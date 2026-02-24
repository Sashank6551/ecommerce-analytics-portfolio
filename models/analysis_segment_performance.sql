/*
    Segment Performance Analysis
    
    Purpose: Track revenue contribution by customer segment over time
    Use: Identify which segments drive growth, spot trends
*/

WITH segment_monthly_revenue AS (
    SELECT 
        DATE_TRUNC(f.order_date, MONTH) AS order_month,
        r.customer_segment,
        
        -- Revenue metrics
        COUNT(DISTINCT f.order_id) AS total_orders,
        COUNT(DISTINCT f.user_id) AS active_customers,
        SUM(f.order_revenue) AS total_revenue,
        AVG(f.order_revenue) AS avg_order_value,
        
        -- Customer engagement
        SUM(f.num_of_item) AS total_items_sold
        
    FROM `portfolio-ecommerce-486905.analytics.fct_orders` f
    INNER JOIN `portfolio-ecommerce-486905.analytics.fct_rfm_segments` r
        ON f.user_id = r.user_id
    WHERE f.status = 'Complete'
        AND f.order_date >= '2023-01-01'  -- Focus on recent 2 years
    GROUP BY order_month, customer_segment
),

segment_totals AS (
    SELECT 
        order_month,
        SUM(total_revenue) AS month_total_revenue
    FROM segment_monthly_revenue
    GROUP BY order_month
)

SELECT 
    s.order_month,
    s.customer_segment,
    s.total_orders,
    s.active_customers,
    s.total_revenue,
    s.avg_order_value,
    s.total_items_sold,
    
    -- Revenue share
    ROUND(s.total_revenue / t.month_total_revenue * 100, 2) AS revenue_share_pct,
    
    -- Running totals
    SUM(s.total_revenue) OVER (
        PARTITION BY s.customer_segment 
        ORDER BY s.order_month
    ) AS cumulative_revenue

FROM segment_monthly_revenue s
LEFT JOIN segment_totals t
    ON s.order_month = t.order_month

ORDER BY s.order_month DESC, s.total_revenue DESC
