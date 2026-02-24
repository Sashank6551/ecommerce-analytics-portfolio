# E-Commerce Analytics - Business Insights Report
**Data Period:** 2019-2024 (5 years)  
**Analysis Date:** February 16, 2026  
**Dashboard Pages:** 5 (Executive Summary, Segmentation, Products, Churn Risk, Cohorts)

---

## Executive Summary

This e-commerce business faces a **critical retention crisis** with 98% of customers making only one purchase. Despite generating $5.83M in revenue from 48K customers, the business model relies on continuous acquisition rather than customer lifetime value optimization.

**Key Findings:**
- 86% of customer base flagged as **Critical Churn Risk** ($4.3M revenue exposure)
- Average 6-month retention rate: **1.35%** (industry benchmark: 20-40%)
- Top revenue segment ("Need Attention") has **lowest LTV** ($66.81 avg)
- **New customers have higher LTV ($173)** than Champions ($193) - unusual pattern indicating acquisition quality over retention success

**Immediate Action Required:** Month 1 retention campaign to reduce 98% churn rate

---

## Detailed Findings by Area

### 1. Customer Retention Analysis

#### **The One-Time Buyer Crisis**

**Cohort Retention Metrics (2023 cohorts):**
- **Month 0 → Month 1:** 100% → 2-5% retention (-95% drop)
- **Month 1 → Month 2:** 2% → 0-1% retention (further 50% decline)
- **Month 6:** 1.35% average retention
- **Month 12:** <1% retention across all cohorts

**Visual Evidence:** Page 5 retention curve shows near-vertical drop after first purchase

**Root Causes (Hypotheses):**
1. **Poor onboarding:** No post-purchase engagement sequence
2. **Mismatch in expectations:** Product quality, shipping time, or pricing vs. perception
3. **One-time need fulfilled:** Seasonal purchases (outerwear focus) not repeat category
4. **Competitive switching:** Low barriers to trying competitors
5. **Missing loyalty program:** No incentive to return

**Business Impact:**
- **Customer Acquisition Cost (CAC) never recovered:** If CAC = $20-50, need 2-3 orders to break even
- **Marketing spend inefficiency:** 98% of acquisition spend yields one-time customers
- **Revenue volatility:** Dependent on constant new customer influx vs. stable base

---

#### **The 50/50 Paradox**

**Finding:** 50% of orders from new customers, 50% from returning customers (Page 5 donut chart)

**Analysis:**
- Total customers: 48K
- If 98% churn after 1 order → ~47K one-time buyers
- Remaining 2% (~1K customers) = super-loyal cohort generating 50% of orders
- **Average orders per loyal customer:** ~33 orders each (50% of 67K orders ÷ 1K customers)

**Insight:** Small group of highly engaged customers subsidizes poor overall retention

**Implication:** 
- **Protect the 2% at all costs** - they are 50x more valuable
- **Identify common traits** of loyal 2% to improve acquisition targeting
- **Prevent Champions from churning** (current avg recency: 164 days = 5+ months)

---

### 2. Customer Segmentation Insights

#### **RFM Segment Performance (Page 2)**

| Segment | Count | % of Base | Avg LTV | Avg Recency (Days) | Strategic Priority |
|---------|-------|-----------|---------|-------------------|-------------------|
| **Champions** | 1,208 | 8% | $193.25 | 164 | **HIGH** - Prevent churn |
| **New Customers** | 440 | 3% | $173.60 | 168 | **CRITICAL** - Onboard aggressively |
| **At Risk** | 2,159 | 14% | $141.27 | 1,090 | **URGENT** - Win-back campaign |
| **Loyal Customers** | 1,318 | 9% | $116.94 | 368 | **MEDIUM** - Maintain engagement |
| **Promising** | 2,472 | 16% | $108.74 | 320 | **MEDIUM** - Convert to Loyal |
| **Need Attention** | 4,402 | 29% | $66.81 | 861 | **LOW** - Triage/deprioritize |
| **Potential Loyalists** | 2,314 | 15% | $37.29 | 166 | **HIGH** - Nurture opportunity |
| **Hibernating** | 1,100 | 7% | $26.77 | 1,099 | **LOW** - Ignore/suppression list |

---

#### **Segment-Specific Recommendations**

**1. Champions (Priority 1: Retention)**
- **Issue:** 164-day avg recency (5+ months) for "best customers"
- **Goal:** Reduce recency to <90 days (monthly purchase cadence)
- **Tactics:**
  - VIP loyalty program (exclusive early access, free shipping)
  - Personalized product recommendations (based on purchase history)
  - Birthday/anniversary rewards
  - Dedicated customer service line
- **Success Metric:** Champions recency <90 days, 4+ orders/year

---

**2. New Customers (Priority 1: Onboarding)**
- **Issue:** $173 LTV but 168-day recency (likely churned after first order)
- **Goal:** 30% make 2nd purchase within 30 days (vs. current ~2%)
- **Tactics:**
  - **Day 3:** Post-purchase thank you + product care tips
  - **Day 7:** "Complete the look" email (complementary products)
  - **Day 14:** Feedback survey + 15% off next order
  - **Day 21:** Urgency email ("Your discount expires in 7 days")
  - **Day 28:** Last-chance email (if no 2nd order)
- **Success Metric:** Month 1 retention 30%, Month 3 retention 15%
- **ROI Calculation:**
  - Current: 440 new customers/month × 2% repeat = 9 repeat buyers
  - Target: 440 × 30% = 132 repeat buyers
  - Lift: 123 additional customers × $86 AOV = **$10,578/month** (+$127K/year)

---

**3. At Risk (Priority 1: Win-Back)**
- **Issue:** 2,159 customers, $141 avg LTV, 1,090 days inactive (3 years!)
- **Goal:** Reactivate 20% (432 customers)
- **Tactics:**
  - **Segment 1 (High LTV >$200):** Personal outreach, exclusive 25% off
  - **Segment 2 (Mid LTV $100-200):** Automated "We miss you" email, 20% off
  - **Segment 3 (Low LTV <$100):** One-time blast, 15% off, then suppress
- **Success Metric:** 20% reactivation rate
- **ROI Calculation:**
  - 432 reactivated × $86 AOV × 2 orders = **$74K revenue**
  - Campaign cost: 2,159 emails × $1 CPA = $2,159
  - **Net ROI: 3,300%** (74K / 2.2K)

---

**4. Potential Loyalists (Priority 2: Conversion)**
- **Issue:** 2,314 customers at $37 LTV (only 1-2 orders), recent activity (166 days)
- **Goal:** 2x LTV to $75 within 6 months
- **Tactics:**
  - Frequency incentive: "Buy 3, get 4th free" or loyalty points
  - Category expansion: Recommend adjacent products (outerwear → accessories)
  - Time-based promotions: "Flash sale - 48 hours only"
- **Success Metric:** 50% make 3+ orders, avg LTV $75
- **ROI Calculation:**
  - 2,314 × 50% success × ($75 - $37) incremental LTV = **$44K**

---

**5. Need Attention (Priority 3: Triage)**
- **Issue:** Largest segment (29%), lowest LTV ($66.81), 861 days recency
- **Analysis:** This segment is resource-intensive for low return
- **Recommendation:** 
  - **Don't invest heavily** in retention (low ROI)
  - **Passive nurture only:** Quarterly newsletter, no dedicated campaigns
  - **Focus budget on higher-value segments**
- **Exception:** If subset shows recent engagement (last 90 days), move to Potential Loyalists

---

### 3. Churn Risk Analysis (Page 4)

#### **Churn Model Results**

**Methodology:** Weighted composite score (0-100 scale)
- **Recency (40% weight):** Days since last order
- **Frequency (30% weight):** Order count decline vs. historical baseline
- **Monetary (30% weight):** Revenue decline vs. historical average

**Risk Distribution:**
| Risk Tier | Customers | % of Base | Avg Churn Score | Revenue at Risk |
|-----------|-----------|-----------|-----------------|-----------------|
| **Critical Risk** | 33,629 | 86% | 95.1 | $4.3M+ |
| **High Risk** | 3,932 | 10% | 66.3 | (included above) |
| **Medium Risk** | 148 | 0.4% | 36.9 | - |
| **Low Risk** | 1,309 | 3.4% | 8.6 | - |

**Interpretation:** 86% Critical Risk reflects dataset ending Dec 2024 (13 months ago from Feb 2026 analysis date). Most customers appear churned due to data staleness.

---

#### **Early Warning Indicators**

**Three flags identify at-risk customers BEFORE full churn:**

1. **Overdue Order Flag (34K customers)**
   - **Definition:** Days since last order > 2× average order frequency
   - **Example:** Customer historically orders every 60 days, now 120+ days elapsed
   - **Action:** Automated "Check-in" email at 1.5× frequency threshold

2. **Revenue Drop Flag (34K customers)**
   - **Definition:** Recent 90-day revenue <50% of historical 90-day average
   - **Example:** Was spending $200/quarter, now <$100/quarter
   - **Action:** Survey + targeted offer to understand decline

3. **90-Day Inactive Flag (3K customers)**
   - **Definition:** No orders in last 90 days but has prior purchase history
   - **Example:** Active buyer suddenly stops (life event, competitor switch)
   - **Action:** Win-back sequence (3 emails over 14 days)

**Flag Overlap:** Many customers trigger multiple flags (34K on 2-3 indicators = severe risk)

---

#### **High-Value At-Risk Customers (Top 20)**

**Profile:**
- Average LTV: **$1,200+** (10× overall average)
- Days inactive: **130-1,013 days** (4 months to 3 years)
- Total revenue exposure: **$25K+** from just 20 customers

**Immediate Action:**
- **Manual outreach** (not automated email)
- **Executive-level contact** (CEO/founder email)
- **Custom retention offer** (not generic discount)
- **Success rate target:** 25% (5 customers) = **$6K recovered revenue**

**Example Message Template:**
```
Subject: [Name], we noticed you've been away

Hi [Name],

I noticed you haven't ordered from us in [X] months, and as one of our top 
customers (you've spent over $1,200 with us!), I wanted to personally reach out.

Was there something we could have done better? I'd love to hear your feedback.

As a thank you for being a valued customer, here's 30% off your next order: [CODE]

Best,
[Founder Name]
```

---

### 4. Product Performance Insights (Page 3)

#### **Revenue Drivers**

**Top 5 Products (by revenue):**
1. **Nike Women's Pro Comfort** - $19.0K (0.3% of total revenue)
2. **The North Face Apex Bionic** - $19.0K
3. **Canada Goose Men's Thermal** - $8.2K
4. **adidas Women's Adifit Slides** - $6.4K
5. **Nobis Merideth Parka** - $6.4K

**Key Insights:**
- **Premium brands dominate:** Nike, North Face, Canada Goose, Nobis
- **Outerwear focus:** 4 of top 5 are jackets/parkas (seasonal dependency risk)
- **Low concentration:** Top product = 0.3% of revenue (healthy diversification)
- **Gender mix:** 3 women's, 2 men's products in top 5

---

#### **Category Performance**

**Revenue by Category (visual: Page 3 treemap):**
- **Outerwear:** Largest category (visual dominance in treemap)
- **Accessories:** High volume, lower price points
- **Active/Athleisure:** Strong Nike/adidas presence
- **Intimates/Underwear:** Smaller but consistent

**Profit Margin Analysis:**
- **Average margin:** 40-60% (retail_price - cost) ÷ retail_price
- **Highest margin categories:** Accessories, Intimates (lower COGS)
- **Lowest margin categories:** Outerwear (premium brand wholesale costs)

**Strategic Implications:**
1. **Expand winning brands:** Increase Nike/North Face SKU count
2. **Seasonal risk:** Outerwear dependency → need year-round categories
3. **Margin mix:** Balance high-margin accessories with high-revenue outerwear

---

#### **Product Performance Quadrants (Scatter Plot)**

**Stars (High Revenue + High Volume):**
- Premium outerwear items (North Face, Canada Goose)
- Best candidates for marketing spend, inventory investment

**Cash Cows (High Revenue + Low Volume):**
- Likely high-priced items with good margins
- Protect pricing, don't discount heavily

**Volume Drivers (Low Revenue + High Volume):**
- Accessories, basic apparel
- Use for acquisition, bundle with premium items

**Underperformers (Low Revenue + Low Volume):**
- **Recommendation:** Discontinue bottom 10% of SKUs
- **Free up:** Inventory capital, warehouse space, marketing focus

---

### 5. Cohort Analysis Insights (Page 5)

#### **Cohort Size Trends**

**Customer Acquisition by Month (2023):**
- **Q1 2023:** 14.0K customers/month (Jan peak)
- **Q2 2023:** 13.3K customers/month (May dip)
- **Q3 2023:** 12.0K customers/month (summer decline)
- **Q4 2023:** 11.4K customers/month (Oct low)

**Trend:** **-18% decline** in monthly acquisition (Jan → Oct 2023)

**Possible Causes:**
- Reduced marketing spend
- Seasonal pattern (winter → summer for outerwear)
- Increased competition
- Market saturation

**Action:** Investigate Q3-Q4 2023 marketing campaigns for drop-off cause

---

#### **Cohort Revenue Heatmap (Page 5)**

**Revenue Concentration by Month Since Acquisition:**

| Cohort Month | Month 0 Revenue | Month 1 Revenue | Month 6 Revenue | Lifetime Revenue |
|--------------|-----------------|-----------------|-----------------|------------------|
| 2023-01 | $61K | $1K | $476 | $680K |
| 2023-06 | $51K | $887 | $941 | - |
| 2023-12 | $61K | $1K | - | - |

**Key Pattern:** 
- **90-95% of lifetime revenue occurs in Month 0** (first purchase)
- **Month 1 = 1-2% of Month 0 revenue** (confirms 98% churn)
- **Month 6+ = negligible** (<1% of cohort still active)

**Interpretation:**
- Business operates on **acquisition model, not retention model**
- **Revenue predictability:** Low (dependent on new customer volume)
- **Customer value extraction:** Happening in first transaction only

---

## Revenue Opportunity Analysis

### **Total Addressable Opportunity: $1.2M+ annually**

#### **Opportunity 1: Reduce Month 1 Churn (98% → 70%)**
- **Current:** 440 new customers/month × 2% retention = 9 repeat buyers
- **Target:** 440 × 30% = 132 repeat buyers
- **Incremental customers:** 123/month × 12 = 1,476/year
- **Revenue lift:** 1,476 × $86 AOV = **$127K/year**
- **Confidence:** High (industry benchmarks achievable with basic email sequence)

---

#### **Opportunity 2: Reactivate At-Risk High-LTV Customers**
- **Target:** Top 2,159 At-Risk customers ($141 avg LTV)
- **Reactivation rate:** 20% (industry standard for win-back campaigns)
- **Customers recovered:** 432
- **Orders per recovered customer:** 2/year
- **Revenue:** 432 × 2 × $86 = **$74K/year**
- **Confidence:** Medium (depends on reason for churn)

---

#### **Opportunity 3: Protect Champions from Churn**
- **Current Champions:** 1,208 customers @ $193 avg LTV
- **Assumed annual churn:** 30% (360 customers lost)
- **Retention program cost:** $20/customer = $24K
- **Retention improvement:** 30% → 15% (save 180 customers)
- **Revenue saved:** 180 × $193 = **$35K/year**
- **Net benefit:** $35K - $24K = **$11K/year** (46% ROI)
- **Confidence:** High (loyalty programs proven effective)

---

#### **Opportunity 4: Convert Potential Loyalists**
- **Target:** 2,314 customers @ $37 LTV
- **Goal:** 50% increase LTV to $75 (2x)
- **Incremental revenue:** 1,157 × ($75 - $37) = **$44K/year**
- **Confidence:** Medium (requires sustained engagement)

---

#### **Opportunity 5: Expand Winning Products**
- **Current top 2 products:** $38K revenue
- **Expand SKU count:** +50% (e.g., 10 → 15 Nike styles)
- **Cannibalization risk:** Low (different sizes/colors)
- **Revenue lift:** $38K × 25% = **$9.5K/year**
- **Confidence:** High (proven demand)

---

**Total Annual Revenue Opportunity:**
- Month 1 retention: $127K
- At-Risk win-back: $74K
- Champions retention: $11K
- Potential Loyalist conversion: $44K
- Product expansion: $9.5K
- **TOTAL: $265K/year** (4.5% of current revenue)

**With aggressive execution (50% achievement): $132K incremental revenue**

---

## Recommended Action Plan

### **Phase 1: Quick Wins (30 days) - $50K potential**

**1.1 Launch Month 1 Retention Email Sequence**
- **Owner:** Marketing team
- **Timeline:** 2 weeks to build, launch Week 3
- **Budget:** $5K (ESP setup + copywriting)
- **Target:** All new customers (440/month)
- **Success metric:** 30% Month 1 retention (vs. 2% baseline)
- **Revenue impact:** $10K/month ($127K annualized)

**Email Sequence:**
```
Day 3:  Welcome + product care tips
Day 7:  "Complete the look" (cross-sell)
Day 14: Survey + 15% off
Day 21: Urgency reminder (discount expires)
Day 28: Last chance email
```

---

**1.2 High-Value At-Risk Manual Outreach**
- **Owner:** Customer success / Founder
- **Timeline:** Week 1-2
- **Budget:** $500 (time cost only)
- **Target:** Top 20 at-risk customers ($1,200+ LTV)
- **Success metric:** 25% reactivation (5 customers)
- **Revenue impact:** $6K one-time

**Template:** Personal email from founder (see example above)

---

**1.3 Champions VIP Program (MVP)**
- **Owner:** Marketing + Operations
- **Timeline:** Week 3-4
- **Budget:** $3K (setup + rewards)
- **Target:** 1,208 Champions
- **Benefits:**
  - Free shipping (threshold: $50)
  - Early access to new products (48-hour window)
  - Birthday discount (20% off)
- **Success metric:** Champions recency <90 days, 4+ orders/year
- **Revenue impact:** $11K/year (prevent 30% → 15% churn)

---

### **Phase 2: Foundation Building (60-90 days) - $100K potential**

**2.1 Automated Win-Back Campaign (At-Risk segment)**
- **Timeline:** Week 5-8
- **Target:** 2,159 At-Risk customers
- **3-tier approach:**
  - High LTV (>$200): 25% off + free shipping
  - Mid LTV ($100-200): 20% off
  - Low LTV (<$100): 15% off, then suppress
- **Revenue impact:** $74K/year

---

**2.2 Potential Loyalist Conversion Program**
- **Timeline:** Week 6-10
- **Target:** 2,314 Potential Loyalists
- **Tactics:**
  - Loyalty points (1 point = $1 spent, 100 points = $10 off)
  - Frequency incentive: "Buy 3, get 4th 50% off"
  - Category expansion: Recommend complementary products
- **Revenue impact:** $44K/year

---

**2.3 Product SKU Expansion**
- **Timeline:** Week 8-12
- **Target:** Increase Nike + North Face SKUs by 50%
- **Action:**
  - Analyze top sellers by size/color
  - Order additional variants
  - Test new styles (low inventory risk)
- **Revenue impact:** $9.5K/year

---

### **Phase 3: Optimization (90+ days) - $50K+ potential**

**3.1 Cohort-Specific Strategies**
- **Old cohorts (2023 Q1-Q2):** Deep discount re-activation (last attempt)
- **Mid cohorts (2023 Q3):** Standard win-back
- **New cohorts (2023 Q4):** Aggressive Month 2-3 retention
- **2024 cohorts:** Monitor for improvement vs. 2023 baseline

---

**3.2 Product Portfolio Optimization**
- **Discontinue:** Bottom 10% SKUs by revenue (<$500/year)
- **Free up:** Inventory capital for top performers
- **Test:** Bundles (outerwear + accessories) for AOV lift

---

**3.3 Customer Feedback Loop**
- **Exit survey:** For customers who haven't ordered in 90 days
- **Goal:** Understand churn reasons (product, price, service, competition)
- **Use insights:** Inform product development, marketing messaging

---

## Success Metrics & KPIs

### **Monthly Dashboard (track progress)**

| Metric | Baseline | Month 1 Target | Month 3 Target | Month 6 Target |
|--------|----------|----------------|----------------|----------------|
| **Month 1 Retention Rate** | 2% | 15% | 25% | 30% |
| **6-Month Retention Rate** | 1.35% | 2% | 5% | 10% |
| **Champions Avg Recency** | 164 days | 140 days | 120 days | 90 days |
| **At-Risk Reactivations** | 0 | 50 | 150 | 300 |
| **Avg Customer LTV** | $122 | $130 | $145 | $160 |
| **Revenue from Repeat Customers** | 50% | 52% | 56% | 60% |

---

### **North Star Metrics (12-month goals)**

1. **Customer Lifetime Value:** $122 → $160 (+31%)
2. **Repeat Purchase Rate:** 2% → 30% (Month 1)
3. **Customer Retention Cost Ratio:** LTV:CAC from 2:1 → 4:1
4. **Revenue from Existing Customers:** 50% → 60%

---

## Risks & Mitigations

### **Risk 1: Email Fatigue**
- **Concern:** Aggressive email cadence drives unsubscribes
- **Mitigation:**
  - A/B test frequency (3-day vs. 7-day intervals)
  - Segment by engagement (reduce frequency for low openers)
  - Always provide value (not just promotions)

### **Risk 2: Discount Dependency**
- **Concern:** Customers wait for discounts, eroding margins
- **Mitigation:**
  - Vary incentives (free shipping, loyalty points, early access)
  - Time-box offers (48-hour flash sales)
  - Tier discounts by segment (Champions get perks, not discounts)

### **Risk 3: Low Reactivation Response**
- **Concern:** At-Risk customers don't return despite outreach
- **Mitigation:**
  - Test multiple offer levels (15%, 20%, 25%)
  - Survey non-responders (why didn't they return?)
  - Accept some segments are permanently churned (move to suppression)

### **Risk 4: Seasonal Revenue Dependency**
- **Concern:** Outerwear focus limits year-round sales
- **Mitigation:**
  - Expand into non-seasonal categories (accessories, active)
  - Pre-season campaigns (buy winter coats in summer at discount)
  - Geographic expansion (sell winter gear to Southern Hemisphere in Q2-Q3)

---

## Conclusion

This e-commerce business has a **$265K annual revenue opportunity** by addressing its critical retention gap. The current model—98% one-time buyers with 50% of revenue from a tiny 2% loyal cohort—is unsustainable and leaves significant value on the table.

**Three strategic pivots required:**

1. **Shift from acquisition-only to retention-first** mindset
2. **Implement systematic Month 1 onboarding** to break the one-purchase curse
3. **Protect and grow the loyal 2%** who drive half of all orders

**Immediate priorities:**
- ✅ Launch Month 1 retention email sequence (30 days)
- ✅ Manually outreach to top 20 at-risk customers (14 days)
- ✅ Start Champions VIP program (30 days)

**Success will be measured by:**
- Month 1 retention: 2% → 30% (within 6 months)
- 6-month retention: 1.35% → 10%
- Customer LTV: $122 → $160

With disciplined execution, this business can achieve **$132K+ incremental revenue in Year 1** (conservative 50% plan achievement) and build a sustainable, retention-driven growth model.

---

**Report prepared by:** [D Sashank Aravindh]  
**Date:** February 16, 2026  
**Dashboard:** [Link to Power BI report](https://app.powerbi.com/links/h_9oLO6Nq4?ctid=3944c393-ac9e-47c6-9e62-7f3eebc94b8f&pbi_source=linkShare&bookmarkGuid=02a2b736-cf9c-495f-a089-89a5669c72cb) | [Download PDF](outputs/ecommerce_dashboard_portfolio.pdf))  
**Technical Documentation:** [Link to technical_documentation.md]
