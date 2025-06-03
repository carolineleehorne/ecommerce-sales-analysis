-- ============================================================
-- E-Commerce Sales Analysis
-- Author: Caroline Horne
-- Description: SQL analysis of order data to identify revenue
--              trends, top-performing products, regional
--              performance, and customer behavior patterns.
-- ============================================================


-- ============================================================
-- 1. TOTAL REVENUE OVERVIEW
-- ============================================================

-- Total revenue and order count for the full dataset
SELECT
    COUNT(order_id)                          AS total_orders,
    COUNT(DISTINCT customer_id)              AS unique_customers,
    ROUND(SUM(unit_price * quantity), 2)     AS total_revenue,
    ROUND(AVG(unit_price * quantity), 2)     AS avg_order_value
FROM orders
WHERE status = 'Completed';


-- ============================================================
-- 2. MONTHLY REVENUE TREND
-- ============================================================

-- Revenue by month to identify growth trends
SELECT
    TO_CHAR(order_date, 'YYYY-MM')           AS month,
    COUNT(order_id)                          AS orders,
    ROUND(SUM(unit_price * quantity), 2)     AS monthly_revenue,
    ROUND(AVG(unit_price * quantity), 2)     AS avg_order_value
FROM orders
WHERE status = 'Completed'
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY month;


-- ============================================================
-- 3. REVENUE BY CATEGORY
-- ============================================================

SELECT
    category,
    COUNT(order_id)                                                  AS total_orders,
    ROUND(SUM(unit_price * quantity), 2)                             AS total_revenue,
    ROUND(SUM(unit_price * quantity) * 100.0 / SUM(SUM(unit_price * quantity)) OVER (), 1) AS revenue_pct
FROM orders
WHERE status = 'Completed'
GROUP BY category
ORDER BY total_revenue DESC;


-- ============================================================
-- 4. TOP 5 PRODUCTS BY REVENUE
-- ============================================================

SELECT
    product,
    category,
    COUNT(order_id)                          AS units_sold,
    ROUND(SUM(unit_price * quantity), 2)     AS total_revenue,
    ROUND(AVG(unit_price), 2)                AS avg_unit_price
FROM orders
WHERE status = 'Completed'
GROUP BY product, category
ORDER BY total_revenue DESC
LIMIT 5;


-- ============================================================
-- 5. REGIONAL PERFORMANCE
-- ============================================================

SELECT
    region,
    COUNT(order_id)                          AS total_orders,
    COUNT(DISTINCT customer_id)              AS unique_customers,
    ROUND(SUM(unit_price * quantity), 2)     AS total_revenue,
    ROUND(AVG(unit_price * quantity), 2)     AS avg_order_value
FROM orders
WHERE status = 'Completed'
GROUP BY region
ORDER BY total_revenue DESC;


-- ============================================================
-- 6. CUSTOMER PURCHASE FREQUENCY
-- ============================================================

-- Classify customers by order frequency
WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(order_id)                      AS total_orders,
        ROUND(SUM(unit_price * quantity), 2) AS lifetime_value,
        MIN(order_date)                      AS first_order,
        MAX(order_date)                      AS last_order
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN total_orders >= 5 THEN 'High Value (5+ orders)'
        WHEN total_orders BETWEEN 3 AND 4 THEN 'Mid Value (3-4 orders)'
        ELSE 'Low Value (1-2 orders)'
    END                                      AS customer_segment,
    COUNT(customer_id)                       AS customer_count,
    ROUND(AVG(lifetime_value), 2)            AS avg_lifetime_value,
    ROUND(AVG(total_orders), 1)              AS avg_orders_per_customer
FROM customer_orders
GROUP BY customer_segment
ORDER BY avg_lifetime_value DESC;


-- ============================================================
-- 7. REPEAT CUSTOMER RATE
-- ============================================================

WITH customer_order_counts AS (
    SELECT
        customer_id,
        COUNT(order_id) AS total_orders
    FROM orders
    WHERE status = 'Completed'
    GROUP BY customer_id
)
SELECT
    COUNT(CASE WHEN total_orders > 1 THEN 1 END)       AS repeat_customers,
    COUNT(customer_id)                                  AS total_customers,
    ROUND(
        COUNT(CASE WHEN total_orders > 1 THEN 1 END) * 100.0
        / COUNT(customer_id), 1
    )                                                   AS repeat_rate_pct
FROM customer_order_counts;


-- ============================================================
-- 8. MONTH-OVER-MONTH REVENUE GROWTH (Window Function)
-- ============================================================

WITH monthly_revenue AS (
    SELECT
        TO_CHAR(order_date, 'YYYY-MM')       AS month,
        ROUND(SUM(unit_price * quantity), 2) AS revenue
    FROM orders
    WHERE status = 'Completed'
    GROUP BY TO_CHAR(order_date, 'YYYY-MM')
)
SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month)      AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month))
        * 100.0 / LAG(revenue) OVER (ORDER BY month), 1
    )                                        AS mom_growth_pct
FROM monthly_revenue
ORDER BY month;
