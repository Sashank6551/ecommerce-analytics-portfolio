{{
    config(
        materialized='table'
    )
}}

WITH orders AS (
    SELECT * FROM {{ ref('stg_thelook_orders') }}
),

order_items AS (
    SELECT * FROM {{ ref('stg_thelook_order_items') }}
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
        -- Primary key
        o.order_id,
        
        -- Foreign keys (for joining to dimensions)
        o.user_id,
        CAST(o.created_at AS DATE) AS order_date, -- Links to dim_date
        
        -- Order attributes
        o.status,
        o.num_of_item,
        
        -- Timestamps
        o.created_at,
        o.shipped_at,
        o.delivered_at,
        o.returned_at,
        
        -- Calculated metrics from order items
        COALESCE(ot.total_items, 0) AS total_items,
        COALESCE(ot.order_revenue, 0) AS order_revenue,
        COALESCE(ot.avg_item_price, 0) AS avg_item_price,
        COALESCE(ot.min_item_price, 0) AS min_item_price,
        COALESCE(ot.max_item_price, 0) AS max_item_price,
        
        -- Derived flags
        CASE WHEN o.status = 'Complete' THEN 1 ELSE 0 END AS is_completed,
        CASE WHEN o.status = 'Cancelled' THEN 1 ELSE 0 END AS is_cancelled,
        CASE WHEN o.returned_at IS NOT NULL THEN 1 ELSE 0 END AS is_returned,
        
        -- Fulfillment metrics (in days)
        DATE_DIFF(CAST(o.shipped_at AS DATE), CAST(o.created_at AS DATE), DAY) AS days_to_ship,
        DATE_DIFF(CAST(o.delivered_at AS DATE), CAST(o.shipped_at AS DATE), DAY) AS days_to_deliver,
        DATE_DIFF(CAST(o.delivered_at AS DATE), CAST(o.created_at AS DATE), DAY) AS days_to_complete,
        
        -- Metadata
        CURRENT_TIMESTAMP() AS _loaded_at
        
    FROM orders o
    LEFT JOIN order_totals ot ON o.order_id = ot.order_id
)

SELECT * FROM joined