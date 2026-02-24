{{
    config(
        materialized='view'
    )
}}

WITH source AS (
    SELECT *
    FROM `bigquery-public-data.thelook_ecommerce.users`
    -- Filter to users created before 2025
    WHERE created_at < '2025-01-01'
),

renamed AS (
    SELECT
        -- Primary key
        id AS user_id,
        
        -- Personal info
        first_name,
        last_name,
        email,
        age,
        gender,
        
        -- Geographic
        state,
        city,
        country,
        postal_code,
        latitude,
        longitude,
        
        -- Acquisition
        traffic_source,
        
        -- Timestamps
        CAST(created_at AS TIMESTAMP) AS created_at,
        
        -- Metadata
        CURRENT_TIMESTAMP() AS _loaded_at
        
    FROM source
)

SELECT * FROM renamed