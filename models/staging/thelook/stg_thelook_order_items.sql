{{
    config(
        materialized='view'
    )
}}

WITH source AS (
    SELECT *
    FROM `bigquery-public-data.thelook_ecommerce.order_items`
    -- Filter to order items created before 2025
    WHERE created_at < '2025-01-01'
),

renamed AS (
    SELECT
        -- Primary key
        id AS order_item_id,
        
        -- Foreign keys
        order_id,
        user_id,
        product_id,
        inventory_item_id,
        
        -- Item attributes
        status,
        sale_price,
        
        -- Timestamps
        CAST(created_at AS TIMESTAMP) AS created_at,
        CAST(shipped_at AS TIMESTAMP) AS shipped_at,
        CAST(delivered_at AS TIMESTAMP) AS delivered_at,
        CAST(returned_at AS TIMESTAMP) AS returned_at,
        
        -- Metadata
        CURRENT_TIMESTAMP() AS _loaded_at
        
    FROM source
    -- Exclude potential data quality issues (extremely low prices)
    WHERE sale_price >= 0.02
)

SELECT * FROM renamed