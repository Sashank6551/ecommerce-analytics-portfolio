{{
    config(
        materialized='view'
    )
}}

WITH source AS (
    SELECT *
    FROM `bigquery-public-data.thelook_ecommerce.products`
),

renamed AS (
    SELECT
        -- Primary key
        id AS product_id,
        
        -- Product attributes
        name AS product_name,
        category,
        department,
        brand,
        sku,
        
        -- Pricing
        cost,
        retail_price,
        
        -- Calculate margin
        ROUND((retail_price - cost) / NULLIF(retail_price, 0) * 100, 2) AS margin_percent,
        
        -- Distribution
        distribution_center_id,
        
        -- Metadata
        CURRENT_TIMESTAMP() AS _loaded_at
        
    FROM source
)

SELECT * FROM renamed