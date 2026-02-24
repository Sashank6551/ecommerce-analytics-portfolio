{{
    config(
        materialized='view'
    )
}}

WITH source AS (
    SELECT *
    FROM `bigquery-public-data.thelook_ecommerce.orders`
    -- Filter to completed time period (exclude future test data)
    WHERE created_at < '2025-01-01'
),

renamed AS (
    SELECT
        -- Primary key
        order_id,
        
        -- Foreign keys
        user_id,
        
        -- Timestamps
        CAST(created_at AS TIMESTAMP) AS created_at,
        CAST(returned_at AS TIMESTAMP) AS returned_at,
        CAST(shipped_at AS TIMESTAMP) AS shipped_at,
        CAST(delivered_at AS TIMESTAMP) AS delivered_at,
        
        -- Order attributes
        status,
        num_of_item,
        
        -- Metadata
        CURRENT_TIMESTAMP() AS _loaded_at
        
    FROM source
)

SELECT * FROM renamed