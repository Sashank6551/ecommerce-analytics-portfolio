{{
    config(
        materialized='table',
        tags=['analytics', 'rfm', 'segmentation']
    )
}}

/*
    RFM Segmentation Model
    
    Purpose: Segment customers based on Recency, Frequency, and Monetary value
    
    Segments:
    - Champions: Best customers (high R, F, M)
    - Loyal Customers: Regular high-value buyers
    - Potential Loyalists: Recent buyers with growth potential
    - At Risk: Previously good customers showing decline
    - Can't Lose Them: High-value customers gone cold
    - Hibernating: Low recent activity
    - Lost: Completely churned
*/

WITH analysis_date AS (
    -- Use the most recent order date as analysis snapshot
    SELECT MAX(order_date) AS snapshot_date
    FROM {{ ref('fct_orders') }}
),

customer_metrics AS (
    -- Calculate raw RFM metrics for each customer
    SELECT 
        f.user_id,
        
        -- Recency: Days since last order (lower is better)
        DATE_DIFF(a.snapshot_date, MAX(f.order_date), DAY) AS recency_days,
        
        -- Frequency: Total number of orders
        COUNT(DISTINCT f.order_id) AS frequency_count,
        
        -- Monetary: Total revenue generated
        SUM(f.order_revenue) AS monetary_value,
        
        -- Additional metrics for context
        AVG(f.order_revenue) AS avg_order_value,
        MIN(f.order_date) AS first_order_date,
        MAX(f.order_date) AS last_order_date,
        
        a.snapshot_date
        
    FROM {{ ref('fct_orders') }} f
    CROSS JOIN analysis_date a
    WHERE f.status = 'Complete'  -- Only completed orders
    GROUP BY f.user_id, a.snapshot_date
),

rfm_scores AS (
    -- Assign quintile scores (1-5) for each metric
    SELECT 
        user_id,
        recency_days,
        frequency_count,
        monetary_value,
        avg_order_value,
        first_order_date,
        last_order_date,
        snapshot_date,
        
        -- Recency Score: 5 = most recent, 1 = least recent
        -- NTILE creates 5 buckets, but we reverse since lower days = better
        6 - NTILE(5) OVER (ORDER BY recency_days) AS recency_score,
        
        -- Frequency Score: 5 = most orders, 1 = fewest orders
        NTILE(5) OVER (ORDER BY frequency_count) AS frequency_score,
        
        -- Monetary Score: 5 = highest spend, 1 = lowest spend
        NTILE(5) OVER (ORDER BY monetary_value) AS monetary_score
        
    FROM customer_metrics
),

rfm_segments AS (
    -- Assign customer segments based on RFM scores
    SELECT 
        *,
        CONCAT(
            CAST(recency_score AS STRING),
            CAST(frequency_score AS STRING), 
            CAST(monetary_score AS STRING)
        ) AS rfm_code,
        
        -- Segment assignment logic
        CASE
            -- Champions: Best customers across all dimensions
            WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 
                THEN 'Champions'
            
            -- Loyal Customers: Regular high-value buyers
            WHEN recency_score >= 3 AND frequency_score >= 4 AND monetary_score >= 3
                THEN 'Loyal Customers'
            
            -- Potential Loyalists: Recent buyers, can increase frequency/spend
            WHEN recency_score >= 4 AND frequency_score <= 3 AND monetary_score <= 3
                THEN 'Potential Loyalists'
            
            -- At Risk: Were good customers, now showing decline in recency
            WHEN recency_score <= 2 AND frequency_score >= 3 AND monetary_score >= 3
                THEN 'At Risk'
            
            -- Can't Lose Them: Top spenders gone cold - URGENT
            WHEN recency_score = 1 AND frequency_score >= 4 AND monetary_score >= 4
                THEN 'Can\'t Lose Them'
            
            -- Hibernating: Low activity across the board
            WHEN recency_score <= 2 AND frequency_score <= 2 AND monetary_score <= 2
                THEN 'Hibernating'
            
            -- Lost: Completely churned
            WHEN recency_score = 1 AND frequency_score <= 2 AND monetary_score <= 2
                THEN 'Lost'
            
            -- New Customers: Recent first-timers
            WHEN recency_score >= 4 AND frequency_score = 1
                THEN 'New Customers'
            
            -- Promising: Moderate engagement with growth potential
            WHEN recency_score >= 3 AND frequency_score >= 2 AND monetary_score >= 2
                THEN 'Promising'
            
            -- Need Attention: Declining metrics
            ELSE 'Need Attention'
        END AS customer_segment,
        
        -- Segment priority for action (1 = highest priority)
        CASE
            WHEN recency_score = 1 AND frequency_score >= 4 AND monetary_score >= 4 THEN 1  -- Can't Lose Them
            WHEN recency_score <= 2 AND frequency_score >= 3 AND monetary_score >= 3 THEN 2  -- At Risk
            WHEN recency_score >= 4 AND frequency_score >= 4 AND monetary_score >= 4 THEN 3  -- Champions
            WHEN recency_score >= 4 AND frequency_score <= 3 THEN 4  -- Potential Loyalists
            WHEN recency_score >= 3 AND frequency_score >= 4 THEN 5  -- Loyal Customers
            ELSE 6  -- Others
        END AS action_priority
        
    FROM rfm_scores
)

-- Final output with customer details
SELECT 
    s.user_id,
    c.first_name,
    c.last_name,
    c.email,
    c.country,
    c.city,
    
    -- RFM Metrics
    s.recency_days,
    s.frequency_count,
    s.monetary_value,
    s.avg_order_value,
    
    -- RFM Scores
    s.recency_score,
    s.frequency_score,
    s.monetary_score,
    s.rfm_code,
    
    -- Segmentation
    s.customer_segment,
    s.action_priority,
    
    -- Customer Lifecycle
    s.first_order_date,
    s.last_order_date,
    DATE_DIFF(s.last_order_date, s.first_order_date, DAY) AS customer_lifetime_days,
    
    -- Analysis metadata
    s.snapshot_date,
    CURRENT_TIMESTAMP() AS dbt_updated_at

FROM rfm_segments s
LEFT JOIN {{ ref('dim_customers') }} c
    ON s.user_id = c.user_id

ORDER BY s.action_priority, s.monetary_value DESC