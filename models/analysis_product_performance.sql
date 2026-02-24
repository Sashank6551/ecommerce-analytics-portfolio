/*
    Product Performance by Customer Segment
    
    Purpose: Identify which products/categories resonate with each segment
    Use: Targeted product recommendations, inventory planning
*/

WITH segment_product_sales AS (
    SELECT 
        r.customer_segment,
        p.product_name,
        p.category,
        p.brand,
        p.department,
        
        -- Sales metrics
        COUNT(DISTINCT oi.order_id) AS total_orders,
        SUM(oi.sale_price) AS total_revenue,
        AVG(oi.sale_price) AS avg_sale_price,
        SUM(1) AS total_units_sold,  -- Count of order items
        
        -- Customer metrics
        COUNT(DISTINCT f.user_id) AS unique_buyers
        
    FROM `portfolio-ecommerce-486905.analytics.fct_rfm_segments` r
    INNER JOIN `portfolio-ecommerce-486905.analytics.fct_orders` f
        ON r.user_id = f.user_id
    INNER JOIN `portfolio-ecommerce-486905.analytics.stg_thelook_order_items` oi
        ON f.order_id = oi.order_id
    INNER JOIN `portfolio-ecommerce-486905.analytics.dim_products` p
        ON oi.product_id = p.product_id
    WHERE f.status = 'Complete'
        AND f.order_date >= '2023-01-01'
    GROUP BY r.customer_segment, p.product_name, p.category, p.brand, p.department
),

segment_totals AS (
    -- Total revenue per segment for calculating share
    SELECT 
        customer_segment,
        SUM(total_revenue) AS segment_total_revenue
    FROM segment_product_sales
    GROUP BY customer_segment
),

ranked_products AS (
    SELECT 
        s.customer_segment,
        s.product_name,
        s.category,
        s.brand,
        s.department,
        s.total_orders,
        s.total_revenue,
        s.avg_sale_price,
        s.total_units_sold,
        s.unique_buyers,
        
        -- Revenue share within segment
        ROUND(s.total_revenue / t.segment_total_revenue * 100, 2) AS revenue_share_pct,
        
        -- Rank products within each segment
        ROW_NUMBER() OVER (
            PARTITION BY s.customer_segment 
            ORDER BY s.total_revenue DESC
        ) AS revenue_rank
        
    FROM segment_product_sales s
    INNER JOIN segment_totals t
        ON s.customer_segment = t.customer_segment
)

-- Return top 10 products per segment
SELECT 
    customer_segment,
    product_name,
    category,
    brand,
    department,
    total_orders,
    total_revenue,
    avg_sale_price,
    total_units_sold,
    unique_buyers,
    revenue_share_pct,
    revenue_rank

FROM ranked_products
WHERE revenue_rank <= 10  -- Top 10 per segment

ORDER BY customer_segment, revenue_rank
