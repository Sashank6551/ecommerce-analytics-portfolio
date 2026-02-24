{{
    config(
        materialized='table'
    )
}}

WITH date_spine AS (
    -- Generate dates from 2019-01-01 to 2024-12-31
    SELECT
        DATE_ADD(DATE('2019-01-01'), INTERVAL day_offset DAY) AS date_day
    FROM
        UNNEST(GENERATE_ARRAY(0, DATE_DIFF(DATE('2024-12-31'), DATE('2019-01-01'), DAY))) AS day_offset
),

date_attributes AS (
    SELECT
        date_day,
        
        -- Date parts
        EXTRACT(YEAR FROM date_day) AS year,
        EXTRACT(QUARTER FROM date_day) AS quarter,
        EXTRACT(MONTH FROM date_day) AS month,
        EXTRACT(WEEK FROM date_day) AS week_of_year,
        EXTRACT(DAY FROM date_day) AS day_of_month,
        EXTRACT(DAYOFWEEK FROM date_day) AS day_of_week,
        
        -- Formatted strings
        FORMAT_DATE('%B', date_day) AS month_name,
        FORMAT_DATE('%A', date_day) AS day_name,
        FORMAT_DATE('%Y-%m', date_day) AS year_month,
        FORMAT_DATE('%Y-Q%Q', date_day) AS year_quarter,
        
        -- Flags
        CASE WHEN EXTRACT(DAYOFWEEK FROM date_day) IN (1, 7) THEN TRUE ELSE FALSE END AS is_weekend,
        
        -- Metadata
        CURRENT_TIMESTAMP() AS _loaded_at
        
    FROM date_spine
)

SELECT * FROM date_attributes