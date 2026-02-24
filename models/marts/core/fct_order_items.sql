{{ config(materialized='table') }}

WITH order_items AS (
    SELECT
        order_id,
        product_id,
        user_id,
        inventory_item_id,
        sale_price,
        created_at,
        status,
        returned_at,
        shipped_at,
        delivered_at
    FROM {{ ref('stg_thelook_order_items') }}
),

products AS (
    SELECT
        product_id,
        product_name,
        category,
        brand,
        department,
        retail_price,
        cost
    FROM {{ ref('dim_products') }}
),

orders AS (
    SELECT
        order_id,
        user_id,
        order_date,
        status AS order_status,
        total_items
    FROM {{ ref('fct_orders') }}
),

final AS (
    SELECT
        -- Primary Keys
        oi.order_id,
        oi.product_id,
        oi.user_id,
        oi.inventory_item_id,
        
        -- Order Context
        o.order_date,
        o.order_status,
        o.total_items AS total_items_in_order,
        
        -- Product Details
        p.product_name,
        p.category,
        p.brand,
        p.department,
        
        -- Pricing & Profitability
        oi.sale_price,
        p.retail_price,
        p.cost,
        oi.sale_price - p.cost AS profit_margin,
        CASE 
            WHEN p.retail_price > 0 
            THEN ROUND((oi.sale_price - p.retail_price) / p.retail_price * 100, 2)
            ELSE 0
        END AS discount_percentage,
        
        -- Status & Dates
        oi.status AS item_status,
        oi.created_at,
        oi.shipped_at,
        oi.delivered_at,
        oi.returned_at,
        
        -- Flags
        CASE WHEN oi.returned_at IS NOT NULL THEN TRUE ELSE FALSE END AS is_returned,
        CASE WHEN oi.status = 'Complete' THEN TRUE ELSE FALSE END AS is_completed,
        CASE WHEN oi.status = 'Cancelled' THEN TRUE ELSE FALSE END AS is_cancelled
        
    FROM order_items oi
    LEFT JOIN products p ON oi.product_id = p.product_id
    LEFT JOIN orders o ON oi.order_id = o.order_id
)

SELECT * FROM final
