/*
=====================================================================
Script    : 04_measure_exploration.sql
Location  : 04_exploratory_data_analytics/
Author    : Otusanya Toyib Oluwatimilehin
Created   : 2026-04-13
=====================================================================
Script Purpose:
	This script performs measure exploration. It provides an overview
	of the business metric performance.
=====================================================================
*/
USE SalesDB;
GO

-- What is the total revenue generated?
SELECT SUM(sales_amount) AS total_sales FROM gold.fact_orders;

-- How many orders produced this revenue?
SELECT COUNT(DISTINCT order_number) AS total_orders FROM gold.fact_orders;

-- How many quantity of products were sold to generate this revenue?
SELECT SUM(quantity) AS total_quantity FROM gold.fact_orders;

-- What is the total profit, using current product cost?
SELECT SUM(fo.sales_amount - (dp.cost * fo.quantity)) AS total_profit FROM gold.fact_orders fo
LEFT JOIN gold.dim_products dp ON fo.product_key = dp.product_key;

-- What is the average profit margin, using current product cost?
SELECT ROUND((SUM(CAST(fo.sales_amount - (dp.cost * fo.quantity) AS FLOAT))/SUM(fo.sales_amount)) * 100, 2) AS avg_profit_margin 
FROM gold.fact_orders fo LEFT JOIN gold.dim_products dp ON fo.product_key = dp.product_key;

-- What is the average sales?
SELECT AVG(sales_amount) AS avg_sales FROM gold.fact_orders;

-- What is the standard deviation?
SELECT ROUND(STDEV(CAST(sales_amount AS FLOAT)), 2) AS stdev_sales FROM gold.fact_orders;

-- On average, how much does each sales amount deviate from the mean?
SELECT ROUND((STDEV(CAST(sales_amount AS FLOAT))/AVG(sales_amount)) * 100, 2) AS stdev_sales FROM gold.fact_orders;

-- What is the lowest price?
SELECT MIN(price) AS min_price FROM gold.fact_orders;

-- What is the highest price?
SELECT MAX(price) AS max_price FROM gold.fact_orders;

-- What is the weighted average price?
SELECT SUM(sales_amount)/SUM(quantity) AS weighted_avg_price FROM gold.fact_orders;

-- What is the fastest shipping day?
SELECT MIN(DATEDIFF(day, order_date, ship_date)) AS min_shipping_day FROM gold.fact_orders;

-- What is the slowest shipping day?
SELECT MAX(DATEDIFF(day, order_date, ship_date)) AS max_shipping_day FROM gold.fact_orders;

-- What is the average shipping days?
SELECT AVG(DATEDIFF(day, order_date, ship_date)) AS avg_shipping_day FROM gold.fact_orders;

-- What is the minimum distance in days between shipping & due date
SELECT MIN(DATEDIFF(day, ship_date, due_date)) AS min_due_day FROM gold.fact_orders;

-- What is the maximum distance in days between shipping & due date
SELECT MAX(DATEDIFF(day, ship_date, due_date)) AS max_due_day FROM gold.fact_orders;

-- What is the average distance in days between shipping & due date
SELECT AVG(DATEDIFF(day, ship_date, due_date)) AS avg_due_day FROM gold.fact_orders;

-- How many unique products exist?
SELECT COUNT(product_key) AS total_products FROM gold.dim_products;

-- How many of these products have been ordered?
SELECT COUNT(DISTINCT product_key) AS total_products FROM gold.fact_orders;

-- How many of these products have not been ordered?
SELECT COUNT(dp.product_key) AS total_products FROM gold.dim_products dp WHERE NOT EXISTS
(SELECT DISTINCT product_key FROM gold.fact_orders fo WHERE fo.product_key = dp.product_key);

-- What is the lowest product cost?
SELECT MIN(cost) AS min_cost FROM gold.dim_products;

-- What is the highest product cost?
SELECT MAX(cost) AS max_cost FROM gold.dim_products;

-- What is the average product cost?
SELECT AVG(cost) AS avg_cost FROM gold.dim_products;

-- How many unique customers exist?
SELECT COUNT(customer_key) AS total_customers FROM gold.dim_customers;

-- How many of these customers have ordered a product?
SELECT COUNT(DISTINCT customer_key) AS total_customers FROM gold.fact_orders;



-- Generata a report consolidating relevant metrics
SELECT 'Total Sales' AS measure_name, SUM(sales_amount) AS measure_value FROM gold.fact_orders
UNION
SELECT 'Total Orders', COUNT(DISTINCT order_number) FROM gold.fact_orders
UNION
SELECT 'Total Quantity', SUM(quantity) FROM gold.fact_orders
UNION
SELECT 'Total Profit', SUM(fo.sales_amount - (dp.cost * fo.quantity)) FROM gold.fact_orders fo
LEFT JOIN gold.dim_products dp ON fo.product_key = dp.product_key
UNION
SELECT 'Average Profit Margin (%)', ROUND((SUM(CAST(fo.sales_amount - (dp.cost * fo.quantity) AS FLOAT))/SUM(fo.sales_amount)) * 100, 2) 
FROM gold.fact_orders fo LEFT JOIN gold.dim_products dp ON fo.product_key = dp.product_key
UNION
SELECT 'Lowest Product Price', MIN(price) FROM gold.fact_orders
UNION
SELECT 'Highest Product Price', MAX(price) FROM gold.fact_orders
UNION
SELECT 'Average Price Per Quantity', SUM(sales_amount)/SUM(quantity) FROM gold.fact_orders
UNION
SELECT 'Average Shipping Days', AVG(DATEDIFF(day, order_date, ship_date)) AS avg_shipping_day FROM gold.fact_orders
UNION
SELECT 'Total Products', COUNT(product_key) FROM gold.dim_products
UNION
SELECT 'Total Products Ordered', COUNT(DISTINCT product_key) AS total_products FROM gold.fact_orders
UNION
SELECT 'Total Products Not Ordered', COUNT(dp.product_key) FROM gold.dim_products dp WHERE NOT EXISTS
(SELECT DISTINCT product_key FROM gold.fact_orders fo WHERE fo.product_key = dp.product_key)
UNION
SELECT 'Minimum Product Cost', MIN(cost) FROM gold.dim_products
UNION
SELECT 'Maximum Product Cost', MAX(cost) FROM gold.dim_products
UNION
SELECT'Average Product Cost', AVG(cost) FROM gold.dim_products
UNION
SELECT 'Total Customers', COUNT(customer_key) FROM gold.dim_customers
UNION
SELECT 'Total Customers Ordered', COUNT(DISTINCT customer_key) FROM gold.fact_orders;


-- What is the statistical distribution of sales amounts?
-- Is the mean a reliable measure of central tendency for sales? 
WITH quartile AS
(
SELECT
	sales_amount,
	NTILE(4) OVER(ORDER BY sales_amount) AS quartile
FROM gold.fact_orders
)
, metrics AS
(
SELECT	
	MIN(sales_amount) AS min_sales,
	MAX(sales_amount) AS max_sales,
	AVG(sales_amount) AS avg_sales,
	ROUND(STDEV(CAST(sales_amount AS FLOAT)), 2) AS stdev_sales,
	ROUND((STDEV(CAST(sales_amount AS FLOAT))/AVG(sales_amount)) * 100, 2) AS cv_sales,
	MAX(CASE WHEN quartile = 1 THEN sales_amount ELSE NULL END) AS quartile_1,
	MAX(CASE WHEN quartile = 2 THEN sales_amount ELSE NULL END) AS median,
	MAX(CASE WHEN quartile = 3 THEN sales_amount ELSE NULL END) AS quartile_3
FROM quartile
)
SELECT
	min_sales,
	max_sales,
	avg_sales,
	stdev_sales,
	cv_sales,
	quartile_1,
	median,
	quartile_3,
	quartile_3 - quartile_1 AS iqr,
	quartile_1 - (1.5 * (quartile_3 - quartile_1)) AS lower_boundary,
	quartile_3 + (1.5 * (quartile_3 - quartile_1)) AS upper_boundary
FROM metrics;


-- What is the statistical distribution of cost?
-- Is the mean a reliable measure of central tendency for cost?
WITH quartile AS
(
SELECT
	cost,
	NTILE(4) OVER(ORDER BY cost) AS quartile
FROM gold.dim_products
WHERE cost IS NOT NULL
)
, metrics AS
(
SELECT
	MIN(cost) AS min_cost,
	MAX(cost) AS max_cost,
	AVG(cost) AS avg_cost,
	ROUND(STDEV(CAST(cost AS FLOAT)), 2) AS stdev_cost,
	ROUND((STDEV(CAST(cost AS FLOAT))/AVG(cost)) * 100, 2) AS cv_cost,
	MAX(CASE WHEN quartile = 1 THEN cost ELSE NULL END) AS quartile_1,
	MAX(CASE WHEN quartile = 2 THEN cost ELSE NULL END) AS median,
	MAX(CASE WHEN quartile = 3 THEN cost ELSE NULL END) AS quartile_3
FROM quartile
)
SELECT
	min_cost,
	max_cost,
	avg_cost,
	stdev_cost,
	cv_cost,
	quartile_1,
	median,
	quartile_3,
	quartile_3 - quartile_1 AS iqr,
	quartile_1 - (1.5 *(quartile_3 - quartile_1)) AS lower_boundary,
	quartile_3 + (1.5 *(quartile_3 - quartile_1)) AS upper_boundary
FROM metrics;


-- What proportion of transactions are statistical outliers?
-- How much of total revenue do outlier orders contribute? 
WITH quartile AS
(
SELECT
	sales_amount,
	NTILE(4) OVER(ORDER BY sales_amount) AS quartile
FROM gold.fact_orders
)
, metrics AS
(
SELECT	
	MIN(sales_amount) AS min_sales,
	MAX(sales_amount) AS max_sales,
	AVG(sales_amount) AS avg_sales,
	ROUND(STDEV(CAST(sales_amount AS FLOAT)), 2) AS stdev_sales,
	ROUND((STDEV(CAST(sales_amount AS FLOAT))/AVG(sales_amount)) * 100, 2) AS cv_sales,
	MAX(CASE WHEN quartile = 1 THEN sales_amount ELSE NULL END) AS quartile_1,
	MAX(CASE WHEN quartile = 2 THEN sales_amount ELSE NULL END) AS median,
	MAX(CASE WHEN quartile = 3 THEN sales_amount ELSE NULL END) AS quartile_3
FROM quartile
)
, sales_dist AS
(
SELECT
	min_sales,
	max_sales,
	avg_sales,
	stdev_sales,
	cv_sales,
	quartile_1,
	median,
	quartile_3,
	quartile_3 - quartile_1 AS iqr,
	quartile_1 - (1.5 * (quartile_3 - quartile_1)) AS lower_boundary,
	quartile_3 + (1.5 * (quartile_3 - quartile_1)) AS upper_boundary
FROM metrics
)
SELECT
	COUNT(*) AS total_transactions,
	SUM(fo.sales_amount) AS total_sales,
	SUM(CASE WHEN fo.sales_amount > sd.upper_boundary THEN fo.sales_amount ELSE NULL END) AS outlier_revenue,
	COUNT(CASE WHEN fo.sales_amount > sd.upper_boundary THEN fo.sales_amount ELSE NULL END) AS outlier_count,
	ROUND((CAST(COUNT(CASE WHEN fo.sales_amount > sd.upper_boundary THEN fo.sales_amount ELSE NULL END) AS FLOAT)/COUNT(*)) * 100, 2) AS outlier_count_pct,
	ROUND((CAST(SUM(CASE WHEN fo.sales_amount > sd.upper_boundary THEN fo.sales_amount ELSE NULL END) AS FLOAT)/SUM(fo.sales_amount)) * 100, 2) AS outlier_revenue_pct
FROM gold.fact_orders fo
CROSS JOIN sales_dist sd;
