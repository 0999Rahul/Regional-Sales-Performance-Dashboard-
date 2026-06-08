-- ============================================================
--   SALES DASHBOARD - SQL ANALYSIS QUERIES
--   Dataset: European Sales Data (2015-2018)
--   Tables: orders, returns, people, target
-- ============================================================

-- ============================================================
-- STEP 1: CREATE TABLES
-- ============================================================

CREATE TABLE orders (
    order_id        VARCHAR(50),
    order_date      DATE,
    ship_date       DATE,
    ship_mode       VARCHAR(50),
    customer_id     VARCHAR(50),
    customer_name   VARCHAR(100),
    segment         VARCHAR(50),
    city            VARCHAR(100),
    state           VARCHAR(100),
    country         VARCHAR(100),
    region          VARCHAR(50),
    product_id      VARCHAR(50),
    category        VARCHAR(50),
    sub_category    VARCHAR(50),
    product_name    VARCHAR(255),
    sales           DECIMAL(10,2),
    quantity        INT,
    discount        DECIMAL(5,2),
    profit          DECIMAL(10,2)
);

CREATE TABLE returns (
    order_id  VARCHAR(50),
    returned  VARCHAR(10)
);

CREATE TABLE people (
    region  VARCHAR(50),
    person  VARCHAR(100)
);

CREATE TABLE target (
    category      VARCHAR(50),
    year          INT,
    sales_target  DECIMAL(10,2)
);

-- ============================================================
-- STEP 2: BASIC EXPLORATION
-- ============================================================

-- Total number of orders
SELECT COUNT(DISTINCT order_id) AS total_orders
FROM orders;

-- Date range of the dataset
SELECT 
    MIN(order_date) AS earliest_order,
    MAX(order_date) AS latest_order
FROM orders;

-- Total Sales, Profit, Quantity
SELECT 
    ROUND(SUM(sales), 2)    AS total_sales,
    ROUND(SUM(profit), 2)   AS total_profit,
    SUM(quantity)            AS total_quantity,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_pct
FROM orders;

-- ============================================================
-- STEP 3: SALES & PROFIT ANALYSIS
-- ============================================================

-- Q1: Year-wise Sales and Profit
SELECT 
    YEAR(order_date)         AS year,
    ROUND(SUM(sales), 2)     AS total_sales,
    ROUND(SUM(profit), 2)    AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_pct
FROM orders
GROUP BY YEAR(order_date)
ORDER BY year;

-- Q2: Monthly Sales Trend (all years combined)
SELECT 
    MONTH(order_date)        AS month,
    ROUND(SUM(sales), 2)     AS total_sales,
    ROUND(SUM(profit), 2)    AS total_profit
FROM orders
GROUP BY MONTH(order_date)
ORDER BY month;

-- Q3: Sales and Profit by Category
SELECT 
    category,
    ROUND(SUM(sales), 2)    AS total_sales,
    ROUND(SUM(profit), 2)   AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_pct
FROM orders
GROUP BY category
ORDER BY total_sales DESC;

-- Q4: Sales and Profit by Sub-Category
SELECT 
    sub_category,
    ROUND(SUM(sales), 2)    AS total_sales,
    ROUND(SUM(profit), 2)   AS total_profit,
    ROUND(SUM(profit) / SUM(sales) * 100, 2) AS profit_margin_pct
FROM orders
GROUP BY sub_category
ORDER BY total_profit DESC;

-- Q5: Top 10 Most Profitable Products
SELECT 
    product_name,
    category,
    ROUND(SUM(sales), 2)    AS total_sales,
    ROUND(SUM(profit), 2)   AS total_profit
FROM orders
GROUP BY product_name, category
ORDER BY total_profit DESC
LIMIT 10;

-- Q6: Bottom 10 Loss-Making Products
SELECT 
    product_name,
    category,
    ROUND(SUM(sales), 2)    AS total_sales,
    ROUND(SUM(profit), 2)   AS total_profit
FROM orders
GROUP BY product_name, category
ORDER BY total_profit ASC
LIMIT 10;

-- ============================================================
-- STEP 4: REGIONAL ANALYSIS
-- ============================================================

-- Q7: Sales and Profit by Region
SELECT 
    region,
    ROUND(SUM(sales), 2)    AS total_sales,
    ROUND(SUM(profit), 2)   AS total_profit,
    COUNT(DISTINCT order_id) AS total_orders
FROM orders
GROUP BY region
ORDER BY total_sales DESC;

-- Q8: Sales by Country
SELECT 
    country,
    ROUND(SUM(sales), 2)    AS total_sales,
    ROUND(SUM(profit), 2)   AS total_profit
FROM orders
GROUP BY country
ORDER BY total_sales DESC;

-- Q9: Top 10 Cities by Sales
SELECT 
    city,
    country,
    ROUND(SUM(sales), 2)    AS total_sales,
    ROUND(SUM(profit), 2)   AS total_profit
FROM orders
GROUP BY city, country
ORDER BY total_sales DESC
LIMIT 10;

-- Q10: Regional Manager Performance (joining People table)
SELECT 
    p.person        AS manager,
    p.region,
    ROUND(SUM(o.sales), 2)   AS total_sales,
    ROUND(SUM(o.profit), 2)  AS total_profit
FROM orders o
JOIN people p ON o.region = p.region
GROUP BY p.person, p.region
ORDER BY total_sales DESC;

-- ============================================================
-- STEP 5: CUSTOMER & SEGMENT ANALYSIS
-- ============================================================

-- Q11: Sales by Customer Segment
SELECT 
    segment,
    ROUND(SUM(sales), 2)    AS total_sales,
    ROUND(SUM(profit), 2)   AS total_profit,
    COUNT(DISTINCT customer_id) AS total_customers
FROM orders
GROUP BY segment
ORDER BY total_sales DESC;

-- Q12: Top 10 Customers by Sales
SELECT 
    customer_name,
    customer_id,
    segment,
    ROUND(SUM(sales), 2)    AS total_sales,
    ROUND(SUM(profit), 2)   AS total_profit
FROM orders
GROUP BY customer_name, customer_id, segment
ORDER BY total_sales DESC
LIMIT 10;

-- Q13: Number of Unique Customers per Year
SELECT 
    YEAR(order_date)                AS year,
    COUNT(DISTINCT customer_id)     AS unique_customers
FROM orders
GROUP BY YEAR(order_date)
ORDER BY year;

-- ============================================================
-- STEP 6: SHIPPING ANALYSIS
-- ============================================================

-- Q14: Sales by Ship Mode
SELECT 
    ship_mode,
    COUNT(DISTINCT order_id)    AS total_orders,
    ROUND(SUM(sales), 2)        AS total_sales
FROM orders
GROUP BY ship_mode
ORDER BY total_orders DESC;

-- Q15: Average Shipping Days by Ship Mode
SELECT 
    ship_mode,
    ROUND(AVG(DATEDIFF(ship_date, order_date)), 1) AS avg_ship_days
FROM orders
GROUP BY ship_mode
ORDER BY avg_ship_days;

-- ============================================================
-- STEP 7: DISCOUNT IMPACT ANALYSIS
-- ============================================================

-- Q16: Effect of Discount on Profit
SELECT 
    CASE 
        WHEN discount = 0         THEN 'No Discount'
        WHEN discount <= 0.10     THEN '1-10%'
        WHEN discount <= 0.20     THEN '11-20%'
        WHEN discount <= 0.30     THEN '21-30%'
        ELSE 'Above 30%'
    END                          AS discount_range,
    COUNT(*)                     AS total_orders,
    ROUND(SUM(sales), 2)         AS total_sales,
    ROUND(SUM(profit), 2)        AS total_profit
FROM orders
GROUP BY discount_range
ORDER BY total_profit DESC;

-- ============================================================
-- STEP 8: RETURNS ANALYSIS
-- ============================================================

-- Q17: Total Returned Orders
SELECT COUNT(*) AS total_returns
FROM returns
WHERE returned = 'Yes';

-- Q18: Return Rate by Category
SELECT 
    o.category,
    COUNT(DISTINCT o.order_id)  AS total_orders,
    COUNT(DISTINCT r.order_id)  AS returned_orders,
    ROUND(COUNT(DISTINCT r.order_id) * 100.0 / COUNT(DISTINCT o.order_id), 2) AS return_rate_pct
FROM orders o
LEFT JOIN returns r ON o.order_id = r.order_id AND r.returned = 'Yes'
GROUP BY o.category
ORDER BY return_rate_pct DESC;

-- Q19: Return Rate by Region
SELECT 
    o.region,
    COUNT(DISTINCT o.order_id)  AS total_orders,
    COUNT(DISTINCT r.order_id)  AS returned_orders,
    ROUND(COUNT(DISTINCT r.order_id) * 100.0 / COUNT(DISTINCT o.order_id), 2) AS return_rate_pct
FROM orders o
LEFT JOIN returns r ON o.order_id = r.order_id AND r.returned = 'Yes'
GROUP BY o.region
ORDER BY return_rate_pct DESC;

-- ============================================================
-- STEP 9: TARGET vs ACTUAL ANALYSIS
-- ============================================================

-- Q20: Actual Sales vs Target by Category and Year
SELECT 
    o.category,
    YEAR(o.order_date)          AS year,
    ROUND(SUM(o.sales), 2)      AS actual_sales,
    t.sales_target,
    ROUND(SUM(o.sales) - t.sales_target, 2)                        AS variance,
    ROUND((SUM(o.sales) - t.sales_target) / t.sales_target * 100, 2) AS variance_pct
FROM orders o
JOIN target t 
    ON o.category = t.category 
    AND YEAR(o.order_date) = t.year
GROUP BY o.category, YEAR(o.order_date), t.sales_target
ORDER BY year, o.category;

-- ============================================================
-- END OF ANALYSIS
-- ============================================================
