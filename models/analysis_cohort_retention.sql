/*
    Cohort Analysis - Customer Retention
    
    Purpose: Track how customers from each acquisition month behave over time
    Use: Measure retention rates, identify sticky cohorts
*/

WITH customer_cohorts AS (
    -- Identify each customer's first purchase month (cohort)
    SELECT 
        user_id,
        DATE_TRUNC(MIN(order_date), MONTH) AS cohort_month,
        MIN(order_date) AS first_order_date
    FROM `portfolio-ecommerce-486905.analytics.fct_orders`
    WHERE status = 'Complete'
    GROUP BY user_id
),

cohort_activity AS (
    -- Track each customer's orders by month
    SELECT 
        c.cohort_month,
        c.user_id,
        DATE_TRUNC(f.order_date, MONTH) AS activity_month,
        
        -- Calculate months since first order
        DATE_DIFF(
            DATE_TRUNC(f.order_date, MONTH), 
            c.cohort_month, 
            MONTH
        ) AS months_since_first_order,
        
        -- Metrics
        COUNT(DISTINCT f.order_id) AS orders_in_month,
        SUM(f.order_revenue) AS revenue_in_month
        
    FROM customer_cohorts c
    INNER JOIN `portfolio-ecommerce-486905.analytics.fct_orders` f
        ON c.user_id = f.user_id
    WHERE f.status = 'Complete'
        AND c.cohort_month >= '2023-01-01'  -- Focus on recent cohorts
    GROUP BY c.cohort_month, c.user_id, activity_month, months_since_first_order
),

cohort_size AS (
    -- Count unique customers in each cohort
    SELECT 
        cohort_month,
        COUNT(DISTINCT user_id) AS cohort_customers
    FROM customer_cohorts
    WHERE cohort_month >= '2023-01-01'
    GROUP BY cohort_month
),

cohort_retention AS (
    -- Calculate retention for each cohort-month combination
    SELECT 
        ca.cohort_month,
        ca.months_since_first_order,
        cs.cohort_customers,
        
        -- Active customers in this period
        COUNT(DISTINCT ca.user_id) AS active_customers,
        
        -- Retention rate
        ROUND(
            COUNT(DISTINCT ca.user_id) / cs.cohort_customers * 100, 
            2
        ) AS retention_rate_pct,
        
        -- Revenue metrics
        SUM(ca.orders_in_month) AS total_orders,
        SUM(ca.revenue_in_month) AS total_revenue,
        ROUND(AVG(ca.revenue_in_month), 2) AS avg_revenue_per_customer
        
    FROM cohort_activity ca
    INNER JOIN cohort_size cs
        ON ca.cohort_month = cs.cohort_month
    GROUP BY ca.cohort_month, ca.months_since_first_order, cs.cohort_customers
)

SELECT 
    cohort_month,
    months_since_first_order,
    cohort_customers,
    active_customers,
    retention_rate_pct,
    total_orders,
    total_revenue,
    avg_revenue_per_customer,
    
    -- Cumulative metrics
    SUM(total_revenue) OVER (
        PARTITION BY cohort_month 
        ORDER BY months_since_first_order
    ) AS cumulative_cohort_revenue

FROM cohort_retention

ORDER BY cohort_month DESC, months_since_first_order ASC
