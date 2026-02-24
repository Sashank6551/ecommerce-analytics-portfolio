# E-Commerce Analytics - Technical Documentation
**Project:** E-Commerce Analytics Portfolio  
**Tech Stack:** BigQuery + dbt + Power BI  
**Data Period:** 2019-2024  
**Last Updated:** February 16, 2026

---

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Data Model Design](#data-model-design)
3. [dbt Implementation](#dbt-implementation)
4. [Power BI Implementation](#power-bi-implementation)
5. [SQL Patterns & Techniques](#sql-patterns--techniques)
6. [DAX Formulas Reference](#dax-formulas-reference)
7. [Performance Optimizations](#performance-optimizations)
8. [Data Quality & Testing](#data-quality--testing)

---

## Architecture Overview

### **Data Flow Pipeline**

```
┌─────────────────────────────────────────────────────────────┐
│  SOURCE                                                     │
│  BigQuery Public Data: thelook_ecommerce                    │
│  - orders, users, order_items, products                    │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│  STAGING LAYER (dbt - Views)                                │
│  - stg_thelook__orders                                      │
│  - stg_thelook__users                                       │
│  - stg_thelook__order_items                                 │
│  - stg_thelook__products                                    │
│                                                             │
│  Purpose: Clean, filter, rename for consistency             │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│  MARTS LAYER (dbt - Tables)                                 │
│                                                             │
│  DIMENSIONS:                                                │
│  - dim_customers (customer master + metrics)                │
│  - dim_products (product catalog + performance)             │
│  - dim_date (calendar table 2019-2024)                      │
│                                                             │
│  FACTS:                                                     │
│  - fct_orders (order-level transactions)                    │
│  - fct_order_items (line item-level transactions)           │
│  - fct_rfm_segments (customer segmentation)                 │
│  - fct_churn_risk_score (predictive churn model)            │
│  - fct_customer_cohorts (retention analysis)                │
└──────────────────┬──────────────────────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────────────────────┐
│  VISUALIZATION LAYER (Power BI)                             │
│  - Executive Summary                                        │
│  - Customer Segmentation                                    │
│  - Product Performance                                      │
│  - Churn Risk & Retention                                   │
│  - Cohort Analysis                                          │
└─────────────────────────────────────────────────────────────┘
```

---

### **Technology Stack Details**

| Layer | Technology | Version | Purpose |
|-------|------------|---------|---------|
| **Data Warehouse** | Google BigQuery | - | Cloud data warehouse, SQL analytics |
| **Transformation** | dbt Core | 1.11.3 | SQL-based transformations, data modeling |
| **Adapter** | dbt-bigquery | 1.11.0 | BigQuery connector for dbt |
| **Visualization** | Power BI Desktop | Latest | Interactive dashboards |
| **Publishing** | Power BI Service | - | Cloud-hosted reports, sharing |
| **Version Control** | Git + GitHub | - | Code versioning, collaboration |
| **Language** | SQL | BigQuery dialect | Data transformations |
| **Formula Language** | DAX | - | Power BI measures, calculated columns |

---

## Data Model Design

### **Star Schema Architecture**

```
                 ┌─────────────┐
                 │  dim_date   │
                 │             │
                 │ date_day PK │
                 │ year        │
                 │ month       │
                 │ quarter     │
                 └──────┬──────┘
                        │
                        │ (1:*)
                        │
       ┌────────────────┼────────────────┐
       │                │                │
       ▼                ▼                ▼
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│ dim_        │  │ fct_orders  │  │ dim_        │
│ customers   │  │             │  │ products    │
│             │  │ order_id PK │  │             │
│ user_id PK  │  │ user_id FK  │  │ product_id  │
│ first_name  │  │ order_date  │  │ PK          │
│ ltv         │  │ revenue     │  │ category    │
│ segment     │  │ status      │  │ brand       │
└──────┬──────┘  └──────┬──────┘  └──────┬──────┘
       │                │                │
       │ (1:*)          │ (1:*)          │ (1:*)
       │                │                │
       ▼                ▼                ▼
┌─────────────┐  ┌───────────-──────┐
│ fct_rfm_    │  │ fct_order_items  │
│ segments    │  │                  │
│             │  │ order_item_id PK │
│ user_id PK  │  │ order_id FK      │
│ rfm_score   │  │ product_id FK    │
│ segment     │  │ sale_price       │
└─────────────┘  └──────────────────┘

┌─────────────┐  ┌──────────────────┐
│ fct_churn_  │  │ fct_customer_    │
│ risk_score  │  │ cohorts          │
│             │  │                  │
│ user_id PK  │  │ cohort_month PK  │
│ churn_score │  │ months_since PK  │
│ risk_tier   │  │ retention_rate   │
└─────────────┘  └──────────────────┘
```

---

### **Key Design Decisions**

#### **1. Grain Definition**
- **fct_orders:** One row per order (order_id = PK)
- **fct_order_items:** One row per line item (order_item_id = PK)
- **fct_rfm_segments:** One row per customer (user_id = PK)
- **fct_churn_risk_score:** One row per customer (user_id = PK)
- **fct_customer_cohorts:** One row per cohort-month combination (cohort_month + months_since = composite PK)

**Why:** Clear grain prevents double-counting and enables accurate aggregations

---

#### **2. Fact vs. Dimension Classification**

**Dimensions (low cardinality, descriptive):**
- `dim_customers` - 48K rows (customer attributes)
- `dim_products` - Product catalog (SKU details)
- `dim_date` - 2,191 rows (2019-2024 daily)

**Facts (high cardinality, transactional):**
- `fct_orders` - 67K rows (order transactions)
- `fct_order_items` - Line items (many-to-one with orders)
- `fct_rfm_segments` - 15K rows (analytical, but derived from transactions)
- `fct_churn_risk_score` - 39K rows (predictive model output)
- `fct_customer_cohorts` - Cohort × Month combinations

**Edge Case:** `fct_rfm_segments` and `fct_churn_risk_score` are technically dimensions (customer attributes) but named "fct" because they're calculated/derived rather than source data.

---

#### **3. Relationship Cardinality**

| Relationship | Type | Direction | Active |
|--------------|------|-----------|--------|
| dim_date → fct_orders | 1:* | Single | Yes |
| dim_date → fct_order_items | 1:* | Single | No (inactive) |
| dim_customers → fct_orders | 1:* | Single | Yes |
| dim_customers → fct_rfm_segments | 1:1 | Single | Yes |
| dim_customers → fct_churn_risk_score | 1:1 | Single | Yes |
| dim_products → fct_order_items | 1:* | Single | Yes |

**Note:** Multiple date relationships handled with one active, others inactive (activated via DAX USERELATIONSHIP when needed)

---

## dbt Implementation

### **Project Structure**

```
ecommerce_analytics/
├── dbt_project.yml              # Project configuration
├── models/
│   ├── staging/
│   │   └── thelook/
│   │       ├── stg_thelook__orders.sql
│   │       ├── stg_thelook__users.sql
│   │       ├── stg_thelook__order_items.sql
│   │       └── stg_thelook__products.sql
│   └── marts/
│       └── core/
│           ├── dim_customers.sql
│           ├── dim_products.sql
│           ├── dim_date.sql
│           ├── fct_orders.sql
│           ├── fct_order_items.sql
│           ├── fct_rfm_segments.sql
│           ├── fct_churn_risk_score.sql
│           ├── fct_customer_cohorts.sql
│           ├── schema_rfm.yml
│           └── schema_churn_risk.yml
└── profiles.yml                 # Connection credentials (not in repo)
```

---

### **Materialization Strategy**

| Model Type | Materialization | Reason |
|------------|----------------|--------|
| **Staging** | `view` | Lightweight, always fresh, no storage cost |
| **Dimensions** | `table` | Better query performance, relatively small |
| **Facts** | `table` | Large datasets, used frequently in dashboards |

**Configuration:**
```sql
-- In model file
{{ config(materialized='table') }}

-- Or in dbt_project.yml
models:
  ecommerce_analytics:
    staging:
      +materialized: view
    marts:
      +materialized: table
```

---

### **Sample dbt Model: fct_churn_risk_score**

**Purpose:** Calculate 0-100 churn risk score using RFM-style components

**SQL Structure (5 CTEs):**

```sql
WITH customer_metrics AS (
    -- Calculate current state metrics per customer
    SELECT
        user_id,
        COUNT(DISTINCT order_id) AS lifetime_orders,
        SUM(order_revenue) AS lifetime_revenue,
        MIN(order_date) AS first_order_date,
        MAX(order_date) AS last_order_date,
        DATE_DIFF(
            (SELECT MAX(order_date) FROM {{ ref('fct_orders') }}),
            MAX(order_date),
            DAY
        ) AS days_since_last_order
    FROM {{ ref('fct_orders') }}
    WHERE status IN ('Complete', 'Shipped')
    GROUP BY user_id
),

risk_calculations AS (
    -- Calculate individual risk components (0-100 scale)
    SELECT
        user_id,
        -- Recency risk (higher = worse)
        CASE
            WHEN days_since_last_order <= 30 THEN 0
            WHEN days_since_last_order <= 90 THEN 25
            WHEN days_since_last_order <= 180 THEN 50
            WHEN days_since_last_order <= 365 THEN 75
            ELSE 100
        END AS recency_risk_score,
        
        -- Frequency risk (compare to historical baseline)
        CASE
            WHEN recent_order_count >= avg_orders_per_90d THEN 0
            WHEN recent_order_count >= avg_orders_per_90d * 0.75 THEN 25
            WHEN recent_order_count >= avg_orders_per_90d * 0.5 THEN 50
            WHEN recent_order_count >= avg_orders_per_90d * 0.25 THEN 75
            ELSE 100
        END AS frequency_risk_score
        
        -- (Monetary risk calculated similarly)
    FROM customer_metrics
),

final_scores AS (
    -- Weighted composite score
    SELECT
        user_id,
        ROUND(
            (recency_risk_score * 0.40) +
            (frequency_risk_score * 0.30) +
            (monetary_risk_score * 0.30),
            1
        ) AS churn_risk_score,
        
        -- Risk tier classification
        CASE
            WHEN churn_risk_score <= 25 THEN 'Low Risk'
            WHEN churn_risk_score <= 50 THEN 'Medium Risk'
            WHEN churn_risk_score <= 75 THEN 'High Risk'
            ELSE 'Critical Risk'
        END AS risk_tier
    FROM risk_calculations
)

SELECT * FROM final_scores
```

**Key Techniques:**
- **Date-relative calculations:** `DATE_DIFF` from dataset max date (not `CURRENT_DATE()` to handle historical data)
- **CASE-based scoring:** Translate continuous metrics to categorical risk levels
- **Weighted composites:** Combine multiple signals with domain-informed weights
- **dbt ref():** `{{ ref('fct_orders') }}` for lineage tracking

---

### **dbt Testing Framework**

**Schema File Example:** `schema_churn_risk.yml`

```yaml
version: 2

models:
  - name: fct_churn_risk_score
    description: "Predictive churn risk model with 0-100 scoring"
    
    columns:
      - name: user_id
        description: "Unique customer identifier"
        tests:
          - not_null
          - unique
          
      - name: churn_risk_score
        description: "Composite risk score (0-100)"
        tests:
          - not_null
          
      - name: risk_tier
        description: "Risk classification"
        tests:
          - not_null
          - accepted_values:
              values:
                - Low Risk
                - Medium Risk
                - High Risk
                - Critical Risk
```

**Run Tests:**
```bash
dbt test                          # All models
dbt test --models fct_churn_risk_score  # Specific model
```

---

## Power BI Implementation

### **Data Connection Configuration**

**Method:** DirectQuery to BigQuery (not Import)

**Why DirectQuery:**
- ✅ Always fresh data (no manual refresh)
- ✅ No row limit (Import mode capped at 1M rows)
- ✅ Smaller .pbix file size

**Tradeoff:**
- ❌ Slower visual rendering (queries BigQuery in real-time)
- ❌ Requires internet connection

**For this project:** Used Import mode (dataset <1M rows, better performance for portfolio demo)

---

### **Data Model in Power BI**

**Tables Imported:**
1. `dim_customers` (48K rows)
2. `dim_products` (Product catalog)
3. `dim_date` (2,191 rows)
4. `fct_orders` (67K rows)
5. `fct_order_items` (Line items)
6. `fct_rfm_segments` (15K rows)
7. `fct_churn_risk_score` (39K rows)
8. `fct_customer_cohorts` (Cohort combinations)

**Date Table Configuration:**
- Right-click `dim_date` → Mark as Date Table
- Date column: `date_day`
- Enables time intelligence functions (YTD, MTD, etc.)

---

### **Power Query Transformations**

**Applied to fct_orders:**

```m
// Remove time component from timestamps
= Table.TransformColumnTypes(
    Source,
    {
        {"created_at", type date},
        {"shipped_at", type date},
        {"delivered_at", type date}
    }
)

// Round profit margin to 2 decimals
= Table.TransformColumns(
    PreviousStep,
    {{"profit_margin", each Number.Round(_, 2), type number}}
)
```

**Why:** Date (not DateTime) matches `dim_date` grain, avoids relationship errors

---

## SQL Patterns & Techniques

### **Pattern 1: CTE Chain for Readability**

**Structure:**
```sql
WITH step1 AS (
    -- Extract raw data
    SELECT * FROM source
),

step2 AS (
    -- Apply transformations
    SELECT 
        key,
        calculated_field
    FROM step1
),

final AS (
    -- Final joins and cleanup
    SELECT * FROM step2
    JOIN other_table USING (key)
)

SELECT * FROM final
```

**Benefits:**
- Each CTE has single responsibility
- Easy to debug (can `SELECT * FROM step1` independently)
- Self-documenting (CTE names explain purpose)

---

### **Pattern 2: NTILE for Quintile Scoring**

**Use Case:** RFM scoring (divide customers into 5 buckets)

```sql
NTILE(5) OVER (ORDER BY recency_days DESC) AS recency_score

-- For recency: Lower days = better = higher score
-- So reverse order: 6 - NTILE(5) ... or ORDER BY DESC
```

**Result:** Automatic distribution into quintiles (1-5)

---

### **Pattern 3: Date-Relative Calculations**

**Problem:** Dataset ends Dec 2024, but analysis date is Feb 2026

**Wrong Approach:**
```sql
DATE_DIFF(CURRENT_DATE(), MAX(order_date), DAY) AS days_since_last_order
-- Returns 400+ days for all customers (seems churned)
```

**Correct Approach:**
```sql
DATE_DIFF(
    (SELECT MAX(order_date) FROM {{ ref('fct_orders') }}),
    MAX(order_date),
    DAY
) AS days_since_last_order
-- Returns accurate days relative to dataset end
```

---

### **Pattern 4: SAFE_DIVIDE for Division Protection**

**Problem:** Division by zero errors

```sql
-- WRONG
AVG(order_revenue) / COUNT(orders)  -- Error if COUNT = 0

-- CORRECT
SAFE_DIVIDE(
    SUM(order_revenue),
    NULLIF(COUNT(orders), 0)
) AS avg_order_value
-- Returns NULL if denominator = 0
```

---

### **Pattern 5: COALESCE for NULL Handling**

**Use Case:** New customers have no historical baseline

```sql
COALESCE(historical_avg_orders, 0) AS baseline_orders
-- If NULL (new customer), use 0 instead
```

---

### **Pattern 6: Window Functions for Ranking**

```sql
ROW_NUMBER() OVER (
    PARTITION BY category
    ORDER BY revenue DESC
) AS rank_in_category

-- Use in WHERE clause: WHERE rank_in_category <= 10
```

---

## DAX Formulas Reference

### **Category 1: Basic Aggregations**

#### **Total Revenue**
```dax
Total Revenue = SUM(fct_orders[order_revenue])
```
- **Type:** Simple aggregation
- **Use:** KPI card, filter context sensitive

---

#### **Total Customers**
```dax
Total Customers = DISTINCTCOUNT(fct_orders[user_id])
```
- **Type:** Distinct count (handles duplicates)
- **Use:** Customer count metric

---

### **Category 2: Calculated Measures**

#### **Average Order Value**
```dax
Avg Order Value = 
DIVIDE(
    [Total Revenue],
    [Total Orders],
    0
)
```
- **Type:** Derived metric (references other measures)
- **Why DIVIDE:** Protects against division by zero (returns 0 instead of error)
- **Use:** AOV trend analysis

---

#### **Retention Rate**
```dax
Retention Rate = 
DIVIDE(
    AVERAGE(fct_customer_cohorts[retention_rate_pct]),
    100,
    0
)
```
- **Format:** Percentage (0.0135 = 1.35%)
- **Use:** Cohort retention analysis

---

### **Category 3: Advanced DAX**

#### **Top Product Revenue**
```dax
Top Product Revenue = 
VAR TopProduct = 
    TOPN(
        1,
        ALL(dim_products[product_id]),
        [Product Revenue],
        DESC
    )
RETURN
    CALCULATE([Product Revenue], TopProduct)
```
- **Pattern:** Variable + CALCULATE + TOPN
- **Why ALL():** Removes filter context to find global top product
- **Why product_id:** Unique identifier (product_name has duplicates)

---

#### **Churn Risk Score (using inactive relationship)**
```dax
Churn Score = 
CALCULATE(
    AVERAGE(fct_churn_risk_score[churn_risk_score]),
    USERELATIONSHIP(dim_customers[user_id], fct_churn_risk_score[user_id])
)
```
- **USERELATIONSHIP:** Activates inactive relationship for this calculation
- **Use:** When multiple relationships exist between same tables

---

### **Category 4: Time Intelligence**

#### **Year-to-Date Revenue (if needed)**
```dax
Revenue YTD = 
TOTALYTD(
    [Total Revenue],
    dim_date[date_day]
)
```
- **Requires:** Date table marked as Date Table
- **Use:** Cumulative revenue tracking

---

### **DAX Best Practices Applied**

1. **Measure references over direct column sums:**
   ```dax
   -- GOOD
   AOV = DIVIDE([Total Revenue], [Total Orders])
   
   -- AVOID
   AOV = DIVIDE(SUM(fct_orders[revenue]), COUNT(fct_orders[order_id]))
   ```
   **Why:** Measure references update automatically if base measure changes

2. **DIVIDE over division operator:**
   ```dax
   -- GOOD
   DIVIDE([Numerator], [Denominator], 0)
   
   -- AVOID
   [Numerator] / [Denominator]  -- Error if denominator = 0
   ```

3. **Variables for complex calculations:**
   ```dax
   Measure = 
   VAR Step1 = CALCULATE(...)
   VAR Step2 = FILTER(Step1, ...)
   RETURN Step2
   ```
   **Why:** Easier to debug, more readable

---

## Performance Optimizations

### **BigQuery Optimizations**

#### **1. Partitioning (if dataset were larger)**
```sql
-- Partition fact tables by date for faster filtering
CREATE TABLE fct_orders
PARTITION BY DATE(order_date)
AS SELECT ...
```
**Benefit:** Query only scans relevant date partitions (cost savings)

---

#### **2. Clustering**
```sql
-- Cluster by frequently filtered columns
CREATE TABLE fct_orders
PARTITION BY DATE(order_date)
CLUSTER BY user_id, status
AS SELECT ...
```
**Benefit:** Data physically sorted for faster lookups

---

#### **3. Materialized Views (considered but not used)**
```sql
-- Pre-aggregate expensive calculations
CREATE MATERIALIZED VIEW mv_customer_metrics AS
SELECT
    user_id,
    COUNT(*) AS order_count,
    SUM(revenue) AS total_revenue
FROM fct_orders
GROUP BY user_id
```
**Tradeoff:** Faster queries, but requires refresh management

---

### **dbt Optimizations**

#### **1. Incremental Models (not used in this project)**
```sql
{{ config(
    materialized='incremental',
    unique_key='order_id'
) }}

SELECT * FROM {{ ref('stg_orders') }}
{% if is_incremental() %}
    WHERE order_date > (SELECT MAX(order_date) FROM {{ this }})
{% endif %}
```
**Use Case:** Large tables where full refresh is slow (not needed for 67K rows)

---

#### **2. Selective Execution**
```bash
# Run only changed models and downstream dependencies
dbt run --select state:modified+

# Run specific model
dbt run --models fct_churn_risk_score
```

---

### **Power BI Optimizations**

#### **1. Import vs. DirectQuery**
- **Used Import mode:** Better performance for <1M rows
- **Tradeoff:** Manual refresh required (acceptable for portfolio)

#### **2. Reduce Visual Count**
- **Limit:** 5-7 visuals per page (more causes slow rendering)
- **Used:** 4-5 visuals per page (within limit)

#### **3. Avoid Unnecessary Calculated Columns**
- **Prefer measures over calculated columns** (measures computed on-demand, columns stored)
- **Used:** All calculations as measures, not columns

---

## Data Quality & Testing

### **dbt Tests Implemented**

| Test Type | Model | Column | Purpose |
|-----------|-------|--------|---------|
| `unique` | fct_churn_risk_score | user_id | No duplicate customers |
| `not_null` | fct_churn_risk_score | user_id | All customers have ID |
| `not_null` | fct_churn_risk_score | churn_risk_score | Score always calculated |
| `accepted_values` | fct_churn_risk_score | risk_tier | Only valid tiers exist |
| `accepted_values` | fct_rfm_segments | customer_segment | Only 8 valid segments |

**Run Results:**
```bash
$ dbt test
Completed successfully
```

---

### **Manual Data Validation**

#### **1. Revenue Reconciliation**
```sql
-- Check fct_orders vs. fct_order_items revenue match
SELECT
    (SELECT SUM(order_revenue) FROM fct_orders) AS order_level,
    (SELECT SUM(sale_price) FROM fct_order_items) AS item_level,
    (SELECT SUM(order_revenue) FROM fct_orders) - 
    (SELECT SUM(sale_price) FROM fct_order_items) AS variance
```
**Result:** $40K variance (0.7%) - flagged for investigation

---

#### **2. Churn Score Range Validation**
```sql
SELECT
    MIN(churn_risk_score) AS min_score,
    MAX(churn_risk_score) AS max_score
FROM fct_churn_risk_score
```
**Expected:** 0-100  
**Actual:** 70-100 (reflects high churn in historical data)

---

#### **3. Retention Rate Sanity Check**
```sql
SELECT AVG(retention_rate_pct)
FROM fct_customer_cohorts
WHERE months_since_acquisition = 6
```
**Result:** 1.35% (aligns with visual in dashboard ✅)

---

## Lessons Learned & Challenges

### **Challenge 1: Column Name Mismatches**
**Problem:** Assumed column names (e.g., `customer_id`) didn't match actual schema (`user_id`)  
**Solution:** Always run `SELECT * LIMIT 5` on source before writing models  
**Prevention:** Document actual schema in comments at top of staging models

---

### **Challenge 2: Date Handling for Historical Data**
**Problem:** Using `CURRENT_DATE()` made all customers appear churned  
**Solution:** Use `(SELECT MAX(order_date) FROM table)` for dataset-relative dates  
**Lesson:** Always consider data freshness when writing time-based logic

---

### **Challenge 3: Power BI Relationship Ambiguity**
**Problem:** Multiple date relationships caused filter errors  
**Solution:** One active relationship, others inactive (use USERELATIONSHIP in DAX)  
**Lesson:** Power BI allows only one active relationship per table pair

---

### **Challenge 4: dbt Schema Naming**
**Problem:** `schema='analytics'` created `analytics_analytics` schema  
**Solution:** Omit schema config when using default target schema  
**Lesson:** dbt appends custom schema to target schema unless macro overrides

---

## Appendix

### **Useful Commands Reference**

#### **dbt Commands**
```bash
dbt run                          # Run all models
dbt run --models model_name      # Run specific model
dbt run --select tag:mart        # Run tagged models
dbt test                         # Run all tests
dbt test --models model_name     # Test specific model
dbt docs generate                # Generate documentation
dbt docs serve                   # Serve docs locally
dbt clean                        # Clear compiled files
```

#### **BigQuery SQL Snippets**
```sql
-- Check table size
SELECT 
  table_name,
  row_count,
  ROUND(size_bytes / 1024 / 1024, 2) AS size_mb
FROM `project.dataset.__TABLES__`
ORDER BY size_bytes DESC;

-- Query cost estimation
SELECT 
  ROUND(SUM(total_bytes_processed) / 1024 / 1024 / 1024, 2) AS gb_processed
FROM `region-us`.INFORMATION_SCHEMA.JOBS_BY_PROJECT
WHERE creation_time > TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 7 DAY);
```

---

### **Power BI Keyboard Shortcuts**
```
Ctrl + S          Save .pbix file
Ctrl + Alt + R    Reading view (preview mode)
Ctrl + C / V      Copy/paste visuals
F11               Full screen
Ctrl + G          Group selected visuals
```

---

### **ERD Diagram**
![Entity Relationship Diagram](./data_model_ERD.png)

---

### **Resources**
- [dbt Documentation](https://docs.getdbt.com/)
- [BigQuery SQL Reference](https://cloud.google.com/bigquery/docs/reference/standard-sql/query-syntax)
- [DAX Guide](https://dax.guide/)
- [Power BI Best Practices](https://learn.microsoft.com/en-us/power-bi/guidance/)

---

**Documentation maintained by:** D Sashank Aravindh
**Last Updated:** February 16, 2026  
**Repository:** [GitHub link](https://github.com/Sashank6551/ecommerce-analytics-portfolio)
