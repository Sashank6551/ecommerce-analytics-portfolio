# E-Commerce Analytics Portfolio
**End-to-end customer analytics pipeline using dbt, BigQuery, and Power BI**

### Dashboard Preview

### Page 1: Executive Summary
![Executive Summary](outputs/screenshots/page1_executive_summary.png)
*Overview of key business metrics including total revenue ($5.83M), customer count (48K), and order volume (67K)*

### Page 2: Customer Segmentation Analysis
![Customer Segmentation](outputs/screenshots/page2_customer_segmentation.png)
*RFM analysis showing segment distribution, with Champions averaging $193 LTV and Need Attention segment comprising 29% of customer base*

### Page 3: Product Performance Dashboard
![Product Performance](outputs/screenshots/page3_product_performance.png)
*Product revenue analysis by category, featuring treemap visualization and top-performing SKUs*

### Page 4: Churn Risk & Retention
![Churn Risk](outputs/screenshots/page4_churn_risk.png)
*Predictive churn model identifying $4.3M revenue at risk across 86% of customer base flagged as Critical Risk*

### Page 5: Cohort Analysis
![Cohort Analysis](outputs/screenshots/page5_cohort_analysis.png)*Customer retention curves showing 98% churn rate after first purchase, with 24 monthly cohorts analyzed*

---
## 📊 Project Overview

This project demonstrates a complete analytics workflow from raw data to actionable business insights:

- **Data Engineering:** 16 dbt models transforming 200K+ orders into star schema
- **Customer Segmentation:** RFM analysis identifying 8 behavioral segments
- **Churn Prediction:** Weighted risk scoring model ($4.3M revenue at risk quantified)
- **Cohort Analysis:** Retention tracking revealing 98% Month 1 churn
- **Interactive Dashboard:** 5-page Power BI report with 20+ DAX measures

**Live Dashboard:** [View on Power BI Service](https://app.powerbi.com/links/h_9oLO6Nq4?ctid=3944c393-ac9e-47c6-9e62-7f3eebc94b8f&pbi_source=linkShare&bookmarkGuid=02a2b736-cf9c-495f-a089-89a5669c72cb) | [Download PDF](outputs/ecommerce_dashboard_portfolio.pdf)

---

## 🎯 Key Insights & Business Impact

### 1. Massive Churn Problem (CRITICAL)
- **98-99% of customers never make a second purchase**
- Only 1-2% become repeat buyers
- **Recommendation:** Month 1 retention campaign (email sequence + 10% discount)
- **Estimated ROI:** 20% recovery = $860K additional annual revenue

### 2. Revenue at Risk
- **$4.3M from 33,629 customers at Critical/High churn risk**
- Top 20 high-value at-risk customers identified (avg LTV $190)
- **Recommendation:** Immediate win-back campaign for top 100 by LTV

### 3. Segment Imbalance
- **Need Attention segment:** 29% of customers, only $68 avg LTV
- **Champions segment:** 8% of customers, $190 avg LTV (2.8x higher)
- **Recommendation:** Shift marketing spend to convert Need Attention → Champions

### 4. Product Concentration
- **Top 10 products = 30% of revenue** (Nike, North Face dominate)
- Outerwear category drives majority of sales
- **Recommendation:** Expand premium brand SKUs, negotiate better wholesale terms

---

## 🛠️ Tech Stack

| Layer | Technology | Purpose |
|-------|------------|---------|
| **Data Warehouse** | Google BigQuery | Cloud data storage (200K+ orders, 80K customers) |
| **Transformation** | dbt Core | Data modeling & testing (16 models, 15 tests) |
| **Visualization** | Power BI | Interactive dashboards (5 pages, 20+ measures) |
| **Languages** | SQL, DAX, Markdown | Query, metrics, documentation |
| **Version Control** | Git + GitHub | Code management & portfolio hosting |

---

## 📂 Project Structure
```
ecommerce-analytics-portfolio/
├── models/
│   ├── staging/          # 6 staging models (raw data cleaning)
│   ├── marts/
│   │   ├── core/         # 5 facts + 5 dimensions
│   │   └── schema files  # dbt tests & documentation
├── outputs/
│   ├── dashboard.pdf     # Full 5-page dashboard export
│   └── screenshots/      # Individual page images
├── documentation/
│   ├── ERD.png          # Data model diagram
│   └── insights.md      # Detailed business findings
└── README.md            # This file
```

---

## 📈 Dashboard Pages

### Page 1: Executive Summary
**Purpose:** High-level business health snapshot

**KPIs:** Total Revenue ($5.86M), Orders (68K), AOV ($86), Customers (49K)

**Key Visuals:**
- Monthly revenue trend (50% YoY growth)
- Order status breakdown (25% completion rate - investigate!)
- Top 5 products by revenue (Nike dominates)

![Executive Summary](documentation/outputs/screenshots/page1_executive_summary.png)

---

### Page 2: RFM Segment Analysis
**Purpose:** Customer segmentation for targeted marketing

**Methodology:** Recency-Frequency-Monetary scoring (quintiles 1-5)

**8 Segments Identified:**
1. **Champions (1,227):** $190 avg LTV, 160 days recency
2. **Loyal Customers (1,320):** $119 avg LTV, consistent orders
3. **At Risk (2,171):** $142 avg LTV, 1,090 days inactive - **URGENT**
4. **Need Attention (4,518):** Largest segment, $68 avg LTV

**Key Visual:** RFM Score Heatmap (5x5 grid showing customer distribution)

![Page 2](outputs/screenshots/page2_customer_segmentation.png)

---

### Page 3: Product Performance
**Purpose:** SKU-level revenue and profitability analysis

**Metrics:** 24K products sold, $59.65 avg price, product return rate

**Key Visuals:**
- Revenue by Category & Product (treemap)
- Top 10 products by revenue (bar chart)
- Product Performance Matrix (scatter: revenue vs volume)
- Category trends over time (line chart)

**Insight:** Outerwear + premium brands = 60% of revenue

![Page 3](outputs/screenshots/page3_product_performance.png)

---

### Page 4: Churn Risk Dashboard
**Purpose:** Early warning system for customer churn

**Model:** Weighted composite scoring
- Recency: 40%
- Frequency: 30%
- Monetary: 30%

**Risk Distribution:**
- Critical Risk: 86% (33,629 customers) - $4.3M at risk
- High Risk: 10% (3,932 customers)
- Low/Medium: 4%

**Early Warning Flags:**
- Overdue orders (2x avg frequency elapsed)
- 90-day inactive (no recent orders)
- Revenue drop (<50% historical average)

![Page 4](outputs/screenshots/page4_churn_risk.png)

---

### Page 5: Customer Cohort Analysis
**Purpose:** Retention tracking by acquisition month

**Key Visual:** Retention curve (line chart)
- All cohorts start at 100% (Month 0)
- Drop to 1-2% by Month 1 (massive churn)
- <1% by Month 12 (long-term loyalists)

**Revenue Heatmap:** Shows acquisition revenue >> retention revenue

**Insight:** Problem is retention, not acquisition (steady 500-800 new customers/month)

![Page 5](outputs/screenshots/page5_cohort_analysis.png)

---

## 🗄️ Data Model

**Architecture:** Star schema (5 facts, 5 dimensions)

**Grain Levels:**
- `fct_orders`: One row per order
- `fct_order_items`: One row per line item
- `fct_rfm_segments`: One row per customer
- `fct_customer_cohorts`: One row per cohort-month combination
- `fct_churn_risk_score`: One row per customer

**Key Relationships:**
- `dim_customers` → `fct_orders` (1:N)
- `dim_products` → `fct_order_items` (1:N)
- `dim_date` → `fct_orders` (1:N, active)
- `dim_customers` → `fct_rfm_segments` (1:1)

![ERD Diagram](documentation/data_model_ERD.png)

---

## 🔬 Methodology

### RFM Segmentation
**Scoring:** NTILE(5) window function (quintiles)
- **Recency:** Days since last order (lower = better)
- **Frequency:** Total orders (higher = better)
- **Monetary:** Lifetime revenue (higher = better)

**Segment Rules:**
```sql
CASE
    WHEN R >= 4 AND F >= 4 AND M >= 4 THEN 'Champions'
    WHEN R >= 3 AND F >= 3 THEN 'Loyal Customers'
    WHEN R >= 4 AND F <= 2 THEN 'Promising'
    WHEN R <= 2 AND F >= 3 THEN 'At Risk'
    WHEN R <= 2 AND F <= 2 THEN 'Hibernating'
    ELSE 'Need Attention'
END
```

---

### Churn Risk Model
**Features:** Recency risk + Frequency risk + Monetary risk

**Scoring (0-100 scale):**
- **Recency Risk:** 0-100 based on days inactive
  - 0-30 days: 0 points (active)
  - 30-90 days: 25 points (slight concern)
  - 90-180 days: 50 points (moderate risk)
  - 180-365 days: 75 points (high risk)
  - 365+ days: 100 points (churned)

- **Frequency Risk:** Decline vs historical average
  - 100%+ of historical: 0 points (improving)
  - 75-99%: 25 points (slight decline)
  - 50-74%: 50 points (concerning)
  - 25-49%: 75 points (major decline)
  - <25%: 100 points (near-zero engagement)

- **Monetary Risk:** Same logic as frequency

**Final Score:** (Recency × 0.40) + (Frequency × 0.30) + (Monetary × 0.30)

**Risk Tiers:**
- 0-25: Low Risk
- 26-50: Medium Risk
- 51-75: High Risk
- 76-100: Critical Risk

---

### Cohort Analysis
**Definition:** Customers grouped by first order month

**Retention Calculation:**
```sql
Retention % = (Active Customers in Month N / Cohort Size) × 100
```

**Key Metrics:**
- Cohort size (customers acquired in Month 0)
- Active customers (ordered in Month N)
- Cohort revenue (total revenue from cohort in Month N)
- Retention rate (% still active)

---

## 📊 Sample SQL Queries

### Query 1: Top Customers by LTV in At Risk Segment
```sql
SELECT 
    c.first_name,
    c.last_name,
    r.customer_segment,
    r.monetary_value AS lifetime_revenue,
    r.recency_days,
    r.frequency AS total_orders
FROM analytics.dim_customers c
JOIN analytics.fct_rfm_segments r ON c.user_id = r.user_id
WHERE r.customer_segment = 'At Risk'
ORDER BY r.monetary_value DESC
LIMIT 20;
```

---

### Query 2: Monthly Revenue Trend by Segment
```sql
SELECT 
    DATE_TRUNC(o.order_date, MONTH) AS month,
    r.customer_segment,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(o.order_revenue) AS total_revenue
FROM analytics.fct_orders o
JOIN analytics.fct_rfm_segments r ON o.user_id = r.user_id
WHERE o.status = 'Complete'
GROUP BY month, r.customer_segment
ORDER BY month DESC, total_revenue DESC;
```

---

### Query 3: Cohort Retention Curve
```sql
SELECT 
    cohort_month_start,
    months_since_acquisition,
    cohort_size,
    active_customers,
    retention_rate_pct,
    cohort_revenue
FROM analytics.fct_customer_cohorts
WHERE cohort_month_start >= '2023-01-01'
ORDER BY cohort_month_start, months_since_acquisition;
```

---

## 🚀 Setup Instructions

### Prerequisites
- Google Cloud Platform account (free tier works)
- Python 3.8+ with `dbt-bigquery` package
- Power BI Desktop
- Git

### Installation

**1. Clone Repository**
```bash
git clone https://github.com/Sashank6551/ecommerce-analytics-portfolio.git
cd ecommerce-analytics-portfolio
```

**2. Set Up dbt Environment**
```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install dbt-bigquery
```

**3. Configure BigQuery Connection**
```bash
# Create dbt profile
nano ~/.dbt/profiles.yml

# Add configuration:
ecommerce_analytics:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: service-account
      project: your-gcp-project-id
      dataset: analytics
      keyfile: /path/to/keyfile.json
```

**4. Run dbt Models**
```bash
cd dbt_project
dbt run --full-refresh
dbt test
```

**5. Open Power BI Dashboard**
- Open `outputs/Ecommerce_Analytics_Dashboard_Feb2026.pdf` for static view
- OR connect Power BI Desktop to your BigQuery `analytics` dataset

---

## 📚 Documentation

Detailed technical documentation available:
- [Data Model ERD](documentation/data_model_ERD.png)
- Build Process (Sessions 1-4)
	- [Session 1 Documentation](documentation/E-Commerce%20Analytics%20-%20Session%201%20Documentation.md)
	- [Session 2 Documentation](documentation/E-Commerce%20Analytics%20-%20Session%202%20Documentation.md)
	- [Session 3 Part 1 Documentation](documentation/E-Commerce%20Analytics%20-%20Session%203%20Part%201%20Documentation.md)
	- [Session 3 Part 2 Documentation](documentation/E-Commerce%20Analytics%20-%20Session%203%20Part%202%20Documentation.md)
	- [Session 4 Documentation](documentation/E-Commerce%20Analytics%20-%20Session%204%20Documentation.md)
- [Business Insights Report](documentation/business_insights.md)
- [dBT Learnings](documentation/dbt_schema_behavior_reference.md)
- [Technical Implementation](documentation/technical_documentation.md)
- [Session Notes](documentation/) - Development process & learnings
- Visual Assets:
	- [Dashboard Screenshots](outputs/screenshots/) - All 5 pages (high-res PNG)
	- [ERD Diagram](documentation/data_model_ERD.png) - Star schema visualization  
	- [Dashboard PDF](outputs/ecommerce_dashboard_portfolio.pdf) - Shareable export

---

## 🎓 Skills Demonstrated

**Data Engineering:**
- dbt modeling (staging → marts pattern)
- Star schema design
- Data quality testing
- Incremental transformations

**SQL Proficiency:**
- CTEs (Common Table Expressions)
- Window functions (NTILE, ROW_NUMBER, SUM OVER)
- Date arithmetic (DATE_DIFF, DATE_TRUNC)
- Complex joins (5+ table joins)

**Business Intelligence:**
- DAX measure development
- Power BI data modeling
- Interactive dashboard design
- Storytelling with data

**Analytics:**
- Customer segmentation (RFM)
- Predictive modeling (churn risk)
- Cohort analysis (retention)
- Metric definition & KPIs

---

## 📞 Contact

**Sashank Aravindh D**
- **LinkedIn:** [Sashank Aravindh](https://www.linkedin.com/in/sashank-aravindh-20063b132/)
- **Email:** Sashank6551@gmail.com
- **Portfolio:** [Github Link](https://github.com/Sashank6551/ecommerce-analytics-portfolio)

---

## 📄 License

This project is open source under the MIT License. Data sourced from BigQuery Public Dataset: TheLook E-Commerce.

---

**Last Updated:** February 15, 2026