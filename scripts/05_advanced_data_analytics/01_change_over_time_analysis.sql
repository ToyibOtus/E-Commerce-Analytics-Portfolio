/*
=====================================================================
Script    : 01_change_over_time_analysis.sql
Location  : 04_advanced_data_analytics/
Author    : Otusanya Toyib Oluwatimilehin
Created   : 2026-04-18
=====================================================================
Script Purpose:
	This script performs change over time analysis, providing 
	insights into how relevant metrics change over time.
=====================================================================
*/
USE SalesDB;
GO

-- Is revenue increasing consistently across the years?
-- Is profit margin increasing with every passing year?
-- Excluding 2010 due to absence of transactions records from Jan - Nov
SELECT
	YEAR(fo.order_date) AS order_year,
	COUNT(DISTINCT fo.customer_key) AS total_customers,
	COUNT(DISTINCT fo.product_key) AS total_products,
	COUNT(DISTINCT fo.order_number) AS total_orders,
	SUM(fo.quantity) AS total_quantity,
	SUM(fo.sales_amount) AS total_sales,
	SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) AS total_profit,
	ROUND((CAST(SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) AS FLOAT)/SUM(fo.sales_amount)) * 100, 2) AS profit_margin,
	SUM(fo.sales_amount)/SUM(fo.quantity) AS weighted_avg_price,
	(SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity))/SUM(fo.quantity) AS profit_per_qty
FROM gold.fact_orders fo
LEFT JOIN gold.dim_customers dc
ON fo.customer_key = dc.customer_key
LEFT JOIN gold.dim_products dp
ON fo.product_key = dp.product_key
WHERE fo.order_date IS NOT NULL AND YEAR(fo.order_date) <> 2010
GROUP BY YEAR(fo.order_date)
ORDER BY order_year;


-- Is revenue always highest in the month of december?
-- Excluding 2010 due to absence of transactions records from Jan - Nov
SELECT
	DATETRUNC(month, fo.order_date) AS monthly_orders,
	DATENAME(month, fo.order_date) AS month_name,
	COUNT(DISTINCT fo.customer_key) AS total_customers,
	COUNT(DISTINCT fo.product_key) AS total_products,
	COUNT(DISTINCT fo.order_number) AS total_orders,
	SUM(fo.quantity) AS total_quantity,
	SUM(fo.sales_amount) AS total_sales,
	SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) AS total_profit,
	ROUND((CAST(SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) AS FLOAT)/SUM(fo.sales_amount)) * 100, 2) AS profit_margin,
	SUM(fo.sales_amount)/SUM(fo.quantity) AS weighted_avg_price,
	(SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity))/SUM(fo.quantity) AS profit_per_qty
FROM gold.fact_orders fo
LEFT JOIN gold.dim_customers dc
ON fo.customer_key = dc.customer_key
LEFT JOIN gold.dim_products dp
ON fo.product_key = dp.product_key
WHERE fo.order_date IS NOT NULL AND YEAR(fo.order_date) <> 2010
GROUP BY DATETRUNC(month, order_date), DATENAME(month, order_date)
ORDER BY monthly_orders;


-- Within each country, is revenue increasing consistently across the years?
-- Within each country, is profit margin increasing with every passing year?
-- Excluding 2010 due to absence of transactions records from Jan - Nov
SELECT
	YEAR(fo.order_date) AS order_year,
	dc.country,
	COUNT(DISTINCT fo.customer_key) AS total_customers,
	COUNT(DISTINCT fo.product_key) AS total_products,
	COUNT(DISTINCT fo.order_number) AS total_orders,
	SUM(fo.quantity) AS total_quantity,
	SUM(fo.sales_amount) AS total_sales,
	SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) AS total_profit,
	ROUND((CAST(SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) AS FLOAT)/SUM(fo.sales_amount)) * 100, 2) AS profit_margin,
	SUM(fo.sales_amount)/SUM(fo.quantity) AS weighted_avg_price,
	(SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity))/SUM(fo.quantity) AS profit_per_qty
FROM gold.fact_orders fo
LEFT JOIN gold.dim_customers dc
ON fo.customer_key = dc.customer_key
LEFT JOIN gold.dim_products dp
ON fo.product_key = dp.product_key
WHERE fo.order_date IS NOT NULL AND YEAR(fo.order_date) <> 2010 AND dc.country <> 'N/A' 
GROUP BY YEAR(fo.order_date), dc.country
ORDER BY dc.country, order_year;


-- Within each category, is revenue increasing consistently across the years?
-- Within each category, is profit margin increasing with every passing year?
-- Excluding 2010 due to absence of transactions records from Jan - Nov
SELECT
	YEAR(fo.order_date) AS order_year,
	dp.category,
	COUNT(DISTINCT fo.customer_key) AS total_customers,
	COUNT(DISTINCT fo.product_key) AS total_products,
	COUNT(DISTINCT fo.order_number) AS total_orders,
	SUM(fo.quantity) AS total_quantity,
	SUM(fo.sales_amount) AS total_sales,
	SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) AS total_profit,
	ROUND((CAST(SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) AS FLOAT)/SUM(fo.sales_amount)) * 100, 2) AS profit_margin,
	SUM(fo.sales_amount)/SUM(fo.quantity) AS weighted_avg_price,
	(SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity))/SUM(fo.quantity) AS profit_per_qty
FROM gold.fact_orders fo
LEFT JOIN gold.dim_products dp
ON fo.product_key = dp.product_key
WHERE fo.order_date IS NOT NULL AND YEAR(fo.order_date) <> 2010
GROUP BY YEAR(fo.order_date), dp.category
ORDER BY dp.category, order_year;
