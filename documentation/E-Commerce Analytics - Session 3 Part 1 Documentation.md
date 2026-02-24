# Project 1 - Session 3 Documentation
**E-Commerce Analytics Pipeline - Power BI Dashboard & Advanced Analytics**

---

## Session Information
- **Date:** February 12-13, 2026
- **Start Time:** ~6:00 PM IST (Feb 12)
- **End Time:** ~1:30 AM IST (Feb 13)
- **Duration:** ~10 hours total (8 hours Feb 12 + 2 hours Feb 13)
- **Status:** ✅ COMPLETE (100% complete)

---

## Session 3 Objectives & Results

### Planned Objectives:
1. Build Power BI dashboard (5 pages)
2. Create advanced SQL model (LTV or Churn scoring)
3. Leverage PL-300 certification prep synergy
4. Strengthen SQL pattern recognition

### Actual Results (So Far):
✅ Power BI connection to BigQuery established
✅ Star schema data model built and validated
✅ 8 DAX measures created with proper formatting
✅ Dashboard Page 1: Executive Summary (complete)
✅ Dashboard Page 2: RFM Segment Analysis (complete)
✅ Dashboard Pages 3-5: Complete (built in Sessions 3 Part 2 & 4)
✅ Advanced SQL model: Complete (Churn model in Session 3 Part 2)

---

## Deliverables Created

### 1. dbt Models

#### `fct_order_items.sql`
- **Location:** `models/marts/core/fct_order_items.sql`
- **Type:** Table materialization
- **Purpose:** Order line item level analysis with product details
- **Grain:** One row per product per order
- **Rows:** ~60,000-100,000 line items
- **Key Features:**
  - Product-level revenue and profitability
  - Profit margin calculation (sale_price - cost)
  - Discount percentage vs retail price
  - Item status tracking (returned, cancelled, completed)
  - Full date tracking (created, shipped, delivered, returned)

**Technical Learning:**
- Fixed column name mismatches (`num_items` → `total_items`)
- Used proper ref() syntax for staging models (`stg_thelook_*` not `stg_*`)
- Joined three sources: order_items + products + orders
- Calculated fields using CASE statements and ROUND functions

---

### 2. Power BI Data Model

#### Tables Imported:
1. `dim_customers` - Customer master data
2. `dim_products` - Product catalog
3. `dim_date` - Date dimension (continuous, 2019-2024)
4. `fct_orders` - Order-level transactions
5. `fct_order_items` - Line item-level transactions
6. `fct_rfm_segments` - Customer segmentation (from Session 2)

#### Relationships Configured:

**Star Schema Design:**
```
                    dim_date (Date Table)
                         |
                    (Active: 1:*)
                         |
        dim_products    fct_orders    dim_customers
        (1:*)           (Center)      (1:*)
             \             |              /
              \            |             /
               \     (1:*) |  (1:*)    /
                \          |          /
                 fct_order_items   fct_rfm_segments
                                   (1:1 to dim_customers)
```

**Relationship Details:**
- `dim_date[date_day]` → `fct_orders[order_date]` (Many-to-One, **Active**)
- `dim_date[date_day]` → `fct_order_items[order_date]` (Many-to-One, **Inactive**)
- `dim_customers[user_id]` → `fct_orders[user_id]` (One-to-Many)
- `dim_customers[user_id]` → `fct_order_items[user_id]` (One-to-Many)
- `dim_customers[user_id]` → `fct_rfm_segments[user_id]` (One-to-One)
- `dim_products[product_id]` → `fct_order_items[product_id]` (One-to-Many)

**Key Modeling Decisions:**
- ✅ dim_date marked as Date Table (enables time intelligence)
- ✅ Single active date relationship (order_date) - others inactive for USERELATIONSHIP
- ✅ Facts connect to dimensions, NOT to each other (proper star schema)
- ✅ Cross-filter direction: Single (dimension → fact)

---

### 3. Power Query Transformations

**Data Cleaning Applied:**
1. **Date/Time → Date conversion:**
   - `created_at`, `shipped_at`, `delivered_at`, `order_date`
   - Removed time component for performance
   - Matches dim_date granularity (date only)

2. **Decimal rounding:**
   - `profit_margin` rounded to 2 decimal places
   - Kept as decimal (0.89), not percentage (Power BI formats in visuals)

3. **NULL handling:**
   - Kept NULLs in `shipped_at` for cancelled orders (semantically correct)
   - Avoided fake dates (1900-01-01) that would break filters

**Learning:** Power BI handles NULLs gracefully in DAX - don't replace unnecessarily

---

### 4. DAX Measures Created

#### Measure 1: Total Revenue
```dax
Total Revenue = SUM(fct_orders[order_revenue])
```
- **Definition:** Sum of all order-level revenue
- **Grain:** Order level (fct_orders)
- **Format:** Currency ($), 0 decimals
- **Impact Interpretation:**
  - **Higher is better** - more revenue = business growth
  - **Benchmark:** Track month-over-month growth (target: 5-10% MoM)
  - **Use Case:** Executive KPI, trend analysis, forecasting

---

#### Measure 2: Total Orders
```dax
Total Orders = COUNTROWS(fct_orders)
```
- **Definition:** Count of distinct orders (transactions)
- **Grain:** Order level
- **Format:** Whole number, thousands separator
- **Impact Interpretation:**
  - **Higher is better** - more transactions = customer engagement
  - **Benchmark:** Compare to website traffic (conversion rate)
  - **Use Case:** Volume tracking, capacity planning, marketing campaign effectiveness

---

#### Measure 3: Average Order Value (AOV)
```dax
Avg Order Value = DIVIDE([Total Revenue], [Total Orders], 0)
```
- **Definition:** Revenue per transaction (basket size)
- **Grain:** Calculated from aggregates
- **Format:** Currency ($), 2 decimals
- **Impact Interpretation:**
  - **Higher is better** - larger baskets = more revenue per customer
  - **Benchmark:** Industry standard for e-commerce: $50-$150
  - **Current Value:** $86.39 (healthy, mid-range)
  - **Use Case:** 
    - Upsell/cross-sell effectiveness
    - Promotion impact (discounts may lower AOV but increase volume)
    - Customer segment comparison (Champions should have higher AOV)
  - **Optimization:** Target 10-15% increase through bundling, recommendations

---

#### Measure 4: Total Customers
```dax
Total Customers = DISTINCTCOUNT(fct_orders[user_id])
```
- **Definition:** Unique customers who placed at least one order
- **Grain:** Customer level (distinct count)
- **Format:** Whole number, thousands separator
- **Impact Interpretation:**
  - **Higher is better** - larger customer base = growth potential
  - **Benchmark:** 
    - Total customers: 49K
    - Compare to registered users (not all buy)
    - Repeat customer rate: Critical metric
  - **Use Case:**
    - Customer acquisition tracking
    - Retention rate calculation (returning / total)
    - Market penetration analysis

---

#### Measure 5: Product Revenue
```dax
Product Revenue = SUM(fct_order_items[sale_price])
```
- **Definition:** Sum of line item-level revenue (product grain)
- **Grain:** Line item level (fct_order_items)
- **Format:** Currency ($), 0 decimals
- **Impact Interpretation:**
  - **Should match Total Revenue** (validation check)
  - **Current Gap:** $5.86M (orders) vs $5.82M (items) = $40K discrepancy
  - **Use Case:** Product performance analysis, category breakdowns
  - **Issue Flagged:** Investigate revenue gap (likely cancelled/returned orders)

---

#### Measure 6: Customer Count
```dax
Customer Count = COUNTROWS(fct_rfm_segments)
```
- **Definition:** Count of customers in RFM segmentation table
- **Grain:** Customer level (one row per customer)
- **Format:** Whole number, thousands separator
- **Impact Interpretation:**
  - **Context-dependent** - varies by segment
  - **Segment Benchmarks:**
    - Champions: Want 10-15% of base (currently 8%)
    - Need Attention: Too high at 29% (retention issue)
    - At Risk: 14% requires urgent win-back campaigns
  - **Use Case:** 
    - Segment distribution analysis
    - Marketing campaign sizing
    - Resource allocation (customer support, outreach)

---

#### Measure 7: Avg LTV (Average Lifetime Value)
```dax
Avg LTV = AVERAGE(fct_rfm_segments[monetary_value])
```
- **Definition:** Average total revenue per customer (lifetime spend)
- **Grain:** Customer level
- **Format:** Currency ($), 2 decimals
- **Impact Interpretation:**
  - **Higher is better** - more valuable customers
  - **Segment Benchmarks:**
    - Champions: $190 (excellent, 5x Need Attention)
    - At Risk: $142 (high value at risk of churn - URGENT)
    - Need Attention: $68 (low, but large volume)
    - Hibernating: $27 (re-activation not worth cost)
  - **Use Case:**
    - Customer acquisition cost (CAC) justification (LTV:CAC ratio should be 3:1)
    - Segment prioritization (high LTV segments get premium service)
    - Churn impact calculation (losing one Champion = losing $190 LTV)
  - **Strategic Action:**
    - Move "Potential Loyalists" ($38) → "Loyal Customers" ($119) through engagement
    - Prevent "At Risk" ($142) from becoming "Hibernating" ($27)

---

#### Measure 8: Avg Recency
```dax
Avg Recency = AVERAGE(fct_rfm_segments[recency_days])
```
- **Definition:** Average days since last purchase per segment
- **Grain:** Customer level
- **Format:** Whole number (days)
- **Impact Interpretation:**
  - **Lower is better** - recent activity = engaged customers
  - **Segment Benchmarks:**
    - Champions: 160 days (should be lower - investigate)
    - New Customers: 168 days (recent acquires)
    - At Risk: 1,090 days (3 years! - critical churn)
    - Need Attention: 867 days (2.4 years - almost lost)
  - **Use Case:**
    - Churn prediction (>365 days = high risk)
    - Re-engagement campaign targeting
    - Seasonal pattern analysis
  - **Alert Thresholds:**
    - 90 days: Send reminder email
    - 180 days: Discount offer
    - 365+ days: Win-back campaign
    - 730+ days: Likely lost, remove from active marketing

---

### 5. Dashboard Pages

#### Page 1: Executive Summary ✅ COMPLETE

**Purpose:** High-level business health snapshot for executives and stakeholders

**Layout:**
- **Top Row:** 4 KPI cards (Total Revenue, Total Customers, Total Orders, Avg Order Value)
- **Middle Left:** Monthly Revenue Trend (line chart)
- **Middle Right:** Revenue by RFM Segment (bar chart)
- **Bottom Left:** Top 5 Products by Revenue (bar chart)
- **Bottom Right:** Orders by Status (donut chart)
- **Filters:** Duration slicer, Order Status slicer (button style)

**Key Insights Visible:**
1. **Revenue Growth:** Jan ($4M) → Dec ($6M) = 50% increase (strong growth trajectory)
2. **Order Completion Rate:** Only 25% (17K/68K) - INVESTIGATE (potential fulfillment issue)
3. **Top Products:** Nike Women's Pro Comfort leads ($11K revenue)
4. **Segment Performance:** Need Attention = largest revenue contributor (volume over value strategy)
5. **Order Status Mix:** 
   - Shipped: 20K (29%)
   - Complete: 17K (25%)
   - Returned: 7K (10% return rate - acceptable)
   - Cancelled: 10K (15% - high, investigate)

**Business Actions from Page 1:**
- Investigate 15% cancellation rate (payment issues? inventory?)
- Optimize shipping process (only 25% fully complete)
- Capitalize on Nike brand strength
- Shift focus from Need Attention volume to Champions value growth

---

#### Page 2: RFM Segment Analysis ✅ COMPLETE

**Purpose:** Deep dive into customer segmentation for targeted marketing strategies

**Layout:**
- **Top:** Segment slicer (8 segments, tile style)
- **Left Top:** Segment Overview Table (6 columns: segment, count, LTV, recency, freq, priority)
- **Left Bottom:** Customer Concentration Across RFM Score (heatmap matrix 5x5)
- **Right Top:** Customer Distribution by Segment (bar chart)
- **Right Bottom:** Average Lifetime Value by Segment (bar chart)

**Key Insights Visible:**

1. **Segment Distribution Issues:**
   - Need Attention: 4,518 customers (29%) - TOO HIGH
   - Champions: 1,227 customers (8%) - TOO LOW
   - **Action:** Conversion funnel from Need Attention → Promising → Champions

2. **Value Concentration:**
   - Champions: $190 avg LTV (2.8x overall average)
   - At Risk: $142 avg LTV + 1,090 days inactive = $308K revenue at risk
   - New Customers: $179 avg LTV (high potential - nurture immediately)
   - **Action:** Protect At Risk segment with aggressive win-back ($142 × 2,171 = $308K at stake)

3. **RFM Score Distribution (Heatmap):**
   - Relatively even spread across 5x5 grid (no extreme clustering)
   - Frequency scores concentrated at F=2-3 (moderate repeat purchase)
   - Recency spread indicates customers at all lifecycle stages
   - **Interpretation:** Healthy mix, but low F scores indicate one-time buyer problem persists

4. **Action Priorities Visible in Table:**
   - Priority 1: Can't Lose Them (not visible in charts - may be small segment)
   - Priority 2: At Risk (2,171 customers, 14% of base)
   - Priority 3: Champions (maintain, don't let slip to At Risk)
   - Priority 4: Potential Loyalists (2,299 customers - growth opportunity)

**Strategic Recommendations from Page 2:**

**Immediate (30 days):**
1. **At Risk Win-Back Campaign:** 
   - Target: 2,171 customers
   - Budget: $20 per customer (10% discount + email)
   - ROI: If recover 20% = 434 customers × $142 LTV = $61K revenue from $43K spend

2. **New Customer Onboarding:**
   - Target: 438 customers (recent acquires)
   - Strategy: 60-day engagement sequence
   - Goal: Move 50% to Potential Loyalists within 6 months

**Medium-term (60-90 days):**
3. **Potential Loyalist Conversion:**
   - Target: 2,299 customers
   - Current LTV: $38
   - Goal: Increase to $75 (2x) through repeat purchase incentives
   - Potential Revenue Lift: 2,299 × ($75 - $38) = $85K

4. **Need Attention Triage:**
   - Target: 4,518 customers (too many to resource)
   - Segment further: High potential (recent inactivity) vs Low potential (never engaged)
   - Re-allocate budget to high-ROI segments

---

## Technical Challenges & Resolutions

### Challenge 1: Column Name Mismatches in dbt Model (1 hour)
**Problem:** `fct_order_items` failed with "node not found" and "unrecognized name" errors

**Root Causes:**
1. Referenced `stg_order_items` instead of `stg_thelook_order_items`
2. Used `num_items` column which doesn't exist (actual: `total_items`)
3. Didn't check source table schemas before writing SQL

**Resolution:**
- Changed all refs to `stg_thelook_*` naming convention
- Updated `num_items` → `total_items` in joins
- Verified column names in BigQuery before re-running

**Lesson Learned:** ALWAYS use `view` tool to check source schemas FIRST before writing dbt models

**Prevention:** Created checklist:
1. `SELECT * FROM source LIMIT 5` to see actual columns
2. Document column names in comments
3. Use consistent naming conventions across staging models

**Time Cost:** 1 hour debugging (would have been 5 minutes with upfront schema check)

---

### Challenge 2: Power BI Relationship Ambiguity (30 min)
**Problem:** Multiple date relationships creating filter ambiguity

**Root Cause:**
- Both `fct_orders[order_date]` and `fct_order_items[order_date]` linking to `dim_date`
- Power BI only allows ONE active relationship between two tables
- Need both relationships for different analysis scenarios

**Resolution:**
- Made `fct_orders[order_date]` → `dim_date[date_day]` ACTIVE (primary)
- Made `fct_order_items[order_date]` → `dim_date[date_day]` INACTIVE
- Can activate inactive relationship in DAX using USERELATIONSHIP function when needed

**DAX Example for Using Inactive Relationship:**
```dax
Item Sales by Date = 
CALCULATE(
    [Product Revenue],
    USERELATIONSHIP(dim_date[date_day], fct_order_items[order_date])
)
```

**Lesson Learned:** Inactive relationships aren't "broken" - they're on-demand via DAX

---

### Challenge 3: RFM Scatter Plot Unreadable (20 min)
**Problem:** Scatter chart with 15K+ customer dots was cluttered and unusable

**Root Cause:**
- Tried to plot every individual customer (15,633 dots)
- Multiple segments overlapping at same R/F coordinates
- Power BI created pie-slice bubbles that obscured patterns

**Attempted Fix 1:** "Don't summarize" on axes
- **Result:** Error asking to remove user_id from Values field
- **Issue:** Can't show individual customers without aggregation creating chaos

**Attempted Fix 2:** Remove user_id, use CustomerCount for Size
- **Result:** Still cluttered with overlapping segments

**Final Solution:** Replace with Matrix (Heatmap)
- **Visual Type:** Matrix with conditional formatting
- **Rows:** Frequency Score (1-5)
- **Columns:** Recency Score (1-5)
- **Values:** CustomerCount
- **Formatting:** Color scale (white → dark blue)
- **Result:** Clean 5×5 grid showing customer concentration

**Lesson Learned:** 
- Not all data is suitable for scatter plots
- Heatmap matrices better for categorical score distributions
- Visual choice should match data grain and message

---

### Challenge 4: Revenue Discrepancy Between Tables ($40K gap)
**Problem:** 
- `Total Revenue` (from fct_orders): $5.86M
- `Product Revenue` (from fct_order_items): $5.82M
- Difference: $40K (0.7% variance)

**Investigation in BigQuery:**
```sql
SELECT 
  SUM(order_revenue) as fct_orders_total,
  (SELECT SUM(sale_price) FROM analytics.fct_order_items) as fct_items_total
FROM analytics.fct_orders;

-- Result: $5,858,225 vs $5,817,765 = $40,460 gap
```

**Possible Causes:**
1. **Cancelled orders:** Included in fct_orders but excluded from fct_order_items
2. **Returned items:** Different handling at order vs item level
3. **Aggregation logic:** order_revenue might include shipping/taxes not in sale_price
4. **Missing line items:** Some orders in fct_orders don't have corresponding fct_order_items rows

**Status:** FLAGGED for deeper investigation (Session 4)

**Temporary Workaround:**
- Use `Total Revenue` for order-level KPIs
- Use `Product Revenue` for product-level analysis
- Document the discrepancy in dashboard notes

**Proper Fix (for later):**
- Trace through dbt lineage to find aggregation difference
- Add dbt test: `sum(fct_orders.order_revenue) = sum(fct_order_items.sale_price)`
- Reconcile at source in staging models

---

### Challenge 5: Segment Definition Mismatch Between Tables (15 min)
**Problem:** Two different customer segmentation schemes in data model

**dim_customers segments:**
- (Blank)
- Never Purchased
- One-Time Buyer
- Repeat Customer

**fct_rfm_segments:**
- (Blank)
- At Risk
- Champions
- Hibernating
- Loyal Customers
- Need Attention
- New Customers
- Potential Loyalists
- Promising

**Root Cause:**
- `dim_customers` created in Session 1 with simple behavioral segments
- `fct_rfm_segments` created in Session 2 with advanced RFM methodology
- No merge/join between them

**Issue:** Created confusion when building slicers (which segment field to use?)

**Temporary Fix:**
- Use `fct_rfm_segments[customer_segment]` for all RFM analysis pages
- Don't use `dim_customers` segment field in this context

**Proper Fix (Architectural):**
**Merge RFM segments INTO dim_customers:**
```sql
-- Updated dim_customers.sql
WITH customers AS (
    SELECT * FROM {{ ref('stg_thelook_users') }}
),
rfm AS (
    SELECT * FROM {{ ref('fct_rfm_segments') }}
)
SELECT 
    c.*,
    r.customer_segment AS rfm_segment,
    r.rfm_score,
    r.recency_score,
    r.frequency_score,
    r.monetary_score,
    -- Keep old simple segment as "basic_segment" for comparison
    CASE 
        WHEN c.lifetime_orders = 0 THEN 'Never Purchased'
        WHEN c.lifetime_orders = 1 THEN 'One-Time Buyer'
        ELSE 'Repeat Customer'
    END AS basic_segment
FROM customers c
LEFT JOIN rfm r ON c.user_id = r.user_id
```

**Benefits of Merge:**
- ✅ Single source of truth (dim_customers is master)
- ✅ Simpler Power BI model (one customer dimension)
- ✅ No orphaned customers (LEFT JOIN catches all)
- ✅ Can compare simple vs advanced segmentation

**Decision:** Defer to Session 4 (1 hour refactor)

---

## Data Quality Issues Flagged

### Issue 1: Blank RFM Segments
**What:** Some customers appear as "(Blank)" in customer_segment visualizations

**Impact:** 
- Skews segment distribution charts
- Unknown number of customers unclassified
- Marketing can't target blank segment

**Likely Causes:**
- New customers added to system after RFM model last ran
- Customers with zero orders (never purchased)
- LEFT JOIN creating NULLs when customer exists in dim_customers but not fct_rfm_segments

**Temporary Workaround:**
- Filter out "(Blank)" in visual-level filters
- Hide blank segment in slicers

**Proper Fix:**
- Re-run `dbt run --select fct_rfm_segments` to capture all current customers
- Add dbt test: All customers in dim_customers should exist in fct_rfm_segments
- Schedule regular RFM refreshes (weekly or monthly)

**Priority:** Medium (affects visual cleanliness but not core insights)

---

### Issue 2: Low Order Completion Rate (25%)
**What:** Only 17K of 68K orders (25%) have status = "Complete"

**Status Distribution:**
- Complete: 17K (25%)
- Shipped: 20K (29%)
- Processing: 14K (21%)
- Cancelled: 10K (15%)
- Returned: 7K (10%)

**Questions:**
1. Why are Shipped orders not marked Complete?
2. Is 15% cancellation rate normal for this business?
3. Are Processing orders stuck in limbo?

**Possible Explanations:**
1. **Data freshness:** Orders in transit not yet updated to Complete
2. **Definition issue:** "Complete" may mean "delivered AND accepted" (excludes returns)
3. **Business process:** Orders stay in "Shipped" status until customer confirms receipt
4. **Data quality:** Status field not being updated properly in source system

**Impact:**
- Can't accurately calculate delivery times
- Revenue recognition might be delayed
- Customer satisfaction metrics unreliable

**Investigation Needed:**
```sql
-- Check status transitions
SELECT 
    status,
    COUNT(*) as order_count,
    AVG(TIMESTAMP_DIFF(delivered_at, shipped_at, DAY)) as avg_delivery_days,
    COUNT(CASE WHEN delivered_at IS NULL THEN 1 END) as missing_delivery_date
FROM analytics.fct_orders
GROUP BY status;
```

**Priority:** High (affects business metrics interpretation)

---

### Issue 3: High Recency Days for Champions
**What:** Champions segment has 160 days average recency (5+ months since last order)

**Expected:** Champions should be most recent purchasers (30-60 days)

**Actual:** 160 days suggests they haven't purchased in 5 months

**Implications:**
1. RFM scoring might be too weighted toward Frequency/Monetary
2. Champions at risk of churning (long time since purchase)
3. Definition of "Champion" may need adjustment

**Comparison:**
- Champions: 160 days (Should be lowest)
- New Customers: 168 days (Makes sense - just acquired)
- At Risk: 1,090 days (3 years - definitely at risk)

**Investigation Needed:**
- Review RFM scoring logic in `fct_rfm_segments.sql`
- Check if Recency score is being calculated correctly (lower days should = higher score)
- Consider adjusting segment thresholds

**Potential Fix:**
```sql
-- In fct_rfm_segments.sql, verify recency scoring:
6 - NTILE(5) OVER (ORDER BY recency_days) AS recency_score
-- This should give lower recency_days = higher score (5)
```

**Priority:** Medium (affects segment reliability for marketing)

---

## Patterns Learned (Technical)

### Power BI Patterns:

1. **Star Schema Layout for Clarity:**
   ```
   Dimensions (outer) → Facts (center)
   
   Ideal positioning:
   - dim_date: Top center
   - dim_customers: Right
   - dim_products: Left  
   - Facts: Bottom center
   ```
   **Why:** Shorter relationship lines, clearer data flow, professional appearance

2. **Active vs Inactive Relationships:**
   - ONE active relationship per table pair
   - Others marked inactive (dotted line)
   - Use USERELATIONSHIP in DAX to activate on-demand
   **Pattern:**
   ```dax
   Measure Name = 
   CALCULATE(
       [Base Measure],
       USERELATIONSHIP(DimTable[Key], FactTable[AlternateKey])
   )
   ```

3. **Date Table Requirements:**
   - Must be continuous (no gaps)
   - Mark as Date Table: Right-click → Mark as date table
   - Enables time intelligence (YTD, MTD, Prior Year comparisons)
   **Validation:**
   ```sql
   SELECT 
       COUNT(*) as actual_days,
       DATE_DIFF(MAX(date_day), MIN(date_day), DAY) + 1 as expected_days
   FROM dim_date
   -- actual_days should equal expected_days
   ```

4. **Measure Naming Conventions:**
   - No spaces in measure names makes DAX easier
   - Use PascalCase or snake_case consistently
   - Prefix with underscore for "helper" measures: `_CustomerCount`
   - Group related measures with prefixes: `Sales_Total`, `Sales_YTD`, `Sales_PY`

5. **Visual-Level Filters vs Report-Level Filters:**
   - **Visual-level:** Apply to one chart only (e.g., Top N filter)
   - **Page-level:** Apply to all visuals on page (e.g., date range)
   - **Report-level:** Apply to entire dashboard (rare, use slicers instead)
   **Best Practice:** Use slicers for user control, page filters for fixed context

---

### DAX Patterns:

1. **DIVIDE Instead of Division Operator:**
   ```dax
   -- WRONG (causes error if denominator = 0)
   Avg Order Value = [Total Revenue] / [Total Orders]
   
   -- RIGHT (returns 0 or BLANK if denominator = 0)
   Avg Order Value = DIVIDE([Total Revenue], [Total Orders], 0)
   ```

2. **Measure References in Measures:**
   ```dax
   -- Base measures
   Total Revenue = SUM(fct_orders[order_revenue])
   Total Orders = COUNTROWS(fct_orders)
   
   -- Derived measure referencing base measures
   Avg Order Value = DIVIDE([Total Revenue], [Total Orders], 0)
   ```
   **Why:** Changes to base measures automatically propagate

3. **Aggregation Functions:**
   - `SUM()` - Additive measures (revenue, cost, quantity)
   - `AVERAGE()` - Mean values (LTV, recency days)
   - `COUNTROWS()` - Row counts (orders, customers)
   - `DISTINCTCOUNT()` - Unique values (customer count, product count)
   **Choosing:** Consider what makes sense when filtered (SUM should add, AVERAGE should recalculate)

4. **Handling NULLs:**
   ```dax
   -- DAX treats BLANK() differently than 0
   Days to Ship = DATEDIFF([order_date], [shipped_at], DAY)
   -- Returns BLANK() if shipped_at is NULL (correct - not yet shipped)
   
   -- If you want 0 instead:
   Days to Ship = DATEDIFF([order_date], [shipped_at], DAY) + 0
   -- Adding 0 converts BLANK() to 0
   ```

---

### Data Modeling Patterns:

1. **Grain Definition is Critical:**
   ```
   fct_orders: One row per ORDER
   - order_id (unique)
   - order_revenue (total for order)
   
   fct_order_items: One row per LINE ITEM
   - order_id + product_id (composite key)
   - sale_price (individual item price)
   ```
   **Rule:** Choose grain FIRST, then decide what columns belong

2. **Fact vs Dimension Decision:**
   ```
   Fact table characteristics:
   - Transactional/event data
   - Many rows (high cardinality)
   - Additive measures (revenue, quantity)
   - Foreign keys to dimensions
   
   Dimension table characteristics:
   - Descriptive attributes
   - Fewer rows (relatively)
   - Text fields (names, categories)
   - Slowly changing (updates infrequent)
   ```
   **Edge Case:** `fct_rfm_segments` is technically a dimension (one row per customer, descriptive)
   - Named "fct" because it's derived/calculated
   - Should probably be merged into dim_customers

3. **Relationship Cardinality Rules:**
   - **One-to-Many (1:*)** - Dimension to Fact (most common)
   - **One-to-One (1:1)** - Dimension to Dimension (rare, e.g., fct_rfm_segments)
   - **Many-to-Many (*:*)** - Avoid! Use bridge table instead
   **Why Many-to-Many is problematic:** Creates ambiguous filter paths, incorrect aggregations

4. **Cross-Filter Direction:**
   - **Single:** Filter flows one way (Dimension → Fact)
   - **Both:** Filter flows bidirectionally (use sparingly, can cause performance issues)
   **Best Practice:** Keep Single unless you specifically need reverse filtering

---

### dbt Patterns:

1. **CTE Chain for Complex Logic:**
   ```sql
   WITH step1 AS (
       -- Get raw data
       SELECT * FROM {{ ref('stg_source') }}
   ),
   
   step2 AS (
       -- Apply transformations
       SELECT 
           col1,
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
   **Why:** Readable, debuggable (can select from intermediate CTEs during development)

2. **Config Block Patterns:**
   ```sql
   -- Compact (single config)
   {{ config(materialized='table') }}
   
   -- Expanded (multiple configs)
   {{
       config(
           materialized='table',
           description='Order line items fact table',
           partition_by={'field': 'order_date', 'data_type': 'date'},
           cluster_by=['user_id', 'product_id']
       )
   }}
   ```

3. **ref() for Dependencies:**
   ```sql
   -- WRONG: Hard-coded table name
   FROM `project.dataset.table`
   
   -- RIGHT: Use ref() for dbt models
   FROM {{ ref('staging_table_name') }}
   ```
   **Why:** dbt tracks lineage, enforces build order, enables testing

---

## Session Statistics

- **dbt Models Created:** 1 (fct_order_items)
- **Power BI Tables Imported:** 6 (facts + dimensions)
- **DAX Measures Created:** 8
- **Dashboard Pages Completed:** 2 of 5
- **Visualizations Built:** 10 (4 on Page 1, 4 on Page 2, 2 slicers)
- **Data Model Relationships:** 7
- **Power Query Transformations:** 3 types (date conversion, rounding, NULL handling)
- **Total Session Duration:** ~10 hours (split across 2 days)
- **Planned Duration:** 4-6 hours
- **Variance:** +4-6 hours (due to troubleshooting and learning)

---

## Next Session Planning (Session 3 Part 2)

### Deferred Items from This Session:
- Dashboard Pages 3, 4, 5 (Product, Cohort, Churn analysis)
- Advanced SQL model (LTV prediction OR Churn scoring)
- Revenue discrepancy investigation
- RFM segment merge into dim_customers

### Proposed Session 3 Part 2 Goals (Feb 13, 9 AM):

**Option C: Hybrid Approach (RECOMMENDED)**

**Phase 1: Complete Page 3 - Product Performance (2 hours)**
1. Revenue by Category/Brand (bar charts)
2. Profit Margin Analysis (scatter plot: price vs margin)
3. Product Performance Matrix (sales vs returns)
4. Return Rate by Category (bar chart)
5. Product slicers (category, brand)

**Phase 2: Advanced SQL Model Foundation (2 hours)**
Choose ONE:

**Option A: Customer LTV Prediction Model**
- Calculate historical LTV by cohort
- Identify LTV growth patterns (new → potential → loyal → champion)
- Build SQL-based prediction using moving averages
- Create fct_customer_ltv_prediction table

**Option B: Churn Risk Scoring Model**
- Calculate churn indicators (recency, order frequency decline, engagement drop)
- Build risk score (0-100) using weighted factors
- Classify into risk tiers (Low/Medium/High/Critical)
- Create fct_churn_risk_score table

**Phase 3: Wrap-up (30 min)**
- Git commit with documentation
- Test Power BI refresh
- Plan Session 4

---

## Timeline Status:
- **Project 1 Deadline:** February 23, 2026
- **Current Date:** February 13, 2026
- **Days Remaining:** 10 days
- **Session 3 Status:** 60% complete (2/5 dashboard pages + data model)
- **Buffer:** 10 days for Pages 3-5, advanced SQL model, polish, and publishing
- **Risk Level:** LOW (well ahead of schedule)

**Recommendation:** Proceed with Option C (hybrid) - balanced approach for maximum portfolio impact

---

## Key Insights & Business Value

### Customer Insights:
1. **Segmentation Imbalance:**
   - Need Attention (29%) too large, low value ($68 LTV)
   - Champions (8%) too small, high value ($190 LTV)
   - **Action:** Shift marketing spend to convert Need Attention → Promising → Champions

2. **At-Risk Revenue:**
   - 2,171 customers at risk ($142 avg LTV = $308K total)
   - Average 1,090 days since last order (3 years!)
   - **Action:** Immediate win-back campaign (20% recovery = $62K revenue)

3. **New Customer Opportunity:**
   - 438 new customers with $179 avg LTV (higher than champions!)
   - Only 168 days old on average
   - **Action:** Aggressive onboarding to lock in repeat purchases

### Product Insights (from Page 1):
1. **Nike Dominance:**
   - Top 5 products all premium brands (Nike, North Face)
   - Women's activewear category driving revenue
   - **Action:** Expand Nike SKUs, negotiate better wholesale terms

2. **Order Fulfillment Issues:**
   - 15% cancellation rate (10K orders lost)
   - Only 25% completion rate
   - **Action:** Investigate payment failures, inventory stockouts

### Revenue Insights:
1. **Strong Growth Trajectory:**
   - 50% revenue increase Jan → Dec 2024
   - AOV stable at $86 (healthy basket size)
   - **Concern:** Is growth from new customers or repeat purchases?

2. **Revenue Concentration:**
   - Need Attention + Promising = ~50% of revenue
   - Over-reliance on low-LTV segments
   - **Risk:** If these segments churn, major revenue loss

---

## Pattern Recap (Quick Reference)

### What I Learned This Session:

**Power BI Skills:**
1. **Star schema data modeling** - dimensions surround facts
2. **Active vs inactive relationships** - manage ambiguity with USERELATIONSHIP
3. **DAX measure creation** - DIVIDE for safety, measure references for DRY code
4. **Visual selection** - heatmap > scatter for categorical data
5. **Slicer best practices** - tile style for segments, filters for cleanup

**dbt Skills:**
1. **Schema validation first** - always check source columns before writing SQL
2. **Naming conventions matter** - stg_thelook_* vs stg_* caused failures
3. **CTE chains for clarity** - step1 → step2 → final pattern
4. **Config blocks** - expanded format for multiple parameters

**Data Modeling Concepts:**
1. **Grain definition** - order level vs line item level determines what's possible
2. **Fact vs dimension** - RFM segments should probably be in dim_customers
3. **Revenue reconciliation** - different grains require validation ($40K gap)
4. **Continuous date tables** - required for time intelligence

**Business Analysis:**
1. **Metrics interpretation** - higher LTV is better, but volume matters too
2. **Segment strategy** - balance value (Champions) vs volume (Need Attention)
3. **Churn prevention** - At Risk segment represents real dollars at stake
4. **Data quality impacts** - 25% completion rate could be real issue or data problem

---

## Files Created/Modified

### New Files:
```
models/marts/core/fct_order_items.sql
models/marts/core/schema_order_items.yml
ecommerce_dashboard_v2.pbix (Power BI file with 2 pages)
```

### BigQuery Tables:
```
portfolio-ecommerce-486905.analytics.fct_order_items (~60K-100K rows)
```

### Power BI Assets:
- 8 DAX measures
- 10 visualizations (4 Page 1, 4 Page 2, 2 slicers)
- 7 table relationships
- 3 Power Query transformations

---

## Personal Notes for Future Sessions

### What Worked Well:
- Starting with Executive Summary page (high-level → detail flow)
- Using slicers for interactivity (makes dashboard feel professional)
- Replacing unusable scatter plot with heatmap (visual selection based on data)
- Documenting issues as flagged items (prevents forgetting important discoveries)

### What to Improve:
- Check source schemas BEFORE writing dbt models (saves 1+ hour debugging)
- Validate revenue totals across tables EARLY (caught $40K gap late)
- Plan data model architecture upfront (RFM should have been in dim_customers from start)
- Time box troubleshooting (spent too long on scatter plot before pivoting)

### Questions for Deep Dive Thread:
1. When to use USERELATIONSHIP vs creating duplicate measures?
2. How to handle slowly changing dimensions (SCD Type 2) in Power BI?
3. What's the best way to reconcile revenue across different grain tables?
4. Should "calculated facts" like RFM be stored as separate tables or merged into dimensions?
5. How to optimize Power BI performance with large datasets (100K+ rows)?

---

## Conclusion

Session 3 Part 1 successfully delivered:
- ✅ Production-ready Power BI data model (star schema)
- ✅ 2 complete dashboard pages (Executive Summary, RFM Analysis)
- ✅ 8 DAX measures with business context
- ✅ Critical data quality issues identified and documented
- ✅ Foundation for advanced SQL modeling

**Key Achievement:** Transformed raw data and Session 2 RFM analysis into interactive, executive-ready dashboards with clear business recommendations.

**Next Steps:** Complete Page 3 (Product Performance) and build advanced SQL model (LTV or Churn) to round out technical portfolio.

**Status:** On track for Feb 23 deadline with 10-day buffer for polish and publishing.

---

**Session 3 Part 1 Complete: February 13, 2026 @ 1:30 AM IST**

---

## Wrap-Up Summary for Thread Continuity

### Quick Context Recap:
**Project:** E-commerce Analytics Portfolio (Project 1 of 3)  
**Goal:** Build end-to-end data pipeline for DA interview prep  
**Tech Stack:** BigQuery (data) + dbt (transform) + Power BI (viz) + SQL (analysis)  
**Timeline:** Feb 9-23, 2026 (currently Feb 13 - on schedule)

### Session 3 Progress:
**Completed (60%):**
- ✅ dbt: Built fct_order_items (line item grain, 60K+ rows)
- ✅ Power BI: Connected to BigQuery, star schema model, 7 relationships
- ✅ DAX: 8 measures (revenue, orders, customers, LTV, etc.)
- ✅ Dashboard Page 1: Executive Summary (4 KPIs + 4 charts)
- ✅ Dashboard Page 2: RFM Segment Analysis (table + heatmap + 2 bar charts)

**Pending (40%):**
- ⏳ Dashboard Page 3: Product Performance
- ⏳ Dashboard Page 4: Customer Cohort Analysis  
- ⏳ Dashboard Page 5: Churn Risk & Retention
- ⏳ Advanced SQL Model (LTV Prediction OR Churn Scoring)

### Data Quality Issues Flagged:
1. Revenue discrepancy: $5.86M (orders) vs $5.82M (items) = $40K gap
2. Segment mismatch: dim_customers has different segments than fct_rfm_segments
3. Blank segments: Some customers not classified in RFM
4. Low completion rate: Only 25% orders marked "Complete" (investigate)

### Key Metrics Defined:
- **Total Revenue ($5.86M):** Higher = better, track MoM growth
- **AOV ($86.39):** Higher = better, industry standard $50-$150
- **Total Customers (49K):** Higher = better, but retention matters more
- **Avg LTV by Segment:** Champions $190, Need Attention $68
- **Avg Recency:** Lower = better, Champions at 160 days (concerning)

### Actual Next Steps (Completed):
- ✅ Session 3 Part 2: Pages 3-4, Churn model (Feb 14)
- ✅ Session 4: Page 5, Publishing, Documentation (Feb 16)

### Resume Points:
- Power BI file saved: `ecommerce_dashboard_v2.pbix`
- Ready to build product analysis visualizations
- Decision needed: LTV prediction vs Churn scoring model
- 10 days buffer before Feb 23 deadline

### Questions to Answer in Next Session:
1. Which advanced SQL model? (LTV or Churn - both valuable)
2. Merge RFM into dim_customers or keep separate?
3. Investigate revenue gap now or defer to Session 4?
4. When to publish dashboard to Power BI Service?

**Status:** Strong progress, well ahead of schedule, ready for final push on Pages 3-5 and SQL modeling.
**NOTE:** This documentation was written mid-project (after Pages 1-2 complete).
Final status: All 5 pages built, churn model complete, published to Power BI Service.
See Session 3 Part 2 and Session 4 documentation for full completion details.
---
