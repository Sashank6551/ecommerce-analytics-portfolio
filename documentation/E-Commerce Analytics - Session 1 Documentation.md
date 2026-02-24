**Date:** Monday, February 9, 2026  
**Session Time:** 11:45 AM - 4:30 PM IST (~4.5 hours with breaks)  
**Status:** ✅ Core models complete, ready for RFM & analysis

---

## Table of Contents
1. [Session Overview](#session-overview)
2. [Prerequisites & Environment Setup](#prerequisites--environment-setup)
3. [Technical Configuration](#technical-configuration)
4. [Data Exploration](#data-exploration)
5. [Models Built](#models-built)
6. [Errors Encountered & Solutions](#errors-encountered--solutions)
7. [Key Learnings](#key-learnings)
8. [Next Session Plan](#next-session-plan)
9. [Code Repository](#code-repository)

---

## Session Overview

### Goals Achieved ✅
- [x] BigQuery project created and configured
- [x] dbt Core installed and connected to BigQuery
- [x] Git repository initialized with proper .gitignore
- [x] Dataset explored and documented (TheLook E-Commerce)
- [x] 8 dbt models built and tested (4 staging + 3 dimensions + 1 fact)
- [x] All models passing without errors

### Deliverables
- **8 dbt models** materialized in BigQuery
- **Clean folder structure** following dbt best practices
- **Documentation** of data schema and relationships
- **Git repository** ready for version control

---

## Prerequisites & Environment Setup

### System Information
- **OS:** Windows 10 (Version 10.0.26200.7623)
- **Python:** 3.11.9
- **Virtual Environment:** `data_analytics_env` (located at `E:\ELTStack_Projects\data_analytics_env\`)
- **dbt Version:** 1.11.3
- **dbt Adapter:** dbt-bigquery 1.11.0

### Google Cloud Platform Setup

#### 1. BigQuery Project Created
- **Project ID:** `portfolio-ecommerce-486905`
- **Dataset:** `analytics` (created automatically by dbt)
- **Region:** US
- **Billing:** Free tier (10GB storage + 1TB query processing/month)

#### 2. Service Account Configuration
- **Service Account:** `dbt-bigquery-dev`
- **Role:** BigQuery Admin
- **Key File:** `portfolio-ecommerce-486905-58f073ad1fd6.json`
- **Location:** `E:\ELTStack_Projects\data_analytics_env\` (NEVER commit to Git!)

#### 3. Environment Variable Setup (Windows)
```cmd
# Set via Windows System Settings (permanent)
Variable Name: GOOGLE_APPLICATION_CREDENTIALS
Variable Value: E:\ELTStack_Projects\data_analytics_env\portfolio-ecommerce-486905-58f073ad1fd6.json

# Verify (in new CMD window)
echo %GOOGLE_APPLICATION_CREDENTIALS%
```

**Important:** Set via System Settings, NOT temporary session variables, for persistence.

### Python Environment

#### Virtual Environment Setup
```cmd
cd E:\ELTStack_Projects\data_analytics_env
python -m venv .
Scripts\activate
```

#### Packages Installed
```txt
dbt-core==1.11.3
dbt-bigquery==1.11.0
# Additional packages in requirements.txt (plotly, scipy, prophet for future use)
```

### Git Configuration

#### Git Repository Initialized
```cmd
cd E:\ELTStack_Projects\data_analytics_env
git init
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

#### .gitignore Configuration
```gitignore
# Credentials
*.json
portfolio-ecommerce-*.json

# Python virtual environment
venv/
env/
Lib/
Scripts/
share/
pyvenv.cfg
Include/
*.cfg
__pycache__/
*.pyc
*.pyo
*.pyd

# dbt
target/
dbt_packages/
logs/
.user.yml

# OS
Thumbs.db
.DS_Store

# IDE
.vscode/
.idea/
*.swp
*.swo
```

**Critical:** Always verify JSON keyfile is ignored before committing:
```cmd
git status  # Should NOT show *.json files
```

---

## Technical Configuration

### dbt Project Structure

```
E:\ELTStack_Projects\data_analytics_env\
└── ecommerce_analytics\
    ├── dbt_project.yml
    ├── models\
    │   ├── staging\
    │   │   └── thelook\
    │   │       ├── stg_thelook__orders.sql
    │   │       ├── stg_thelook__users.sql
    │   │       ├── stg_thelook__order_items.sql
    │   │       └── stg_thelook__products.sql
    │   └── marts\
    │       └── core\
    │           ├── dim_customers.sql
    │           ├── dim_products.sql
    │           ├── dim_date.sql
    │           └── fct_orders.sql
    ├── tests\
    ├── macros\
    ├── snapshots\
    ├── seeds\
    └── analyses\
```

### dbt_project.yml Configuration


```yaml
name: 'ecommerce_analytics'
version: '1.0.0'
config-version: 2

profile: 'ecommerce_analytics'

model-paths: ["models"]
analysis-paths: ["analyses"]
test-paths: ["tests"]
seed-paths: ["seeds"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]

target-path: "target"
clean-targets:
  - "target"
  - "dbt_packages"

models:
  ecommerce_analytics:
    +materialized: view
```

### profiles.yml Configuration

**Location:** `C:\Users\Sashank Aravindh D\.dbt\profiles.yml`

```yaml
ecommerce_analytics:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: service-account
      project: portfolio-ecommerce-486905
      dataset: analytics
      threads: 4
      keyfile: E:/ELTStack_Projects/data_analytics_env/portfolio-ecommerce-486905-58f073ad1fd6.json
      location: US
      timeout_seconds: 300
```

**Notes:**
- Use forward slashes `/` in keyfile path (works better in YAML on Windows)
- No quotes around keyfile path
- Exact indentation (2 spaces per level)

### Connection Testing

```cmd
cd E:\ELTStack_Projects\data_analytics_env\ecommerce_analytics
dbt debug
```

**Expected Output:**
```
Configuration:
  profiles.yml file [OK found and valid]
  dbt_project.yml file [OK found and valid]
Required dependencies:
  - git [OK found]

Connection:
  method: service-account
  database: portfolio-ecommerce-486905
  schema: analytics
  location: US
  
Connection test: [OK connection ok]

All checks passed!
```

---

## Data Exploration

### Dataset: TheLook E-Commerce (BigQuery Public Data)

**Source:** `bigquery-public-data.thelook_ecommerce`

#### Dataset Characteristics

| Metric | Value |
|--------|-------|
| **Total Orders** | 125,069 |
| **Total Customers** | 79,856 |
| **Date Range** | 2019-01-12 to 2026-02-09 (7+ years) |
| **Average Orders per Customer** | 1.57 |

#### Available Tables

1. **orders** - Order transactions
2. **users** - Customer information
3. **order_items** - Line items per order
4. **products** - Product catalog
5. **inventory_items** - Inventory data
6. **distribution_centers** - Warehouse locations
7. **events** - User clickstream events

#### Exploration Queries Run

**Query 1: Orders Table Structure**
```sql
SELECT * 
FROM `bigquery-public-data.thelook_ecommerce.orders`
LIMIT 10;
```

**Key Findings:**
- `order_id` (primary key)
- `user_id` (foreign key to users)
- `status` values: Complete, Cancelled, Processing, Shipped, Returned
- Multiple timestamp fields: created_at, shipped_at, delivered_at, returned_at
- `num_of_item` (items per order)

**Query 2: Users Table Structure**
```sql
SELECT * 
FROM `bigquery-public-data.thelook_ecommerce.users`
LIMIT 10;
```

**Key Findings:**
- `id` field (maps to user_id in orders)
- Demographics: age, gender, state, city, country
- All sample data from Brasil (geographic concentration)
- `traffic_source` (acquisition channel: Search, Display, Email, etc.)
- Account `created_at` dates

**Query 3: Order Items Structure**
```sql
SELECT * 
FROM `bigquery-public-data.thelook_ecommerce.order_items`
LIMIT 10;
```

**Key Findings:**
- Multiple items per order (one-to-many with orders)
- `sale_price` field for revenue calculations
- Some prices as low as $0.01 (data quality concern - filtered out)
- Item-level status tracking

**Query 4: Products Structure**
```sql
SELECT * 
FROM `bigquery-public-data.thelook_ecommerce.products`
LIMIT 10;
```

**Key Findings:**
- `cost` and `retail_price` fields (enables margin analysis)
- `category`, `department`, `brand` for segmentation
- SKU for unique product identification

**Query 5: Date Range & Volume** ⭐
```sql
SELECT 
    MIN(created_at) as earliest_order,
    MAX(created_at) as latest_order,
    COUNT(*) as total_orders,
    COUNT(DISTINCT user_id) as total_customers
FROM `bigquery-public-data.thelook_ecommerce.orders`;
```

**Results:**
- Earliest: 2019-01-12
- Latest: 2026-02-09 (TODAY!)
- Contains future test data (2025-2026)
- Decision: Filter to 2019-2024 for historical analysis

#### Data Quality Issues Identified

1. **Future Dates:** Orders dated 2025-2026 (likely test/demo data)
   - **Solution:** Filter `WHERE created_at < '2025-01-01'`

2. **Low Sale Prices:** Items sold for $0.01-$0.02
   - **Solution:** Filter `WHERE sale_price >= 0.02` in order_items staging

3. **Geographic Concentration:** Sample showed only Brasil users
   - **Note:** Full dataset likely has broader coverage

#### Entity Relationship Diagram (Text)

```
users (79,856 rows)
  |
  | 1:N (user_id)
  |
  v
orders (125,069 rows)
  |
  | 1:N (order_id)
  |
  v
order_items (line items)
  |
  | N:1 (product_id)
  |
  v
products (catalog)
```

---

## Models Built

### Staging Layer (4 Models - Views)

Staging models clean and standardize raw data from the source.

#### 1. stg_thelook__orders.sql

**Purpose:** Clean order transactions, filter test data

**Key Transformations:**
- Filter to pre-2025 orders (removes test data)
- Explicit TIMESTAMP casting for date fields
- Add `_loaded_at` audit column

**Materialization:** VIEW  
**Row Count:** ~100,000 (filtered from 125K)

```sql
{{
    config(
        materialized='view'
    )
}}

WITH source AS (
    SELECT *
    FROM `bigquery-public-data.thelook_ecommerce.orders`
    WHERE created_at < '2025-01-01'
),

renamed AS (
    SELECT
        order_id,
        user_id,
        CAST(created_at AS TIMESTAMP) AS created_at,
        CAST(returned_at AS TIMESTAMP) AS returned_at,
        CAST(shipped_at AS TIMESTAMP) AS shipped_at,
        CAST(delivered_at AS TIMESTAMP) AS delivered_at,
        status,
        num_of_item,
        CURRENT_TIMESTAMP() AS _loaded_at
    FROM source
)

SELECT * FROM renamed
```

#### 2. stg_thelook__users.sql

**Purpose:** Standardize customer data

**Key Transformations:**
- Rename `id` → `user_id` for consistency
- Filter to pre-2025 account creations
- Extract geographic and demographic attributes

**Materialization:** VIEW

```sql
{{
    config(
        materialized='view'
    )
}}

WITH source AS (
    SELECT *
    FROM `bigquery-public-data.thelook_ecommerce.users`
    WHERE created_at < '2025-01-01'
),

renamed AS (
    SELECT
        id AS user_id,
        first_name,
        last_name,
        email,
        age,
        gender,
        state,
        city,
        country,
        postal_code,
        latitude,
        longitude,
        traffic_source,
        CAST(created_at AS TIMESTAMP) AS created_at,
        CURRENT_TIMESTAMP() AS _loaded_at
    FROM source
)

SELECT * FROM renamed
```

#### 3. stg_thelook__order_items.sql

**Purpose:** Clean line-item data, remove data quality issues

**Key Transformations:**
- Filter to pre-2025 items
- Exclude suspiciously low prices (< $0.02)
- Rename `id` → `order_item_id`

**Materialization:** VIEW

```sql
{{
    config(
        materialized='view'
    )
}}

WITH source AS (
    SELECT *
    FROM `bigquery-public-data.thelook_ecommerce.order_items`
    WHERE created_at < '2025-01-01'
),

renamed AS (
    SELECT
        id AS order_item_id,
        order_id,
        user_id,
        product_id,
        inventory_item_id,
        status,
        sale_price,
        CAST(created_at AS TIMESTAMP) AS created_at,
        CAST(shipped_at AS TIMESTAMP) AS shipped_at,
        CAST(delivered_at AS TIMESTAMP) AS delivered_at,
        CAST(returned_at AS TIMESTAMP) AS returned_at,
        CURRENT_TIMESTAMP() AS _loaded_at
    FROM source
    WHERE sale_price >= 0.02
)

SELECT * FROM renamed
```

#### 4. stg_thelook__products.sql

**Purpose:** Enrich product catalog with calculated metrics

**Key Transformations:**
- Calculate margin percentage: `(retail_price - cost) / retail_price * 100`
- Rename `id` → `product_id`
- Rename `name` → `product_name`

**Materialization:** VIEW

```sql
{{
    config(
        materialized='view'
    )
}}

WITH source AS (
    SELECT *
    FROM `bigquery-public-data.thelook_ecommerce.products`
),

renamed AS (
    SELECT
        id AS product_id,
        name AS product_name,
        category,
        department,
        brand,
        sku,
        cost,
        retail_price,
        ROUND((retail_price - cost) / NULLIF(retail_price, 0) * 100, 2) AS margin_percent,
        distribution_center_id,
        CURRENT_TIMESTAMP() AS _loaded_at
    FROM source
)

SELECT * FROM renamed
```

---

### Marts Layer - Dimensions (3 Models - Tables)

Dimension tables are "lookup tables" that provide context for facts.

#### 1. dim_customers.sql

**Purpose:** Customer master table with lifetime metrics

**Key Features:**
- One row per customer
- Enriched with order history (first/last order, lifetime orders)
- Customer segmentation logic
- Handles customers who never ordered (LEFT JOIN)

**Materialization:** TABLE  
**Business Logic:**
- **Never Purchased:** No orders
- **One-Time Buyer:** 1 order
- **Repeat Customer:** 2-5 orders
- **Loyal Customer:** 6+ orders

```sql
{{
    config(
        materialized='table'
    )
}}

WITH users AS (
    SELECT * FROM {{ ref('stg_thelook__users') }}
),

customer_orders AS (
    SELECT
        user_id,
        MIN(created_at) AS first_order_date,
        MAX(created_at) AS last_order_date,
        COUNT(DISTINCT order_id) AS lifetime_orders
    FROM {{ ref('stg_thelook__orders') }}
    WHERE status IN ('Complete', 'Shipped', 'Processing')
    GROUP BY user_id
),

joined AS (
    SELECT
        u.user_id,
        u.first_name,
        u.last_name,
        u.email,
        u.age,
        u.gender,
        u.state,
        u.city,
        u.country,
        u.traffic_source,
        u.created_at AS account_created_at,
        COALESCE(o.first_order_date, TIMESTAMP('9999-12-31')) AS first_order_date,
        COALESCE(o.last_order_date, TIMESTAMP('1900-01-01')) AS last_order_date,
        COALESCE(o.lifetime_orders, 0) AS lifetime_orders,
        CASE
            WHEN o.lifetime_orders IS NULL THEN 'Never Purchased'
            WHEN o.lifetime_orders = 1 THEN 'One-Time Buyer'
            WHEN o.lifetime_orders BETWEEN 2 AND 5 THEN 'Repeat Customer'
            WHEN o.lifetime_orders > 5 THEN 'Loyal Customer'
        END AS customer_segment,
        CURRENT_TIMESTAMP() AS _loaded_at
    FROM users u
    LEFT JOIN customer_orders o ON u.user_id = o.user_id
)

SELECT * FROM joined
```

#### 2. dim_products.sql

**Purpose:** Product master with sales performance metrics

**Key Features:**
- One row per product
- Enriched with historical sales data
- Product tier classification based on revenue

**Materialization:** TABLE  
**Business Logic:**
- **Top Seller:** $10,000+ revenue
- **Mid Performer:** $1,000-$10,000 revenue
- **Low Performer:** <$1,000 revenue
- **Never Sold:** No sales

```sql
{{
    config(
        materialized='table'
    )
}}

WITH products AS (
    SELECT * FROM {{ ref('stg_thelook__products') }}
),

product_performance AS (
    SELECT
        product_id,
        COUNT(DISTINCT order_id) AS times_ordered,
        SUM(sale_price) AS total_revenue,
        AVG(sale_price) AS avg_sale_price
    FROM {{ ref('stg_thelook__order_items') }}
    WHERE status IN ('Complete', 'Shipped')
    GROUP BY product_id
),

joined AS (
    SELECT
        p.product_id,
        p.product_name,
        p.category,
        p.department,
        p.brand,
        p.sku,
        p.cost,
        p.retail_price,
        p.margin_percent,
        COALESCE(perf.times_ordered, 0) AS times_ordered,
        COALESCE(perf.total_revenue, 0) AS total_revenue,
        COALESCE(perf.avg_sale_price, 0) AS avg_sale_price,
        CASE
            WHEN perf.total_revenue > 10000 THEN 'Top Seller'
            WHEN perf.total_revenue BETWEEN 1000 AND 10000 THEN 'Mid Performer'
            WHEN perf.total_revenue < 1000 THEN 'Low Performer'
            ELSE 'Never Sold'
        END AS product_tier,
        CURRENT_TIMESTAMP() AS _loaded_at
    FROM products p
    LEFT JOIN product_performance perf ON p.product_id = perf.product_id
)

SELECT * FROM joined
```

#### 3. dim_date.sql

**Purpose:** Calendar table for time-based analysis

**Key Features:**
- Every date from 2019-01-01 to 2024-12-31 (~2,190 rows)
- Date parts extracted (year, quarter, month, week, day)
- Formatted strings (month name, day name)
- Business logic flags (is_weekend)

**Materialization:** TABLE

```sql
{{
    config(
        materialized='table'
    )
}}

WITH date_spine AS (
    SELECT
        DATE_ADD(DATE('2019-01-01'), INTERVAL day_offset DAY) AS date_day
    FROM
        UNNEST(GENERATE_ARRAY(0, DATE_DIFF(DATE('2024-12-31'), DATE('2019-01-01'), DAY))) AS day_offset
),

date_attributes AS (
    SELECT
        date_day,
        EXTRACT(YEAR FROM date_day) AS year,
        EXTRACT(QUARTER FROM date_day) AS quarter,
        EXTRACT(MONTH FROM date_day) AS month,
        EXTRACT(WEEK FROM date_day) AS week_of_year,
        EXTRACT(DAY FROM date_day) AS day_of_month,
        EXTRACT(DAYOFWEEK FROM date_day) AS day_of_week,
        FORMAT_DATE('%B', date_day) AS month_name,
        FORMAT_DATE('%A', date_day) AS day_name,
        FORMAT_DATE('%Y-%m', date_day) AS year_month,
        FORMAT_DATE('%Y-Q%Q', date_day) AS year_quarter,
        CASE WHEN EXTRACT(DAYOFWEEK FROM date_day) IN (1, 7) THEN TRUE ELSE FALSE END AS is_weekend,
        CURRENT_TIMESTAMP() AS _loaded_at
    FROM date_spine
)

SELECT * FROM date_attributes
```

---

### Marts Layer - Facts (1 Model - Table)

Fact tables store measurable events (transactions) with foreign keys to dimensions.

#### 1. fct_orders.sql

**Purpose:** Order-level fact table for revenue and operational analysis

**Grain:** One row per order  
**Materialization:** TABLE

**Key Features:**
- Aggregates line items to order level
- Calculates revenue metrics
- Tracks fulfillment timing (days to ship/deliver)
- Status flags for filtering (is_completed, is_cancelled, is_returned)
- Foreign keys for joining to dimensions

**Foreign Keys:**
- `user_id` → links to `dim_customers`
- `order_date` → links to `dim_date`

**Metrics Calculated:**
- `order_revenue` - Total revenue per order
- `total_items` - Count of line items
- `avg_item_price` - Average item price in order
- `days_to_ship` - Time from order to shipment
- `days_to_deliver` - Time from shipment to delivery
- `days_to_complete` - End-to-end fulfillment time

```sql
{{
    config(
        materialized='table'
    )
}}

WITH orders AS (
    SELECT * FROM {{ ref('stg_thelook__orders') }}
),

order_items AS (
    SELECT * FROM {{ ref('stg_thelook__order_items') }}
),

order_totals AS (
    SELECT
        order_id,
        COUNT(DISTINCT order_item_id) AS total_items,
        SUM(sale_price) AS order_revenue,
        AVG(sale_price) AS avg_item_price,
        MIN(sale_price) AS min_item_price,
        MAX(sale_price) AS max_item_price
    FROM order_items
    GROUP BY order_id
),

joined AS (
    SELECT
        o.order_id,
        o.user_id,
        CAST(o.created_at AS DATE) AS order_date,
        o.status,
        o.num_of_item,
        o.created_at,
        o.shipped_at,
        o.delivered_at,
        o.returned_at,
        COALESCE(ot.total_items, 0) AS total_items,
        COALESCE(ot.order_revenue, 0) AS order_revenue,
        COALESCE(ot.avg_item_price, 0) AS avg_item_price,
        COALESCE(ot.min_item_price, 0) AS min_item_price,
        COALESCE(ot.max_item_price, 0) AS max_item_price,
        CASE WHEN o.status = 'Complete' THEN 1 ELSE 0 END AS is_completed,
        CASE WHEN o.status = 'Cancelled' THEN 1 ELSE 0 END AS is_cancelled,
        CASE WHEN o.returned_at IS NOT NULL THEN 1 ELSE 0 END AS is_returned,
        DATE_DIFF(CAST(o.shipped_at AS DATE), CAST(o.created_at AS DATE), DAY) AS days_to_ship,
        DATE_DIFF(CAST(o.delivered_at AS DATE), CAST(o.shipped_at AS DATE), DAY) AS days_to_deliver,
        DATE_DIFF(CAST(o.delivered_at AS DATE), CAST(o.created_at AS DATE), DAY) AS days_to_complete,
        CURRENT_TIMESTAMP() AS _loaded_at
    FROM orders o
    LEFT JOIN order_totals ot ON o.order_id = ot.order_id
)

SELECT * FROM joined
```

---

## Errors Encountered & Solutions

### Error 1: Resource Names Cannot Contain Spaces

**Error Message:**
```
Runtime Error
  Resource names cannot contain spaces:
    * 'model.ecommerce_analytics.Staging model for orders' (models\Staging model for orders.sql)
  Please rename the invalid model(s) so that their name(s) do not contain any spaces.
```

**Cause:** Saved draft SQL file with filename containing spaces: `Staging model for orders.sql`

**Solution:** 
- Delete file with spaces
- Create properly named file: `stg_thelook__orders.sql`
- Follow dbt naming convention: `<layer>_<source>__<entity>.sql`

**Lesson:** 
- dbt uses filename as model name
- Never use spaces in filenames
- Use underscores for separation
- Use lowercase for consistency

---

### Error 2: Connection Test Failed - NoneType Object Has No Attribute 'close'

**Error Message:**
```
Connection test: [ERROR]
dbt was unable to connect to the specified database.
The database returned the following error:
>'NoneType' object has no attribute 'close'
```

**Cause:** Incorrect keyfile path in `profiles.yml`

**Root Issues:**
1. Service account JSON file stored in different location than path specified in profiles
2. Path used backslashes `\` which can cause issues in YAML
3. Path had been copied from draft script with wrong location

**Solution:**
1. Verified actual location of JSON keyfile: `dir E:\ELTStack_Projects\data_analytics_env\*.json`
2. Updated `profiles.yml` with correct path using forward slashes:
   ```yaml
   keyfile: E:/ELTStack_Projects/data_analytics_env/portfolio-ecommerce-486905-58f073ad1fd6.json
   ```
3. No quotes around the path
4. Exact 2-space indentation in YAML

**Verification:**
```cmd
dbt debug
# Output: Connection test: [OK connection ok]
```

**Lesson:**
- Always verify file paths are correct before debugging other issues
- Use forward slashes `/` in YAML for Windows paths (more reliable)
- Don't quote keyfile paths in profiles.yml
- YAML is indentation-sensitive (2 spaces)

---

### Error 3: Git Commit Failed - User Identity Unknown

**Error Message:**
```
error: switch 'm' requires a value

*** Please tell me who you are.
```

**Cause:** Git user identity not configured (first-time setup required)

**Solution:**
```cmd
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

**Then retry commit:**
```cmd
git commit -m "Initial commit: Add .gitignore"
```

**Lesson:** 
- Git requires user identity before first commit
- Use `--global` flag to set for all repositories
- Email should match GitHub account if using GitHub

---

### Error 4: Nothing Added to Commit (Untracked Files Present)

**Error Message:**
```
nothing added to commit but untracked files present (use "git add" to track)
```

**Cause:** Tried to commit without staging files first

**Solution:**
```cmd
git add .gitignore
git commit -m "Initial commit: Add .gitignore"
```

**Lesson:**
- Git workflow: `add` → `commit` → `push`
- `git add <file>` stages changes
- `git commit` saves staged changes
- Always check `git status` before committing

---

### Error 5: .gitignore Not Ignoring Python venv Files

**Symptom:** `Lib/`, `Scripts/`, `share/`, `pyvenv.cfg` showing as untracked files

**Cause:** Initial `.gitignore` only had generic patterns:
```gitignore
venv/
env/
```

But Windows Python venv creates different structure.

**Solution:** Updated `.gitignore` with Windows-specific venv patterns:
```gitignore
# Python virtual environment
venv/
env/
Lib/
Scripts/
share/
pyvenv.cfg
Include/
*.cfg
```

**Verification:**
```cmd
git status
# venv files should no longer appear in untracked list
```

**Lesson:**
- `.gitignore` patterns must match actual file structure
- Windows Python venv structure differs from Linux/Mac
- Always test `.gitignore` with `git status` before first commit

---

### Error 6: Confusion About Environment Variables on Windows

**Issue:** Tried to use bash commands on Windows CMD

**Attempts:**
- Created `.envrc` file (bash convention, doesn't work on Windows)
- Tried `source .envrc` (bash command, fails on Windows)
- Ran bash script saved as `.bat` file (syntax errors)

**Solution:** Used Windows System Environment Variables instead
- Windows Settings → "Edit environment variables"
- Created permanent `GOOGLE_APPLICATION_CREDENTIALS` variable
- Restarted terminal for changes to take effect

**Alternative (session-only):**
```cmd
# Command Prompt
set GOOGLE_APPLICATION_CREDENTIALS=E:\path\to\keyfile.json

# PowerShell
$env:GOOGLE_APPLICATION_CREDENTIALS="E:\path\to\keyfile.json"
```

**Lesson:**
- Windows CMD ≠ bash/Linux terminal
- Use `set` not `export` on Windows CMD
- System environment variables persist across sessions
- `.envrc` files don't work natively on Windows

---

## Key Learnings

### dbt Best Practices Learned

1. **Folder Structure Matters**
   ```
   models/
   ├── staging/        ← Raw data cleaning (views)
   │   └── <source>/   ← One folder per source system
   └── marts/          ← Business logic (tables)
       └── core/       ← Core business entities
   ```

2. **Naming Conventions**
   - Staging: `stg_<source>__<entity>.sql`
   - Dimensions: `dim_<entity>.sql`
   - Facts: `fct_<entity>.sql`
   - Use double underscore `__` between source and entity
   - Always lowercase, no spaces

3. **Materialization Strategy**
   - **Views** for staging (no storage cost, always fresh)
   - **Tables** for marts (better query performance)
   - Configure per model with `{{ config(materialized='table') }}`

4. **Model References**
   - Use `{{ ref('model_name') }}` instead of hardcoding table names
   - Creates automatic dependencies
   - Enables lineage tracking
   - Example: `FROM {{ ref('stg_thelook__orders') }}`

5. **Data Quality from the Start**
   - Filter bad data in staging layer (e.g., `WHERE created_at < '2025-01-01'`)
   - Document assumptions in SQL comments
   - Add audit columns (`_loaded_at`)

6. **CTE Pattern** (Common Table Expressions)
   ```sql
   WITH source AS (...),
   renamed AS (...),
   final AS (...)
   SELECT * FROM final
   ```
   - More readable than nested subqueries
   - Each CTE has a clear purpose
   - Easy to debug step-by-step

### SQL Techniques Applied

1. **COALESCE for NULL Handling**
   ```sql
   COALESCE(o.lifetime_orders, 0) AS lifetime_orders
   ```
   - Replaces NULL with default value
   - Prevents NULL in downstream calculations

2. **CASE Statements for Segmentation**
   ```sql
   CASE
       WHEN lifetime_orders IS NULL THEN 'Never Purchased'
       WHEN lifetime_orders = 1 THEN 'One-Time Buyer'
       ...
   END AS customer_segment
   ```

3. **Date Calculations**
   ```sql
   DATE_DIFF(delivered_at, created_at, DAY) AS days_to_complete
   ```
   - BigQuery-specific function
   - Calculate business metrics (fulfillment time)

4. **Window Functions** (Not used yet, but coming in RFM)
   - Will use `ROW_NUMBER()` for recency ranking
   - `NTILE()` for RFM score bucketing

5. **LEFT JOIN Pattern**
   ```sql
   FROM users u
   LEFT JOIN orders o ON u.user_id = o.user_id
   ```
   - Preserves all users, even those without orders
   - Critical for "Never Purchased" segment

### BigQuery Specifics

1. **Free Tier is Generous**
   - 10 GB storage/month (we're using ~500 MB)
   - 1 TB query processing/month (we've used ~20 GB)
   - No need to activate $300 trial yet

2. **No "Always On" Costs**
   - Unlike Azure SQL or traditional databases
   - Only pay when queries run
   - No need to pause/stop resources

3. **Public Datasets**
   - `bigquery-public-data.*` available for free
   - Great for learning and portfolio projects
   - TheLook E-Commerce is production-quality data

4. **Query Performance**
   - Views: No storage, recalculated on each query
   - Tables: Stored, faster for repeated queries
   - Our models run in <10 seconds (excellent)

### Git & Version Control

1. **`.gitignore` is Critical**
   - MUST exclude credentials (*.json)
   - Test with `git status` before first commit
   - Can't uncommit exposed secrets easily

2. **Commit Often**
   - Ideally after each working model
   - Descriptive commit messages
   - Example: `"Add staging models for orders and users"`

3. **File Organization**
   - Keep credentials outside project folder (if possible)
   - Use environment variables for secrets
   - Never commit API keys, passwords, service accounts

### Windows-Specific Learnings

1. **Path Separators**
   - Windows uses backslash `\`
   - But forward slash `/` works in most tools
   - Use `/` in YAML, Python code for cross-platform compatibility

2. **Command Prompt vs PowerShell vs Git Bash**
   - CMD: Windows native, use `set` for env vars
   - PowerShell: Modern, use `$env:VAR="value"`
   - Git Bash: Unix-like, use `export VAR="value"`

3. **Virtual Environment Activation**
   ```cmd
   # CMD
   Scripts\activate
   
   # PowerShell
   Scripts\Activate.ps1
   
   # Git Bash
   source Scripts/activate
   ```

### Project Management Insights

1. **Scope Creep Prevention**
   - We could have used GA4 dataset (more complex)
   - Chose TheLook for cleaner learning experience
   - "Perfect is the enemy of done"

2. **Time Tracking**
   - ~4.5 hours for complete staging + marts layer
   - Environment setup took ~1 hour (one-time cost)
   - Actual modeling: ~3 hours (8 models)

3. **Break Down Big Tasks**
   - Didn't try to build everything at once
   - Staging first, then dimensions, then facts
   - Test each model before moving on

4. **Documentation While Building**
   - Easier to document as you go vs. retroactively
   - SQL comments explain "why", not just "what"
   - README tracks decisions and learnings

---

## Next Session Plan

### Immediate Priorities (Next 2-3 Hours)

#### 1. RFM Segmentation Model (60 min)

**Goal:** Create `fct_customer_rfm` model with RFM scores and segments

**RFM Framework:**
- **Recency:** Days since last order (lower = better)
- **Frequency:** Total number of orders (higher = better)
- **Monetary:** Total revenue contributed (higher = better)

**Approach:**
- Calculate RFM metrics per customer
- Score each metric 1-5 using `NTILE(5)`
- Concatenate scores (e.g., "555" = best customer)
- Map RFM combinations to segments (Champions, Loyal, At Risk, etc.)

**File:** `models/marts/core/fct_customer_rfm.sql`

**SQL Pseudocode:**
```sql
WITH customer_metrics AS (
    SELECT
        user_id,
        DATE_DIFF(CURRENT_DATE(), MAX(order_date), DAY) AS recency_days,
        COUNT(DISTINCT order_id) AS frequency,
        SUM(order_revenue) AS monetary
    FROM {{ ref('fct_orders') }}
    WHERE status = 'Complete'
    GROUP BY user_id
),

rfm_scores AS (
    SELECT
        user_id,
        recency_days,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS r_score,
        NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
        NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
    FROM customer_metrics
),

rfm_segments AS (
    SELECT
        *,
        CONCAT(CAST(r_score AS STRING), CAST(f_score AS STRING), CAST(m_score AS STRING)) AS rfm_score,
        CASE
            WHEN r_score >= 4 AND f_score >= 4 THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customers'
            WHEN r_score >= 4 AND f_score <= 2 THEN 'Promising'
            WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
            WHEN r_score <= 2 AND f_score <= 2 THEN 'Lost'
            ELSE 'Needs Attention'
        END AS rfm_segment
    FROM rfm_scores
)

SELECT * FROM rfm_segments
```

#### 2. Analysis Queries (30 min)

Create ad-hoc analysis queries in `analyses/` folder:

**File:** `analyses/customer_segmentation_analysis.sql`
```sql
-- Distribution of customers by RFM segment
SELECT
    rfm_segment,
    COUNT(*) as customer_count,
    ROUND(AVG(monetary), 2) as avg_revenue,
    ROUND(AVG(frequency), 1) as avg_orders
FROM {{ ref('fct_customer_rfm') }}
GROUP BY rfm_segment
ORDER BY customer_count DESC
```

**File:** `analyses/monthly_revenue_trends.sql`
```sql
-- Revenue trends by month
SELECT
    d.year_month,
    SUM(f.order_revenue) as total_revenue,
    COUNT(DISTINCT f.order_id) as total_orders,
    COUNT(DISTINCT f.user_id) as unique_customers
FROM {{ ref('fct_orders') }} f
JOIN {{ ref('dim_date') }} d ON f.order_date = d.date_day
WHERE f.is_completed = 1
GROUP BY d.year_month
ORDER BY d.year_month
```

**File:** `analyses/product_performance.sql`
```sql
-- Top products by revenue
SELECT
    p.product_name,
    p.category,
    p.brand,
    p.product_tier,
    p.total_revenue,
    p.times_ordered,
    ROUND(p.margin_percent, 1) as margin_pct
FROM {{ ref('dim_products') }} p
WHERE p.product_tier IN ('Top Seller', 'Mid Performer')
ORDER BY p.total_revenue DESC
LIMIT 20
```

#### 3. Data Quality Tests (15 min)

Add basic schema tests in `models/staging/thelook/schema.yml`:

```yaml
version: 2

models:
  - name: stg_thelook__orders
    description: Staging table for order transactions
    columns:
      - name: order_id
        description: Primary key
        tests:
          - unique
          - not_null
      - name: user_id
        description: Foreign key to users
        tests:
          - not_null
      - name: status
        description: Order status
        tests:
          - accepted_values:
              values: ['Complete', 'Cancelled', 'Processing', 'Shipped', 'Returned']

  - name: stg_thelook__users
    description: Staging table for customer data
    columns:
      - name: user_id
        description: Primary key
        tests:
          - unique
          - not_null
      - name: email
        description: Customer email
        tests:
          - unique
          - not_null
```

**Run tests:**
```cmd
dbt test
```

#### 4. Git Commit (15 min)

**Commit all completed work:**

```cmd
cd E:\ELTStack_Projects\data_analytics_env\ecommerce_analytics

# Check what's changed
git status

# Add all model files
git add models/

# Commit with descriptive message
git commit -m "Add staging layer (4 models), marts layer (3 dims + 1 fact), and analysis queries"

# (Optional) Push to GitHub if remote configured
git push origin main
```

---

### Medium-Term Goals (Next 3-5 Sessions)

#### Session 2: Visualization & Insights (Feb 10-11)
- Export key datasets to CSV/Parquet
- Create Python visualizations with Plotly
  - RFM segment distribution (bar chart)
  - Revenue trends over time (line chart)
  - Top products by category (treemap)
- Document 5-7 key business insights

#### Session 3: Advanced Analytics (Feb 12-13)
- Customer cohort analysis (retention by signup month)
- Product affinity analysis (frequently bought together)
- Geographic segmentation (revenue by state/region)
- Seasonality analysis (monthly patterns)

#### Session 4: Documentation & Polish (Feb 14-16)
- Complete README.md with:
  - Project overview
  - Data model diagram
  - Key findings & insights
  - Setup instructions
  - Sample queries
- Add dbt model descriptions in YAML
- Screenshot dashboards/visualizations
- Record 2-3 minute walkthrough video (optional)

#### Session 5: Final Review & GitHub Publish (Feb 17-20)
- Code review and refactoring
- Ensure all queries run without errors
- Test setup instructions on fresh environment
- Publish to GitHub with polished README
- Prepare talking points for interviews

---

### Stretch Goals (If Time Permits)

1. **dbt Documentation Site**
   ```cmd
   dbt docs generate
   dbt docs serve
   ```
   - Auto-generated documentation with lineage graphs
   - Professional presentation of data models

2. **Incremental Models**
   - Convert staging models to incremental (only new data)
   - Learn production dbt patterns

3. **dbt Packages**
   - Install `dbt_utils` for reusable macros
   - Use `surrogate_key()` for composite keys

4. **CI/CD with GitHub Actions**
   - Auto-run `dbt test` on every commit
   - Learn modern data engineering workflows

5. **Export to Power BI**
   - Connect Power BI to BigQuery
   - Build interactive dashboard
   - Alternative to Python visualization

---

## Code Repository

### Current Git Status

**Repository:** Initialized locally at `E:\ELTStack_Projects\data_analytics_env\`  
**Branch:** `master` (default)  
**Commits:** 1 (Initial commit: Add .gitignore)  
**Remote:** Not configured yet

### Files Tracked by Git

```
.gitignore
```

### Files Ignored (Not Tracked)

```
Lib/
Scripts/
share/
pyvenv.cfg
Include/
*.json
target/
dbt_packages/
logs/
```

### Recommended GitHub Setup (Next Session)

1. **Create GitHub Repository**
   - Name: `ecommerce-analytics-portfolio`
   - Description: "End-to-end e-commerce analytics project using dbt + BigQuery"
   - Public (for portfolio visibility)

2. **Connect Local to Remote**
   ```cmd
   git remote add origin https://github.com/yourusername/ecommerce-analytics-portfolio.git
   git branch -M main
   git push -u origin main
   ```

3. **Add README.md**
   - Project overview
   - Tech stack
   - Setup instructions
   - Key findings

4. **Add .gitattributes** (optional)
   ```
   *.sql linguist-language=SQL
   ```
   - Helps GitHub recognize SQL as primary language

---

## Appendix

### Useful dbt Commands Reference

```cmd
# Connection testing
dbt debug

# Run all models
dbt run

# Run specific model
dbt run --select model_name

# Run all models in a folder
dbt run --select staging.thelook

# Run model and all downstream dependencies
dbt run --select model_name+

# Run tests
dbt test

# Run specific test
dbt test --select model_name

# Generate documentation
dbt docs generate
dbt docs serve

# Clean compiled files
dbt clean

# Show project structure
dbt ls

# Compile SQL without running
dbt compile --select model_name
```

### BigQuery Cost Monitoring

**Check query costs:**
1. Go to BigQuery Console
2. Click "Query History"
3. Check "Bytes Processed" column
4. 1 TB = 1,000 GB = 1,000,000 MB

**Approximate costs (after free tier):**
- $5 per TB of data processed
- Our project: ~20 GB processed = $0.10

**Storage costs:**
- $0.02 per GB/month (after 10 GB free)
- Our project: ~500 MB = $0.01/month

**Total estimated cost for project: <$1**

### Windows Terminal Setup Tips

**Enable copy-paste in CMD:**
- Right-click title bar → Properties
- Check "QuickEdit Mode"
- Now can select text and right-click to copy

**Better terminal: Windows Terminal**
- Download from Microsoft Store
- Supports tabs, better fonts, easier copy-paste

**Alternative: VS Code Integrated Terminal**
- Open VS Code in project folder
- Terminal → New Terminal
- Auto-activates venv if configured

### Troubleshooting Guide

**Issue: `dbt` command not found**
```cmd
# Check if venv is activated
# Should see (data_analytics_env) in prompt

# If not, activate:
E:\ELTStack_Projects\data_analytics_env\Scripts\activate

# Verify installation
pip list | findstr dbt
```

**Issue: BigQuery authentication failed**
```cmd
# 1. Check environment variable
echo %GOOGLE_APPLICATION_CREDENTIALS%

# 2. Verify file exists
dir "E:\ELTStack_Projects\data_analytics_env\*.json"

# 3. Test connection
dbt debug

# 4. If still failing, clear env var and retry
set GOOGLE_APPLICATION_CREDENTIALS=
dbt debug
# (dbt will use keyfile from profiles.yml)
```

**Issue: Model not found/updated**
```cmd
# dbt caches compiled files
dbt clean  # Removes target/ folder
dbt run    # Recompile and run
```

**Issue: Git shows files that should be ignored**
```cmd
# If files already tracked, remove from Git but keep locally
git rm --cached filename.json

# Verify .gitignore is working
git status  # Should not show ignored files

# If still showing, check .gitignore syntax
type .gitignore
```

---

## Session Statistics

**Total Time:** ~4.5 hours (11:45 AM - 4:30 PM IST with breaks)

**Time Breakdown:**
- Environment setup & troubleshooting: 1 hour
- Data exploration: 20 minutes
- Staging models (4): 45 minutes
- Dimension models (3): 40 minutes
- Fact model (1): 30 minutes
- Documentation & Git: 45 minutes

**Lines of Code Written:** ~450 SQL lines (8 models)

**Models Created:** 8
- 4 staging (views)
- 3 dimensions (tables)
- 1 fact (table)

**BigQuery Resources Used:**
- Storage: ~500 MB
- Query processing: ~20 GB
- Tables created: 4 (dims + fact)
- Views created: 4 (staging)

**Errors Resolved:** 6 major issues (documented above)

**Git Commits:** 1 (Initial .gitignore)

---

## Final Notes

### What Went Well ✅
- Clean separation of staging vs. marts layers
- Followed dbt naming conventions consistently
- All models run without errors on first/second try
- Good data quality filtering in staging layer
- Comprehensive documentation as we built

### What Could Be Improved 🔧
- Could have used `dbt init` interactive mode more smoothly (had to manually create profiles.yml)
- Spent extra time on Windows-specific environment setup (learn from this for future projects)
- Could have added tests earlier in the process
- Documentation could include ERD diagram (add in next session)

### Key Takeaways 💡
- **Start with exploration** before building models (5 queries saved us time)
- **Staging layer is crucial** for data quality (filter bad data early)
- **dbt ref() function** is powerful for building dependencies
- **Table materialization** for marts improves query performance
- **Git hygiene** is critical (never commit secrets!)
- **Windows path handling** requires extra attention (use forward slashes in YAML)

---

## Contact & Resources

### Helpful Links
- [dbt Documentation](https://docs.getdbt.com/)
- [BigQuery SQL Reference](https://cloud.google.com/bigquery/docs/reference/standard-sql/query-syntax)
- [TheLook E-Commerce Dataset](https://console.cloud.google.com/marketplace/product/bigquery-public-data/thelook-ecommerce)
- [dbt Best Practices](https://docs.getdbt.com/guides/best-practices)

### Next Session Preparation
- Review RFM segmentation methodology
- Prepare Plotly visualization templates
- Research customer cohort analysis techniques
- Plan business insights narrative

---

**Session completed successfully! 🎉**

**Next session: Build RFM model + visualizations + document insights**
