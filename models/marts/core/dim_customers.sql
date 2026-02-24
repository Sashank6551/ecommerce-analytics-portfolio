{{
    config(
        materialized='table'
    )
}}

WITH users AS (
    SELECT * FROM {{ ref('stg_thelook_users') }}
),

customer_orders AS (
    SELECT
        user_id,
        MIN(created_at) AS first_order_date,
        MAX(created_at) AS last_order_date,
        COUNT(DISTINCT order_id) AS lifetime_orders
    FROM {{ ref('stg_thelook_orders') }}
    WHERE status IN ('Complete', 'Shipped', 'Processing')
    GROUP BY user_id
),

joined AS (
    SELECT
        -- Primary key
        u.user_id,
        
        -- Customer attributes
        u.first_name,
        u.last_name,
        u.email,
        u.age,
        u.gender,
        
        -- Geographic
        u.state,
        u.city,
        u.country,
        
        -- Acquisition
        u.traffic_source,
        u.created_at AS account_created_at,
        
        -- Order history
        COALESCE(o.first_order_date, TIMESTAMP('9999-12-31')) AS first_order_date,
        COALESCE(o.last_order_date, TIMESTAMP('1900-01-01')) AS last_order_date,
        COALESCE(o.lifetime_orders, 0) AS lifetime_orders,
        
        -- Customer segments
        CASE
            WHEN o.lifetime_orders IS NULL THEN 'Never Purchased'
            WHEN o.lifetime_orders = 1 THEN 'One-Time Buyer'
            WHEN o.lifetime_orders BETWEEN 2 AND 5 THEN 'Repeat Customer'
            WHEN o.lifetime_orders > 5 THEN 'Loyal Customer'
        END AS customer_segment,
        
        -- Metadata
        CURRENT_TIMESTAMP() AS _loaded_at
        
    FROM users u
    LEFT JOIN customer_orders o ON u.user_id = o.user_id
)

SELECT * FROM joined