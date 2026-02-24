{{
    config(
        materialized='table'
    )
}}

WITH products AS (
    SELECT * FROM {{ ref('stg_thelook_products') }}
),

product_performance AS (
    SELECT
        product_id,
        COUNT(DISTINCT order_id) AS times_ordered,
        SUM(sale_price) AS total_revenue,
        AVG(sale_price) AS avg_sale_price
    FROM {{ ref('stg_thelook_order_items') }}
    WHERE status IN ('Complete', 'Shipped')
    GROUP BY product_id
),

joined AS (
    SELECT
        -- Primary key
        p.product_id,
        
        -- Product attributes
        p.product_name,
        p.category,
        p.department,
        p.brand,
        p.sku,
        
        -- Pricing
        p.cost,
        p.retail_price,
        p.margin_percent,
        
        -- Performance metrics
        COALESCE(perf.times_ordered, 0) AS times_ordered,
        COALESCE(perf.total_revenue, 0) AS total_revenue,
        COALESCE(perf.avg_sale_price, 0) AS avg_sale_price,
        
        -- Product tiers based on performance
        CASE
            WHEN perf.total_revenue > 10000 THEN 'Top Seller'
            WHEN perf.total_revenue BETWEEN 1000 AND 10000 THEN 'Mid Performer'
            WHEN perf.total_revenue < 1000 THEN 'Low Performer'
            ELSE 'Never Sold'
        END AS product_tier,
        
        -- Metadata
        CURRENT_TIMESTAMP() AS _loaded_at
        
    FROM products p
    LEFT JOIN product_performance perf ON p.product_id = perf.product_id
)

SELECT * FROM joined