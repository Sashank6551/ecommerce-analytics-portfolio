{{
    config(
        materialized='table'
    )
}}

WITH customer_first_order AS (
    -- Get each customer's first order date
    SELECT
        user_id,
        MIN(order_date) AS cohort_month,
        MIN(order_id) AS first_order_id
    FROM {{ ref('fct_orders') }}
    WHERE status IN ('Complete', 'Shipped')
    GROUP BY user_id
),

customer_orders AS (
    -- Get all orders with cohort assignment
    SELECT
        o.user_id,
        o.order_id,
        o.order_date,
        o.order_revenue,
        c.cohort_month,
        DATE_TRUNC(c.cohort_month, MONTH) AS cohort_month_start
    FROM {{ ref('fct_orders') }} o
    INNER JOIN customer_first_order c ON o.user_id = c.user_id
    WHERE o.status IN ('Complete', 'Shipped')
),

cohort_metrics AS (
    -- Calculate metrics per cohort and month-since-acquisition
    SELECT
        cohort_month_start,
        DATE_DIFF(
            DATE_TRUNC(order_date, MONTH),
            cohort_month_start,
            MONTH
        ) AS months_since_acquisition,
        COUNT(DISTINCT user_id) AS active_customers,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(order_revenue) AS cohort_revenue,
        AVG(order_revenue) AS avg_order_value
    FROM customer_orders
    GROUP BY 
        cohort_month_start,
        months_since_acquisition
),

cohort_sizes AS (
    -- Get initial cohort sizes (Month 0)
    SELECT
        cohort_month_start,
        COUNT(DISTINCT user_id) AS cohort_size
    FROM customer_orders
    GROUP BY cohort_month_start
),

final AS (
    SELECT
        m.cohort_month_start,
        m.months_since_acquisition,
        s.cohort_size,
        m.active_customers,
        m.total_orders,
        m.cohort_revenue,
        m.avg_order_value,
        -- Retention rate calculation
        ROUND(
            SAFE_DIVIDE(m.active_customers, s.cohort_size) * 100,
            2
        ) AS retention_rate_pct,
        -- Revenue per customer in cohort
        ROUND(
            SAFE_DIVIDE(m.cohort_revenue, s.cohort_size),
            2
        ) AS revenue_per_cohort_customer,
        CURRENT_TIMESTAMP() AS _loaded_at
    FROM cohort_metrics m
    INNER JOIN cohort_sizes s ON m.cohort_month_start = s.cohort_month_start
)

SELECT * FROM final
WHERE cohort_month_start >= '2023-01-01'  -- Focus on 2023-2024 cohorts
ORDER BY cohort_month_start, months_since_acquisition