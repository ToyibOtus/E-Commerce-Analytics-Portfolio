/*
=====================================================================
Script    : 02_cumulative_analysis.sql
Location  : 04_advanced_data_analytics/
Author    : Otusanya Toyib Oluwatimilehin
Created   : 2026-04-18
=====================================================================
Script Purpose:
	This script performs cumulative analysis at both yearly and 
	monthly levels, tracking running totals of key metrics, revenue, 
	profit, orders, and quantity to reveal growth trajectory over 
	time. 
	
	Period-over-period percentage differences on cumulative 
	totals show how fast the business is compounding value across 
	the 4-year window. Monthly cumulative totals reset annually to 
	track within-year progression independently.
=====================================================================
*/
USE SalesDB;
GO

-- How much is orders, quantity, revenue, profit and every other key metrics increasing year-over-year?
-- Is significant performance attributed to low price?
-- Excluding 2010 due to absence of transactions records from Jan - Nov
WITH metrics AS
(
SELECT
	YEAR(fo.order_date) AS order_year,
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
GROUP BY YEAR(fo.order_date)
)
, cumulative_metrics AS
(
SELECT
	order_year,
	SUM(total_orders) OVER(ORDER BY order_year) AS running_total_orders,
	SUM(total_quantity) OVER(ORDER BY order_year) AS running_total_quantity,
	SUM(total_sales) OVER(ORDER BY order_year) AS running_total_sales,
	SUM(total_profit) OVER(ORDER BY order_year) AS running_total_profit,
	ROUND((CAST(SUM(total_profit) OVER(ORDER BY order_year) AS FLOAT)/SUM(total_sales) OVER(ORDER BY order_year)) * 100, 2) AS running_profit_margin,
	ROUND(CAST(SUM(total_sales) OVER(ORDER BY order_year) AS FLOAT)/SUM(total_quantity) OVER(ORDER BY order_year), 2) AS running_weighted_avg_price,
	ROUND(CAST(SUM(total_profit) OVER(ORDER BY order_year) AS FLOAT)/SUM(total_quantity) OVER(ORDER BY order_year), 2) AS running_profit_per_quantity
FROM metrics
)
SELECT
	order_year,
	running_total_orders,
	ROUND((CAST((running_total_orders - LAG(running_total_orders) OVER(ORDER BY order_year)) AS FLOAT)
	/LAG(running_total_orders) OVER(ORDER BY order_year)) * 100, 2) AS pct_diff_orders,
	running_total_quantity,
	ROUND((CAST((running_total_quantity - LAG(running_total_quantity) OVER(ORDER BY order_year)) AS FLOAT)
	/LAG(running_total_quantity) OVER(ORDER BY order_year)) * 100, 2) AS pct_diff_qty,
	running_total_sales,
	ROUND((CAST((running_total_sales - LAG(running_total_sales) OVER(ORDER BY order_year)) AS FLOAT)
	/LAG(running_total_sales) OVER(ORDER BY order_year)) * 100, 2) AS pct_diff_sales,
	running_total_profit,
	ROUND((CAST((running_total_profit - LAG(running_total_profit) OVER(ORDER BY order_year)) AS FLOAT)
	/LAG(running_total_profit) OVER(ORDER BY order_year)) * 100, 2) AS pct_diff_profit,
	running_profit_margin,
	ROUND((CAST((running_profit_margin - LAG(running_profit_margin) OVER(ORDER BY order_year)) AS FLOAT)
	/LAG(running_profit_margin) OVER(ORDER BY order_year)) * 100, 2) AS pct_diff_pm,
	running_weighted_avg_price,
	ROUND((CAST((running_weighted_avg_price - LAG(running_weighted_avg_price) OVER(ORDER BY order_year)) AS FLOAT)
	/LAG(running_weighted_avg_price) OVER(ORDER BY order_year)) * 100, 2) AS pct_diff_price,
	running_profit_per_quantity,
	ROUND((CAST((running_profit_per_quantity - LAG(running_profit_per_quantity) OVER(ORDER BY order_year)) AS FLOAT)
	/LAG(running_profit_per_quantity) OVER(ORDER BY order_year)) * 100, 2) AS pct_diff_ppq
FROM cumulative_metrics;


-- How much is orders, quantity, revenue, profit and every other key metrics increasing month-over-month?
-- Is significant performance attributed to low price?
-- Excluding 2010 due to absence of transactions records from Jan - Nov
WITH metrics AS
(
SELECT
	DATETRUNC(month, fo.order_date) AS monthly_orders,
	DATENAME(month, fo.order_date) AS month_name,
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
GROUP BY DATETRUNC(month, fo.order_date), DATENAME(month, fo.order_date)
)
, cumulative_metrics AS
(
SELECT
	monthly_orders,
	month_name,
	SUM(total_orders) OVER(PARTITION BY YEAR(monthly_orders) ORDER BY monthly_orders) AS running_total_orders,
	SUM(total_quantity) OVER(PARTITION BY YEAR(monthly_orders) ORDER BY monthly_orders) AS running_total_quantity,
	SUM(total_sales) OVER(PARTITION BY YEAR(monthly_orders) ORDER BY monthly_orders) AS running_total_sales,
	SUM(total_profit) OVER(PARTITION BY YEAR(monthly_orders) ORDER BY monthly_orders) AS running_total_profit,
	ROUND((CAST(SUM(total_profit) OVER(PARTITION BY YEAR(monthly_orders) ORDER BY monthly_orders) AS FLOAT)
	/SUM(total_sales) OVER(PARTITION BY YEAR(monthly_orders) ORDER BY monthly_orders)) * 100, 2) AS running_profit_margin,
	ROUND(CAST(SUM(total_sales) OVER(PARTITION BY YEAR(monthly_orders) ORDER BY monthly_orders) AS FLOAT)
	/SUM(total_quantity) OVER(PARTITION BY YEAR(monthly_orders) ORDER BY monthly_orders), 2) AS running_weighted_avg_price,
	ROUND(CAST(SUM(total_profit) OVER(PARTITION BY YEAR(monthly_orders) ORDER BY monthly_orders) AS FLOAT)
	/SUM(total_quantity) OVER(PARTITION BY YEAR(monthly_orders) ORDER BY monthly_orders), 2) AS running_profit_per_quantity
FROM metrics
)
SELECT
	monthly_orders,
	month_name,
	running_total_orders,
	ROUND((CAST((running_total_orders - LAG(running_total_orders) OVER(PARTITION BY YEAR(monthly_orders) ORDER BY monthly_orders)) AS FLOAT)
	/LAG(running_total_orders) OVER(PARTITION BY YEAR(monthly_orders) ORDER BY monthly_orders)) * 100, 2) AS pct_diff_orders,
	running_total_quantity,
	ROUND((CAST((running_total_quantity - LAG(running_total_quantity) OVER(PARTITION BY YEAR(monthly_orders) ORDER BY monthly_orders)) AS FLOAT)
	/LAG(running_total_quantity) OVER(PARTITION BY YEAR(monthly_orders) ORDER BY monthly_orders)) * 100, 2) AS pct_diff_qty,
	running_total_sales,
	ROUND((CAST((running_total_sales - LAG(running_total_sales) OVER(PARTITION BY YEAR(monthly_orders) ORDER BY monthly_orders)) AS FLOAT)
	/LAG(running_total_sales) OVER(PARTITION BY YEAR(monthly_orders) ORDER BY monthly_orders)) * 100, 2) AS pct_diff_sales,
	running_total_profit,
	ROUND((CAST((running_total_profit - LAG(running_total_profit) OVER(PARTITION BY YEAR(monthly_orders) ORDER BY monthly_orders)) AS FLOAT)
	/LAG(running_total_profit) OVER(PARTITION BY YEAR(monthly_orders) ORDER BY monthly_orders)) * 100, 2) AS pct_diff_profit,
	running_profit_margin,
	ROUND((CAST((running_profit_margin - LAG(running_profit_margin) OVER(PARTITION BY YEAR(monthly_orders) ORDER BY monthly_orders)) AS FLOAT)
	/LAG(running_profit_margin) OVER(PARTITION BY YEAR(monthly_orders) ORDER BY monthly_orders)) * 100, 2) AS pct_diff_pm,
	running_weighted_avg_price,
	ROUND((CAST((running_weighted_avg_price - LAG(running_weighted_avg_price) OVER(PARTITION BY YEAR(monthly_orders) ORDER BY monthly_orders)) AS FLOAT)
	/LAG(running_weighted_avg_price) OVER(PARTITION BY YEAR(monthly_orders) ORDER BY monthly_orders)) * 100, 2) AS pct_diff_price,
	running_profit_per_quantity,
	ROUND((CAST((running_profit_per_quantity - LAG(running_profit_per_quantity) OVER(PARTITION BY YEAR(monthly_orders) ORDER BY monthly_orders)) AS FLOAT)
	/LAG(running_profit_per_quantity) OVER(PARTITION BY YEAR(monthly_orders) ORDER BY monthly_orders)) * 100, 2) AS pct_diff_ppq
FROM cumulative_metrics;


-- Is revenue & profit increasing with price drop?
-- And Is it at the expense of profit margin?
WITH base_query AS
(
SELECT
	DATETRUNC(month, fo.order_date) AS monthly_orders,
	DATENAME(month, fo.order_date) AS month_name,
	COUNT(DISTINCT fo.order_number) AS total_orders,
	SUM(fo.sales_amount) AS total_sales,
	SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) AS total_profit,
	ROUND((CAST(SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) AS FLOAT)/SUM(fo.sales_amount)) * 100, 2) AS profit_margin,
	SUM(fo.sales_amount)/SUM(fo.quantity) AS weighted_avg_price,
	(SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity))/SUM(fo.quantity) AS profit_per_qty
FROM gold.fact_orders fo
LEFT JOIN gold.dim_products dp
ON fo.product_key = dp.product_key
WHERE fo.order_date IS NOT NULL AND YEAR(fo.order_date) <> 2010
GROUP BY DATETRUNC(month, order_date), DATENAME(month, order_date)
)
SELECT
	monthly_orders,
	month_name,
	AVG(total_orders) OVER(ORDER BY monthly_orders ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_3m_orders,
	AVG(total_sales) OVER(ORDER BY monthly_orders ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_3m_sales,
	AVG(total_profit) OVER(ORDER BY monthly_orders ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_3m_profit,
	ROUND(CAST(AVG(profit_margin) OVER(ORDER BY monthly_orders ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS FLOAT), 2) AS moving_avg_3m_pm,
	AVG(weighted_avg_price) OVER(ORDER BY monthly_orders ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_3m_price,
	AVG(profit_per_qty) OVER(PARTITION BY YEAR(monthly_orders) ORDER BY monthly_orders ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg_3m_ppq
FROM base_query;
