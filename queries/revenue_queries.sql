-- ============================================================
-- Revenue-Focused Queries
-- Author: Caroline Horne
-- Added: Expanded revenue analysis after initial exploration
-- ============================================================


-- Revenue breakdown by product and region combined
SELECT
    region,
    category,
    ROUND(SUM(unit_price * quantity), 2)     AS revenue,
    COUNT(order_id)                          AS orders
FROM orders
WHERE status = 'Completed'
GROUP BY region, category
ORDER BY region, revenue DESC;


-- Average order value trend by month
SELECT
    TO_CHAR(order_date, 'YYYY-MM')           AS month,
    ROUND(AVG(unit_price * quantity), 2)     AS avg_order_value,
    ROUND(MAX(unit_price * quantity), 2)     AS max_order_value,
    ROUND(MIN(unit_price * quantity), 2)     AS min_order_value
FROM orders
WHERE status = 'Completed'
GROUP BY TO_CHAR(order_date, 'YYYY-MM')
ORDER BY month;


-- High-value orders (above average order value)
WITH avg_order AS (
    SELECT AVG(unit_price * quantity) AS avg_val
    FROM orders
    WHERE status = 'Completed'
)
SELECT
    order_id,
    customer_id,
    order_date,
    product,
    region,
    ROUND(unit_price * quantity, 2)          AS order_value
FROM orders, avg_order
WHERE status = 'Completed'
  AND (unit_price * quantity) > avg_val
ORDER BY order_value DESC;
