# Session 4 - Lessons Learned & Complete Documentation
**E-Commerce Analytics Dashboard - Final Polish & Publishing**

---

## Session Information
- **Date:** February 16, 2026 (Sunday)
- **Start Time:** ~11:30 AM IST  
- **End Time:** ~8:00 PM IST (estimated)
- **Duration:** ~8.5 hours
- **Status:** ✅ COMPLETE (100%)

---

## Session 4 Objectives & Results

### Planned Objectives:
1. ✅ Polish dashboard formatting (colors, navigation, alignment)
2. ✅ Build Page 5: Cohort Analysis  
3. ✅ Publish to Power BI Service
4. ✅ Create comprehensive documentation

### Actual Results:
✅ Phase 1 - Dashboard standardization  
✅ Phase 2 - Page 5 with cohort model  
✅ Phase 3 - Published, PDF exported, screenshots  
✅ Phase 4 - Documentation (40,000+ words)

---

## Key Challenges & Solutions

### Challenge 1: dbt Full-Refresh on New Model

**Error:**
```
Unrecognized name: cohort_month_start at [63:9]
```

**Root Cause:**
- Used `--full-refresh` flag on first run  
- Model didn't exist yet to drop/refresh

**Solution:**
```bash
# CORRECT (first run):
dbt run --models fct_customer_cohorts

# Then subsequent runs:
dbt run --models fct_customer_cohorts --full-refresh
```

**Lesson:** `--full-refresh` is for REBUILDING, not creating new models

---

### Challenge 2: Column Reference Error in CTE

**Error:** Column `cohort_month_start` not found in `customer_first_order` CTE

**Root Cause:**
- `cohort_sizes` CTE queried `customer_first_order`  
- But `cohort_month_start` was created in `customer_orders` CTE  
- Wrong source CTE referenced

**Solution:** Changed source from `customer_first_order` to `customer_orders`

**Lesson:** CTE column availability depends on execution order

---

### Challenge 3: Power BI Slicer State Customization

**Issue:** Tried to customize selected/hover states for tile slicers

**Discovery:** Power BI doesn't expose all state customization options  

**Decision:** Accept default blue selection color (good enough vs. perfect)

**Lesson:** Know when to accept tool limitations vs. fight them

---

## Time Estimation Accuracy

| Phase | Planned | Actual | Variance |
|-------|---------|--------|----------|
| Phase 1: Polish | 90 min | 150-180 min | +67-100% |
| Phase 2: Page 5 | 120 min | 150-180 min | +25-50% |
| Phase 3: Publishing | 90 min | 45-60 min | -33-50% |
| Phase 4: Documentation | 90 min | 60 min | -33% |
| **Total** | **6 hours** | **8-8.5 hours** | **+33-42%** |

**Lesson:** Polish tasks take 1.5-2x planned time; publishing faster than expected

---

## Key Technical Learnings

### 1. Report vs. Dashboard (Power BI)

**Clarification:**
- **Report** = Multi-page interactive analysis (what was built)  
- **Dashboard** = Single-page pinned tiles (optional, not needed)

**For Portfolio:** Report IS your "dashboard" (casual language vs. technical term)

---

### 2. Color Palette - Theory vs. Reality

**Theory:** Use 5-7 colors, follow brand guidelines  
**Reality:** Data dictates needs (12 categories ≠ 7 colors)

**What Worked:**  
1. Start with semantic colors (green=good, red=bad)
2. Copy professional palettes as base
3. Test in context  
4. Accept imperfection

---

### 3. Documentation Timing

**Live Documentation (Sessions 1-3):**
- ✅ Captures exact errors/context  
- ❌ Adds 10-15% to build time

**Retroactive Documentation (Session 4):**
- ✅ Faster build time  
- ❌ Forgot minor details

**Optimal:** Quick notes during + detailed write-up after

---

## Deliverables Created

### Phase 1: Dashboard Polish
- ✅ Standardized KPI cards (fonts, colors, shadows)
- ✅ Navigation buttons (5 pages, active state indicator)
- ✅ Color palette defined (semantic colors applied)
- ✅ Slicer formatting (tile style, consistent styling)

### Phase 2: Page 5
- ✅ dbt model: `fct_customer_cohorts` (~150 SQL lines)
- ✅ 6 visuals (2 KPIs, line chart, heatmap, donut, bar chart)
- ✅ Key insight: 98% Month 1 churn revealed

### Phase 3: Publishing
- ✅ Published to Power BI Service  
- ✅ PDF export (5 pages, 2MB)
- ✅ Screenshots (5 PNG files, 1920×1080)
- ✅ Shareable link obtained

### Phase 4: Documentation
- ✅ `business_insights.md` (15,000 words, $265K opportunity)
- ✅ `technical_documentation.md` (8,000 words, implementation details)
- ✅ `session4_lessons_learned.md` (this file)

---

## SQL Patterns Learned

### Pattern 1: Date-Relative Calculations

```sql
-- WRONG (for historical data):
DATE_DIFF(CURRENT_DATE(), order_date, DAY)

-- CORRECT:
DATE_DIFF(
    (SELECT MAX(order_date) FROM table),
    order_date,
    DAY
)
```

### Pattern 2: CTE Dependency Management

```sql
-- Column created in CTE 2 is NOT available in CTE 1
-- Always query from CTE where column exists

cohort_sizes AS (
    SELECT cohort_month_start  -- Must exist in source
    FROM customer_orders  -- Has the column
    -- NOT FROM customer_first_order
)
```

---

## Portfolio Impact

### What Makes This Stand Out:

1. **End-to-End:** dbt + SQL + DAX + Power BI (full stack)
2. **Business Value:** $265K opportunity quantified  
3. **Technical Depth:** 5-CTE models, weighted scoring, star schema
4. **Documentation:** 40,000+ words (business + technical)
5. **Authenticity:** Real bugs documented (not polished tutorial)

### Interview Talking Points:

**30-second:**  
"Built end-to-end e-commerce pipeline identifying $265K revenue opportunity through churn analysis. 17 dbt models, star schema, predictive scoring, 5-page dashboard."

**2-minute technical deep dive:**  
"Churn model uses weighted composite scoring (Recency 40%, Frequency 30%, Monetary 30%). Critical bug: using CURRENT_DATE() made all customers appear churned. Fixed with subquery for dataset max date."

---

## Session Statistics

**Time:** 8-8.5 hours total  
**Code:** 150 SQL lines, 2 DAX measures  
**Docs:** 23,000+ words (business + technical)  
**Files:** 8 created/modified  

---

## Project Completion Checklist

### ✅ Technical:
- [x] 17 dbt models deployed
- [x] 5-page dashboard with 22 measures  
- [x] Published to Power BI Service
- [x] PDF + screenshots

### ✅ Documentation:
- [x] README with images  
- [x] Business insights report
- [x] Technical documentation
- [x] Session 1-4 logs

### ✅ GitHub:
- [x] Code committed
- [x] Repository public
- [x] README renders correctly

---

## Next Steps

**Optional Enhancements:**
- Demo video (2-3 min walkthrough)
- LinkedIn post with screenshots
- Blog post on medium.com

**Projects 2 & 3:**
- Apply lessons (time buffer, doc-as-you-go)
- Different tools (Python, Tableau)
- Focus on business impact

---

## Final Reflection

**Most Valuable Lesson:**  
Portfolio projects are about storytelling, not perfection.

- 98% churn finding > perfect color gradients
- $265K opportunity > "I built a model"
- Documented challenges > hiding mistakes
- Business impact > technical complexity

**For Interviews:**
- Technical depth matters (5-CTE SQL)
- Business impact matters more ($4.3M at risk)
- Explain trade-offs (why X over Y)
- Authenticity > polish

---

**Session 4 Complete: February 16, 2026 @ ~8:00 PM IST**

**Project 1: E-Commerce Analytics - COMPLETE ✅**
