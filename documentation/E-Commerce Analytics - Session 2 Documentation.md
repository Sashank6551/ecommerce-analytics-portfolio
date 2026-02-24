# Project 1 - Session 2 Complete Documentation
**E-Commerce Analytics Pipeline - RFM Analysis & Insights**

---

## Session Information
- **Date:** February 10, 2026
- **Start Time:** 6:20 AM IST (delayed from planned 9:00 AM)
- **End Time:** 5:48 PM IST
- **Duration:** ~11.5 hours (with breaks)
- **Status:** ✅ COMPLETE

---

## Session 2 Objectives & Results

### Planned Objectives:
1. Build RFM segmentation model
2. Create analysis queries for insights
3. Generate Python visualizations
4. Document findings

### Actual Results:
✅ All objectives completed
✅ 4 bonus visualizations created
✅ Deep pattern analysis performed

---

## Deliverables Created

### 1. dbt Models

#### `fct_rfm_segments.sql`
- **Location:** `models/marts/core/fct_rfm_segments.sql`
- **Type:** Table materialization
- **Purpose:** Customer segmentation based on Recency, Frequency, Monetary analysis
- **Rows:** 15,633 customers across 8 segments
- **Key Features:**
  - Quintile scoring (1-5) using NTILE() window function
  - 10 customer segments with business logic
  - Action priority ranking for retention campaigns
  - Full customer lifecycle metrics

**Segments Created:**
1. Champions (1,227) - Best customers, $190 avg LTV
2. Loyal Customers (1,320) - Regular buyers, $119 avg LTV
3. Potential Loyalists (2,299) - Recent with growth potential, $38 avg LTV
4. At Risk (2,171) - Previously good, now declining, $142 avg LTV
5. Can't Lose Them - High spenders gone cold (included in action priority)
6. Hibernating (1,102) - Low activity, $27 avg LTV
7. Lost - Completely churned
8. New Customers (438) - Recent first-timers, $179 avg LTV
9. Promising (2,558) - Moderate engagement, $112 avg LTV
10. Need Attention (4,518) - Largest segment, low value, $68 avg LTV

#### `schema_rfm.yml`
- **Location:** `models/marts/core/schema_rfm.yml`
- **Purpose:** dbt documentation and data tests for RFM model
- **Tests Included:**
  - Unique and not_null constraints on user_id
  - Accepted values validation for customer_segment
  - Column-level documentation for all metrics

---

### 2. Analysis Queries

#### Query 1: Segment Performance Over Time
- **File:** `analysis_segment_performance.sql`
- **Purpose:** Track revenue contribution by segment month-over-month
- **Key Metrics:**
  - Total orders and active customers per segment
  - Revenue share percentage
  - Cumulative revenue trends
- **Time Range:** 2023-2024 (2 years)
- **Output:** 240+ rows (24 months × 10 segments)

**Key Findings:**
- Promising segment leads with 20-30% revenue share
- Champions underperforming at only 9-10% share despite highest LTV
- At Risk segment has minimal revenue (0.5-3%) confirming churn

#### Query 2: Cohort Retention Analysis
- **File:** `analysis_cohort_retention.sql`
- **Purpose:** Measure customer retention by acquisition month
- **Key Metrics:**
  - Retention rate percentage by months since first order
  - Cohort size and active customers
  - Revenue per customer over time
- **Time Range:** Jan 2023 - Dec 2024 cohorts
- **Output:** 244 cohort-month combinations

**Key Findings:**
- MASSIVE churn: 98-99% don't return after Month 1
- Small core (1-2%) becomes super loyal long-term
- Older cohorts (2023) show better cumulative revenue
- One-time buyer problem confirmed

#### Query 3: Product Performance by Segment
- **File:** `analysis_product_performance.sql`
- **Purpose:** Identify top products and categories per segment
- **Key Metrics:**
  - Top 10 products per segment by revenue
  - Revenue share within segment
  - Unique buyers per product
- **Output:** 81 products (top 10 × 8+ segments)

**Key Findings:**
- Outerwear dominates across all segments
- Champions prefer premium brands (North Face, Canada Goose, Mountain Hardwear)
- Price points vary 2-3x between segments
- Low product concentration = healthy diversification

---

### 3. Python Visualizations

#### `rfm_visualizations.py`
- **Location:** `ecommerce_analytics/rfm_visualizations.py`
- **Libraries Used:**
  - pandas (2.3.3)
  - plotly (6.5.2)
  - google-cloud-bigquery (3.40.0)
- **Outputs:** 4 interactive HTML files

**Visualization 1: Segment Distribution**
- **File:** `viz_1_segment_distribution.html`
- **Type:** Horizontal bar chart with color gradient
- **Insight:** Need Attention is largest (4,518) but lowest value; Champions are small (1,227) but highest value ($190 LTV)

**Visualization 2: Segment Metrics Overview**
- **File:** `viz_2_segment_metrics.html`
- **Type:** 4-panel dashboard (LTV, Orders, Recency, RFM Scores)
- **Insight:** Clear separation between high-value (Champions, New Customers) and low-value (Hibernating, Need Attention) segments

**Visualization 3: Revenue Trends**
- **File:** `viz_3_revenue_trends.html`
- **Type:** Multi-line time series (2023-2024)
- **Insight:** 
  - Promising segment leads revenue ($15-20K/month)
  - Champions growing steadily ($2K → $3K in 2024)
  - At Risk volatile and declining
  - New Customers ramping up ($5K → $8K)

**Visualization 4: RFM Score Heatmap**
- **File:** `viz_4_rfm_heatmap.html`
- **Type:** Recency vs Frequency heatmap
- **Insight:**
  - Dark red cluster at R=2, F=2 (550 customers) = Hibernating
  - Most customers stuck at low frequency (F=1-2) = one-time buyers
  - Champions corner (R=5, F=5) has only 406 customers

---

## Technical Challenges & Resolutions

### Challenge 1: Column Name Mismatches (6+ hours debugging)
**Problem:** RFM model failed with "column not found" errors
**Root Cause:** Assumed column names didn't match actual schema
**Resolution Process:**
1. `order_status` → `status` (15 min)
2. `customer_key` → `user_id` (30 min, 6 replacements)
3. `total_amount` → `order_revenue` (20 min, 2 replacements)
4. `customer_name/email` → `first_name/last_name/email` (30 min)

**Lesson Learned:** Always check source table schemas FIRST before writing joins
**Prevention:** Created checklist: `view` source tables → document columns → then write SQL

### Challenge 2: Revenue Chart Blank
**Problem:** Viz 3 showed no data
**Root Cause:** `DATE_SUB(CURRENT_DATE(), INTERVAL 12 MONTH)` filtered out historical data
**Resolution:** Changed filter to `>= '2023-01-01'` for 2-year window
**Time:** 5 minutes

### Challenge 3: BigQuery Storage Warning
**Problem:** Warning about missing `google-cloud-bigquery-storage` module
**Impact:** None - script auto-fell back to REST API
**Resolution:** Ignored (optional optimization library)

---

## Key Insights & Business Recommendations

### Customer Behavior Patterns:

1. **One-Time Buyer Problem (CRITICAL)**
   - 98-99% of customers don't return after first purchase
   - Only 1-2% become loyal long-term
   - **Action:** Implement aggressive Month 1 retention campaigns

2. **Revenue Concentration**
   - Mid-tier segments (Promising, New Customers) drive bulk revenue
   - Champions contribute only 9-10% despite highest per-customer value
   - **Action:** Balance strategy between volume (Promising) and value (Champions)

3. **Segment-Specific Opportunities**
   - **Can't Lose Them (Priority 1):** High-value churned customers - win-back campaign URGENT
   - **At Risk (Priority 2):** 2,171 customers at 1,090 days inactive - re-engagement needed
   - **Potential Loyalists (Priority 4):** 2,299 recent buyers - nurture to increase frequency
   - **New Customers:** High AOV ($179) - onboarding critical to convert to Champions

4. **Product Strategy**
   - Outerwear drives all segments
   - Premium brands resonate with Champions (North Face, Mountain Hardwear)
   - New Customers prefer recognizable brands (Nike, True Religion)
   - **Action:** Segment-specific product recommendations

---

## Data Quality Observations

### Strengths:
- Clean order data with minimal nulls
- Good segment distribution (no segment <400 customers)
- 2+ years of historical data for trend analysis

### Concerns:
- Jan 2024 revenue dip across all segments (seasonal or data issue?)
- Very low repeat purchase rate suggests potential data completeness issue OR genuine business problem
- "Need Attention" segment is 29% of customer base (largest) but unclear strategy

---

## Patterns Learned (Technical)

### SQL Patterns:
1. **CTEs for complex logic:**
   ```sql
   WITH step1 AS (...),
        step2 AS (...),
        final AS (...)
   SELECT * FROM final
   ```

2. **NTILE() for quintile scoring:**
   ```sql
   NTILE(5) OVER (ORDER BY metric) AS score
   6 - NTILE(5) OVER (ORDER BY recency_days) AS recency_score  -- Reverse for recency
   ```

3. **Window functions for running totals:**
   ```sql
   SUM(revenue) OVER (PARTITION BY segment ORDER BY month) AS cumulative_revenue
   ```

4. **Aliasing in JOINs:**
   ```sql
   FROM table_name alias_name
   JOIN another_table another_alias ON ...
   ```

### Python Patterns:
1. **BigQuery client initialization:**
   ```python
   from google.cloud import bigquery
   client = bigquery.Client(project=PROJECT_ID)
   df = client.query(query_string).to_dataframe()
   ```

2. **Plotly subplots for dashboards:**
   ```python
   from plotly.subplots import make_subplots
   fig = make_subplots(rows=2, cols=2)
   ```

3. **Color gradients for insights:**
   ```python
   marker=dict(color=values, colorscale='Blues', showscale=True)
   ```

---

## Files Modified/Created

### New Files:
```
models/marts/core/fct_rfm_segments.sql
models/marts/core/schema_rfm.yml
ecommerce_analytics/analysis_segment_performance.sql
ecommerce_analytics/analysis_cohort_retention.sql
ecommerce_analytics/analysis_product_performance.sql
ecommerce_analytics/rfm_visualizations.py
ecommerce_analytics/viz_1_segment_distribution.html
ecommerce_analytics/viz_2_segment_metrics.html
ecommerce_analytics/viz_3_revenue_trends.html
ecommerce_analytics/viz_4_rfm_heatmap.html
```

### BigQuery Tables:
```
portfolio-ecommerce-486905.analytics.fct_rfm_segments (15,633 rows)
```

---

## Session Statistics

- **dbt Models Created:** 1 (fct_rfm_segments)
- **Analysis Queries Written:** 3
- **Python Scripts Created:** 1
- **Visualizations Generated:** 4 interactive HTML files
- **Total Customers Analyzed:** 15,633
- **Customer Segments:** 8 primary segments
- **Data Time Range:** 2019-2024 (5 years, focused on 2023-2024 for analysis)
- **Total Session Duration:** ~11.5 hours (including debugging)
- **Planned Duration:** 4 hours
- **Variance:** +7.5 hours (due to column mismatch debugging)

---

## Next Session Planning (Session 3)

### Deferred Items:
- Deep dive into SQL mechanics (separate learning thread)
- Understanding metric calculations step-by-step
- Advanced cohort analysis (retention curves, LTV prediction)

### Proposed Session 3 Goals:
1. Build predictive model for customer churn
2. Create automated reporting (scheduled queries or dbt snapshots)
3. Dashboard setup (Looker Studio or Tableau)
4. Advanced segmentation (behavioral clustering)

### Timeline Status:
- **Project 1 Deadline:** February 23, 2025
- **Days Remaining:** 13 days
- **Session 2 Complete:** February 10, 2025
- **Buffer:** 7 days ahead of schedule for RFM completion
- **Next Session:** TBD (flexible based on other prep work)

---

## Pattern Recap (Quick Reference)

### What I Learned This Session:
1. **Always check schemas first** - saves hours of debugging
2. **NTILE() is powerful** - automatic quintile scoring without manual thresholds
3. **CTEs make complex SQL readable** - step-by-step logic building
4. **Window functions enable advanced metrics** - running totals, rankings, percentiles
5. **Plotly creates professional viz quickly** - interactive HTML with minimal code
6. **BigQuery + Python integration is smooth** - pandas DataFrames from SQL queries
7. **Segment analysis reveals business opportunities** - data → insights → action

### Code Patterns to Remember:
- JOIN with aliases: `FROM table t1 JOIN other t2 ON t1.id = t2.id`
- Quintile scoring: `NTILE(5) OVER (ORDER BY metric)`
- Cumulative sums: `SUM(x) OVER (PARTITION BY y ORDER BY z)`
- Python BigQuery: `client.query(sql).to_dataframe()`

---

## Personal Notes for Future Sessions

### What Worked Well:
- Breaking down work into phases (Model → Queries → Viz)
- Using CSV exports for quick data sharing (reduces screenshot clutter)
- Interactive visualizations more insightful than static tables
- Flexible timing (spreading work across day vs one sitting)

### What to Improve:
- Check source schemas BEFORE writing any SQL
- Create data dictionary at project start
- Estimate debugging time more realistically (2-3x initial estimate)
- Consider using dbt docs generate for automatic schema reference

### Questions for Deep Dive Thread:
1. How does `DATE_DIFF` work with `DATE_TRUNC` in cohort analysis?
2. Why use LEFT JOIN vs INNER JOIN for dim_customers?
3. How does NTILE distribute customers when counts aren't divisible by 5?
4. What's the difference between PARTITION BY and GROUP BY?
5. How does cumulative revenue calculation work with OVER clause?

---

## Conclusion

Session 2 successfully delivered a complete RFM segmentation framework with:
- ✅ Production-ready dbt model
- ✅ Actionable business insights
- ✅ Professional visualizations
- ✅ Foundation for future analytics

**Key Achievement:** Transformed raw e-commerce data into customer segments with clear action priorities, supported by visual evidence and SQL-driven analysis.

**Status:** Ready for Session 3 or parallel deep-dive learning on SQL mechanics.

---

**Session 2 Complete: February 10, 2025 @ 5:48 PM IST**
