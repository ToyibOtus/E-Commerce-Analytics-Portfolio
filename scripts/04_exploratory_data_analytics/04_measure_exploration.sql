/*
========================================================================
Script    : 05_magnitude_analysis.sql
Location  : 04_exploratory_data_analytics/
Author    : Otusanya Toyib Oluwatimilehin
Created   : 2026-04-17
========================================================================
Script Purpose:
	This script performs magnitude analysis. It shows the distribution
	of key metrics across relevant dimensions, providing a more detailed
	insight into the business performance.
========================================================================
*/
USE SalesDB;
GO

-- Which country brings in the most revenue, and why?
SELECT
	dc.country,
	COUNT(DISTINCT dc.customer_key) AS total_customers,
	SUM(fo.sales_amount) AS total_sales,
	COUNT(DISTINCT fo.order_number) AS total_orders,
	SUM(fo.quantity) AS total_quantity,
	SUM(fo.sales_amount)/SUM(fo.quantity) AS avg_price_per_quantity,
	COUNT(DISTINCT fo.product_key) AS total_products,
	SUM(fo.quantity)/COUNT(fo.product_key) AS avg_qty_per_prd,
	AVG(DATEDIFF(day, order_date, ship_date)) AS avg_shipping_days
FROM gold.fact_orders fo
LEFT JOIN gold.dim_customers dc
ON dc.customer_key = fo.customer_key
WHERE dc.country <> 'N/A'
GROUP BY country
ORDER BY total_sales DESC;


-- Which country generates the most profit?
SELECT
	dc.country,
	SUM(fo.sales_amount) AS total_sales,
	SUM(dp.cost * fo.quantity) AS total_cost,
	SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) AS total_profit,
	ROUND(((SUM(CAST(fo.sales_amount AS FLOAT)) - SUM(dp.cost * fo.quantity))/SUM(fo.sales_amount)) * 100, 2) AS profit_margin
FROM gold.fact_orders fo
LEFT JOIN gold.dim_customers dc
ON fo.customer_key = dc.customer_key
LEFT JOIN gold.dim_products dp
ON fo.product_key = dp.product_key
WHERE dc.country <> 'N/A'
GROUP BY dc.country
ORDER BY total_profit DESC;


-- Which gender gravitates toward our business?
-- How does sales and other relevant metric spread across gender
SELECT
	gender,
	COUNT(DISTINCT dc.customer_key) AS total_customers,
	SUM(fo.sales_amount) AS total_sales,
	COUNT(DISTINCT fo.order_number) AS total_orders,
	SUM(fo.quantity) AS total_quantity
FROM gold.dim_customers dc
LEFT JOIN gold.fact_orders fo
ON fo.customer_key = dc.customer_key
WHERE dc.gender <> 'N/A'
GROUP BY dc.gender
ORDER BY total_sales DESC;


-- Do we have more married customers?
-- How does sales and other relevant metric spread across marital status
SELECT
	marital_status,
	COUNT(DISTINCT dc.customer_key) AS total_customers,
	SUM(fo.sales_amount) AS total_sales,
	COUNT(DISTINCT fo.order_number) AS total_orders,
	SUM(fo.quantity) AS total_quantity
FROM gold.dim_customers dc 
LEFT JOIN gold.fact_orders fo
ON fo.customer_key = dc.customer_key
GROUP BY dc.marital_status
ORDER BY total_sales DESC;


-- Retrieve customers' age
WITH customer_age AS
(
SELECT
	customer_key,
	DATEDIFF(year, birth_date, GETDATE()) AS age
FROM gold.dim_customers
)
-- Segment age into various age groups
, age_group AS
(
SELECT
	customer_key,
	age,
	CASE
		WHEN age < 20 THEN 'Below 20'
		WHEN age BETWEEN 20 AND 30 THEN '20-30'
		WHEN age BETWEEN 31 AND 40 THEN '31-40'
		WHEN age BETWEEN 41 AND 50 THEN '41-50'
		ELSE 'Above 50'
	END AS age_group
FROM customer_age
)
-- What is the composition of customers by age group?
-- And what is the distribution of sales and other relevant metrics across age group
SELECT
	ag.age_group,
	COUNT(DISTINCT ag.customer_key) AS total_customers,
	SUM(fo.sales_amount) AS total_sales,
	COUNT(DISTINCT fo.order_number) AS total_orders,
	SUM(fo.quantity) AS total_quantity
FROM age_group ag
LEFT JOIN gold.fact_orders fo
ON ag.customer_key = fo.customer_key
GROUP BY ag.age_group
ORDER BY total_customers DESC;


-- What is the composition of products by category?
SELECT
	category,
	COUNT(*) AS total_products
FROM gold.dim_products
WHERE category <> 'N/A'
GROUP BY category
ORDER BY total_products DESC;


-- Which category of product brings in the most revenue?
-- And how do other metrics explain the observed distribution in sales?
SELECT
	dp.category,
	COALESCE(SUM(fo.sales_amount), 0) AS total_sales,
	COUNT(DISTINCT fo.order_number) AS total_orders,
	COALESCE(SUM(fo.quantity), 0) AS total_quantity,
	COALESCE(SUM(fo.sales_amount)/SUM(fo.quantity), 0) AS avg_price_per_quantity,
	COUNT(DISTINCT dp.product_key) AS total_products,
	COUNT(DISTINCT fo.product_key) AS total_products_ordered,
	COALESCE(SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity), 0) AS total_profit,
	COALESCE(ROUND(((SUM(CAST(fo.sales_amount AS FLOAT)) - SUM(dp.cost * fo.quantity))/SUM(fo.sales_amount)) * 100, 2), 0) AS profit_margin,
	COALESCE((SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity))/SUM(fo.quantity), 0) AS profit_per_qty
FROM gold.dim_products dp 
LEFT JOIN gold.fact_orders fo
ON fo.product_key = dp.product_key
WHERE dp.category <> 'N/A'
GROUP BY dp.category
ORDER BY total_sales DESC;


-- Within each category, which subcategory of product brings in the most revenue?
-- And how do other metrics explain the observed distribution in sales?
-- Excluding 'N/A' and 'Components' categories — no transactions recorded
SELECT
	dp.category,
	dp.subcategory,
	COALESCE(SUM(fo.sales_amount), 0) AS total_sales,
	COUNT(DISTINCT fo.order_number) AS total_orders,
	COALESCE(SUM(fo.quantity), 0) AS total_quantity,
	COALESCE(SUM(fo.sales_amount)/SUM(fo.quantity), 0) AS avg_price_per_quantity,
	COUNT(DISTINCT dp.product_key) AS total_products,
	COUNT(DISTINCT fo.product_key) AS total_products_ordered,
	COALESCE(SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity), 0) AS total_profit,
	COALESCE(ROUND(((SUM(CAST(fo.sales_amount AS FLOAT)) - SUM(dp.cost * fo.quantity))/SUM(fo.sales_amount)) * 100, 2), 0) AS profit_margin,
	COALESCE((SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity))/SUM(fo.quantity), 0) AS profit_per_qty
FROM gold.dim_products dp   
LEFT JOIN gold.fact_orders fo
ON fo.product_key = dp.product_key
WHERE dp.category NOT IN ('N/A', 'Components')
GROUP BY dp.category, dp.subcategory
ORDER BY dp.category, total_sales DESC;


-- Within each category & subcategory, which subcategory of product brings in the most revenue?
-- And how do other metrics explain the observed distribution in sales?
-- Excluding subcategories with zero transactions within the 4-year sales period
SELECT
	dp.category,
	dp.subcategory,
	dp.product_name,
	COALESCE(SUM(fo.sales_amount), 0) AS total_sales,
	COUNT(DISTINCT fo.order_number) AS total_orders,
	COALESCE(SUM(fo.quantity), 0) AS total_quantity,
	COALESCE(SUM(fo.sales_amount)/SUM(fo.quantity), 0) AS avg_price_per_quantity,
	COALESCE(SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity), 0) AS total_profit,
	COALESCE(ROUND(((SUM(CAST(fo.sales_amount AS FLOAT)) - SUM(dp.cost * fo.quantity))/SUM(fo.sales_amount)) * 100, 2), 0) AS profit_margin,
	COALESCE((SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity))/SUM(fo.quantity), 0) AS profit_per_qty
FROM gold.dim_products dp   
LEFT JOIN gold.fact_orders fo
ON fo.product_key = dp.product_key
WHERE dp.category NOT IN ('N/A', 'Components') AND dp.subcategory NOT IN ('Tights', 'Bib-Shorts', 'Lights', 'Locks', 'Panniers', 'Pumps')
GROUP BY dp.category, dp.subcategory, dp.product_name
ORDER BY dp.category, total_sales DESC;


-- How many of our products need maintenance?
-- And do maintenance-reliant products cost more on average?
SELECT
	maintenance,
	COUNT(*) AS total_products,
	AVG(cost) AS avg_cost
FROM gold.dim_products
WHERE maintenance <> 'N/A'
GROUP BY maintenance
ORDER BY total_products DESC;
