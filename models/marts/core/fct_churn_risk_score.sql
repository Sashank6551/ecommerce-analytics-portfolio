{{ config(materialized='table') }}

WITH customer_metrics AS (
    -- Get current state of each customer
    SELECT 
        user_id,
        MAX(order_date) AS last_order_date,
        COUNT(DISTINCT order_id) AS lifetime_orders,
        SUM(order_revenue) AS lifetime_revenue,
        MIN(order_date) AS first_order_date,
        
        -- Calculate days since last order
        DATE_DIFF((SELECT MAX(order_date) FROM {{ ref('fct_orders') }}), MAX(order_date), DAY) AS days_since_last_order,
        
        -- Average order frequency (days between orders)
        SAFE_DIVIDE(
            DATE_DIFF(MAX(order_date), MIN(order_date), DAY),
            COUNT(DISTINCT order_id) - 1
        ) AS avg_days_between_orders
        
    FROM {{ ref('fct_orders') }}
    WHERE status NOT IN ('Cancelled', 'Returned')
    GROUP BY user_id
),

recent_activity AS (
    -- Get last 90 days activity
    SELECT 
        user_id,
        COUNT(DISTINCT order_id) AS orders_last_90d,
        SUM(order_revenue) AS revenue_last_90d
    FROM {{ ref('fct_orders') }}
    WHERE order_date >= DATE_SUB((SELECT MAX(order_date) FROM {{ ref('fct_orders') }}), INTERVAL 90 DAY)
      AND status NOT IN ('Cancelled', 'Returned')
    GROUP BY user_id
),

historical_averages AS (
    -- Calculate historical activity excluding last 90 days
    SELECT 
        user_id,
        COUNT(DISTINCT order_id) / 
            NULLIF(DATE_DIFF(
                DATE_SUB((SELECT MAX(order_date) FROM {{ ref('fct_orders') }}), INTERVAL 90 DAY),
                MIN(order_date),
                DAY
            ), 0) * 90 AS avg_orders_per_90d_historical,
        
        SUM(order_revenue) /
            NULLIF(DATE_DIFF(
                DATE_SUB((SELECT MAX(order_date) FROM {{ ref('fct_orders') }}), INTERVAL 90 DAY),
                MIN(order_date),
                DAY
            ), 0) * 90 AS avg_revenue_per_90d_historical
            
    FROM {{ ref('fct_orders') }}
    WHERE order_date < DATE_SUB((SELECT MAX(order_date) FROM {{ ref('fct_orders') }}), INTERVAL 90 DAY)
      AND status NOT IN ('Cancelled', 'Returned')
    GROUP BY user_id
    HAVING DATE_DIFF(
        DATE_SUB((SELECT MAX(order_date) FROM {{ ref('fct_orders') }}), INTERVAL 90 DAY),
        MIN(order_date),
        DAY
    ) > 0  -- Exclude customers with <90 days history
),

risk_calculations AS (
    SELECT 
        cm.user_id,
        cm.last_order_date,
        cm.days_since_last_order,
        cm.lifetime_orders,
        cm.lifetime_revenue,
        cm.avg_days_between_orders,
        
        -- Recent activity
        COALESCE(ra.orders_last_90d, 0) AS orders_last_90d,
        COALESCE(ra.revenue_last_90d, 0) AS revenue_last_90d,
        
        -- Historical benchmarks
        COALESCE(ha.avg_orders_per_90d_historical, 0) AS avg_orders_per_90d_historical,
        COALESCE(ha.avg_revenue_per_90d_historical, 0) AS avg_revenue_per_90d_historical,
        
        -- COMPONENT 1: Recency Risk (0-100)
        CASE 
            WHEN cm.days_since_last_order <= 30 THEN 0
            WHEN cm.days_since_last_order <= 90 THEN 25
            WHEN cm.days_since_last_order <= 180 THEN 50
            WHEN cm.days_since_last_order <= 365 THEN 75
            ELSE 100
        END AS recency_risk_score,
        
        -- COMPONENT 2: Frequency Risk (0-100)
        CASE 
            WHEN ha.avg_orders_per_90d_historical = 0 THEN 0  -- New customers
            WHEN SAFE_DIVIDE(ra.orders_last_90d, ha.avg_orders_per_90d_historical) >= 1.0 THEN 0
            WHEN SAFE_DIVIDE(ra.orders_last_90d, ha.avg_orders_per_90d_historical) >= 0.75 THEN 25
            WHEN SAFE_DIVIDE(ra.orders_last_90d, ha.avg_orders_per_90d_historical) >= 0.5 THEN 50
            WHEN SAFE_DIVIDE(ra.orders_last_90d, ha.avg_orders_per_90d_historical) >= 0.25 THEN 75
            ELSE 100
        END AS frequency_risk_score,
        
        -- COMPONENT 3: Monetary Risk (0-100)
        CASE 
            WHEN ha.avg_revenue_per_90d_historical = 0 THEN 0  -- New customers
            WHEN SAFE_DIVIDE(ra.revenue_last_90d, ha.avg_revenue_per_90d_historical) >= 1.0 THEN 0
            WHEN SAFE_DIVIDE(ra.revenue_last_90d, ha.avg_revenue_per_90d_historical) >= 0.75 THEN 25
            WHEN SAFE_DIVIDE(ra.revenue_last_90d, ha.avg_revenue_per_90d_historical) >= 0.5 THEN 50
            WHEN SAFE_DIVIDE(ra.revenue_last_90d, ha.avg_revenue_per_90d_historical) >= 0.25 THEN 75
            ELSE 100
        END AS monetary_risk_score
        
    FROM customer_metrics cm
    LEFT JOIN recent_activity ra ON cm.user_id = ra.user_id
    LEFT JOIN historical_averages ha ON cm.user_id = ha.user_id
),

final_scores AS (
    SELECT 
        *,
        
        -- WEIGHTED COMPOSITE SCORE (0-100)
        ROUND(
            (recency_risk_score * 0.40) +
            (frequency_risk_score * 0.30) +
            (monetary_risk_score * 0.30),
            1
        ) AS churn_risk_score,
        
        -- RISK TIER CLASSIFICATION
        CASE 
            WHEN ROUND(
                (recency_risk_score * 0.40) +
                (frequency_risk_score * 0.30) +
                (monetary_risk_score * 0.30),
                1
            ) <= 25 THEN 'Low Risk'
            WHEN ROUND(
                (recency_risk_score * 0.40) +
                (frequency_risk_score * 0.30) +
                (monetary_risk_score * 0.30),
                1
            ) <= 50 THEN 'Medium Risk'
            WHEN ROUND(
                (recency_risk_score * 0.40) +
                (frequency_risk_score * 0.30) +
                (monetary_risk_score * 0.30),
                1
            ) <= 75 THEN 'High Risk'
            ELSE 'Critical Risk'
        END AS risk_tier,
        
        -- EARLY WARNING FLAGS
        CASE 
            WHEN days_since_last_order > (avg_days_between_orders * 2) 
            THEN TRUE ELSE FALSE 
        END AS flag_overdue_order,
        
        CASE 
            WHEN orders_last_90d = 0 AND lifetime_orders > 0 
            THEN TRUE ELSE FALSE 
        END AS flag_90d_inactive,
        
        CASE 
            WHEN revenue_last_90d < (avg_revenue_per_90d_historical * 0.5) 
            THEN TRUE ELSE FALSE 
        END AS flag_revenue_drop
        
    FROM risk_calculations
)

SELECT 
    user_id,
    last_order_date,
    days_since_last_order,
    lifetime_orders,
    lifetime_revenue,
    orders_last_90d,
    revenue_last_90d,
    
    -- Risk score components
    recency_risk_score,
    frequency_risk_score,
    monetary_risk_score,
    
    -- Final outputs
    churn_risk_score,
    risk_tier,
    
    -- Early warning flags
    flag_overdue_order,
    flag_90d_inactive,
    flag_revenue_drop,
    
    -- Metadata
    CURRENT_TIMESTAMP() AS scored_at
    
FROM final_scores
ORDER BY churn_risk_score DESC