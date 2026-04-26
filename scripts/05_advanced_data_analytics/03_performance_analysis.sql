/*
============================================================================
Script    : 03_performance_analysis.sql
Location  : 04_advanced_data_analytics/
Author    : Otusanya Toyib Oluwatimilehin
Created   : 2026-04-18
============================================================================
Script Purpose:
	This script performs performance analysis across three dimensions.
	At the product level it benchmarks each product's yearly revenue  
	and profit against both its own historical average (internal 
	benchmarking) and the cross-product average for that year 
	(external benchmarking).
	
	At the country level it benchmarks yearly revenue against each country's 
	historical average and tracks year-over-year growth. Customer retention 
	is analysed by measuring what percentage of each year's buyers are 
	returning versus new acquisitions.
============================================================================
*/
USE SalesDB;
GO

-- How does the yearly revenue of each product compare to its average revenue?
-- How does the yearly profit of each product compare to its average profit?
-- Excluding 2010 due to absence of transactions records from Jan - Nov
WITH metrics1 AS
(
SELECT
	YEAR(fo.order_date) AS order_year,
	dp.product_name,
	SUM(fo.sales_amount) AS total_sales,
	AVG(SUM(fo.sales_amount)) OVER(PARTITION BY dp.product_name) AS avg_sales,
	SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) AS total_profit,
	AVG(SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity)) OVER(PARTITION BY dp.product_name) AS avg_profit
FROM gold.fact_orders fo
LEFT JOIN gold.dim_products dp
ON fo.product_key = dp.product_key
WHERE fo.order_date IS NOT NULL AND YEAR(fo.order_date) <> 2010
GROUP BY YEAR(fo.order_date), dp.product_name
)
, metrics2 AS
(
SELECT
	order_year,
	product_name,
	total_sales,
	avg_sales,
	total_sales - avg_sales AS sales_diff,
	ROUND((CAST((total_sales - avg_sales) AS FLOAT)/avg_sales) * 100, 2) AS pct_sales_diff,
	total_profit,
	avg_profit,
	ROUND((CAST((total_profit - avg_profit) AS FLOAT)/avg_profit) * 100, 2) AS pct_profit_diff,
	total_profit - avg_profit AS profit_diff
FROM metrics1
)
SELECT
	order_year,
	product_name,
	total_sales,
	avg_sales,
	sales_diff,
	pct_sales_diff,
	CASE 
		WHEN sales_diff < 0 THEN 'Below Average Sales'
		WHEN sales_diff > 0 THEN 'Above Average Sales'
		ELSE 'Equal to Average Sales'
	END AS sales_status,
	total_profit,
	avg_profit,
	pct_profit_diff,
	profit_diff,
	CASE 
		WHEN profit_diff < 0 THEN 'Below Average Profit'
		WHEN profit_diff > 0 THEN 'Above Average Profit'
		ELSE 'Equal to Average Profit'
	END AS profit_status
FROM metrics2
ORDER BY product_name, order_year;


-- Are products generating more revenue relative to the previous year?
-- Is similar pattern observed with profit?
-- Excluding 2010 due to absence of transactions records from Jan - Nov
WITH metrics1 AS
(
SELECT
	YEAR(fo.order_date) AS order_year,
	dp.product_name,
	SUM(fo.sales_amount) AS current_sales,
	LAG(SUM(fo.sales_amount)) OVER(PARTITION BY dp.product_name ORDER BY YEAR(fo.order_date)) AS previous_sales,
	SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) AS current_profit,
	LAG(SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity)) OVER(PARTITION BY dp.product_name ORDER BY YEAR(fo.order_date)) AS previous_profit
FROM gold.fact_orders fo
LEFT JOIN gold.dim_products dp
ON fo.product_key = dp.product_key
WHERE fo.order_date IS NOT NULL AND YEAR(fo.order_date) <> 2010
GROUP BY YEAR(fo.order_date), dp.product_name
)
, metrics2 AS
(
SELECT
	order_year,
	product_name,
	current_sales,
	previous_sales,
	current_sales - previous_sales AS sales_diff,
	ROUND((CAST((current_sales - previous_sales) AS FLOAT)/previous_sales) * 100, 2) AS pct_sales_diff,
	current_profit,
	previous_profit,
	current_profit - previous_profit AS profit_diff,
	ROUND((CAST((current_profit - previous_profit) AS FLOAT)/previous_profit) * 100, 2) AS pct_profit_diff
FROM metrics1
)
SELECT
	order_year,
	product_name,
	current_sales,
	previous_sales,
	sales_diff,
	pct_sales_diff,
	CASE 
		WHEN sales_diff < 0 THEN 'Below Previous Sales'
		WHEN sales_diff > 0 THEN 'Above Previous Sales'
		WHEN sales_diff = 0 THEN 'Equal to Previous Sales'
		ELSE NULL
	END AS sales_status,
	current_profit,
	previous_profit,
	profit_diff,
	pct_profit_diff,
	CASE 
		WHEN profit_diff < 0 THEN 'Below Previous Profit'
		WHEN profit_diff > 0 THEN 'Above Previous Profit'
		WHEN profit_diff = 0 THEN 'Equal to Previous Profit'
		ELSE NULL
	END AS profit_status
FROM metrics2
ORDER BY product_name, order_year;


-- How does each product's yearly revenue compare to the average revenue across all products that year?
WITH metrics1 AS
(
SELECT
	YEAR(fo.order_date) AS order_year,
	dp.product_name,
	SUM(fo.sales_amount) AS total_sales,
	AVG(SUM(fo.sales_amount)) OVER(PARTITION BY YEAR(fo.order_date)) AS avg_sales,
	SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) AS total_profit,
	AVG(SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity)) OVER(PARTITION BY YEAR(fo.order_date)) AS avg_profit
FROM gold.fact_orders fo
LEFT JOIN gold.dim_products dp
ON fo.product_key = dp.product_key
WHERE fo.order_date IS NOT NULL AND YEAR(fo.order_date) <> 2010
GROUP BY YEAR(fo.order_date), dp.product_name
)
, metrics2 AS
(
SELECT
	order_year,
	product_name,
	total_sales,
	avg_sales,
	total_sales - avg_sales AS sales_diff,
	ROUND((CAST(total_sales - avg_sales AS FLOAT)/avg_sales) * 100, 2) AS pct_sales_diff,
	total_profit,
	avg_profit,
	total_profit - avg_profit AS profit_diff,
	ROUND((CAST(total_profit - avg_profit AS FLOAT)/avg_profit) * 100, 2) AS pct_profit_diff
FROM metrics1
)
SELECT
	order_year,
	product_name,
	total_sales,
	avg_sales,
	sales_diff,
	pct_sales_diff,
	CASE 
		WHEN sales_diff < 0 THEN 'Below Average Sales'
		WHEN sales_diff > 0 THEN 'Above Average Sales'
		ELSE 'Equal to Average Sales'
	END AS sales_status,
	total_profit,
	avg_profit,
	profit_diff,
	pct_profit_diff,
	CASE 
		WHEN profit_diff < 0 THEN 'Below Average Profit'
		WHEN profit_diff > 0 THEN 'Above Average Profit'
		ELSE 'Equal to Average Profit'
	END AS profit_status
FROM metrics2
ORDER BY product_name, order_year;


-- How does the yearly revenue of each country compare to its average revenue?
WITH metrics1 AS
(
SELECT
	YEAR(fo.order_date) AS order_year,
	dc.country,
	SUM(fo.sales_amount) AS total_sales,
	AVG(SUM(fo.sales_amount)) OVER(PARTITION BY dc.country) AS avg_sales,
	SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) AS total_profit,
	AVG(SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity)) OVER(PARTITION BY dc.country) AS avg_profit
FROM gold.fact_orders fo
LEFT JOIN gold.dim_customers dc
ON fo.customer_key = dc.customer_key
LEFT JOIN gold.dim_products dp
ON fo.product_key = dp.product_key
WHERE fo.order_date IS NOT NULL AND YEAR(fo.order_date) <> 2010 AND country <> 'N/A'
GROUP BY YEAR(fo.order_date), dc.country
)
, metrics2 AS
(
SELECT
	order_year,
	country,
	total_sales,
	avg_sales,
	total_sales - avg_sales AS sales_diff,
	ROUND((CAST((total_sales - avg_sales) AS FLOAT)/avg_sales) * 100, 2) AS pct_sales_diff,
	total_profit,
	avg_profit,
	ROUND((CAST((total_profit - avg_profit) AS FLOAT)/avg_profit) * 100, 2) AS pct_profit_diff,
	total_profit - avg_profit AS profit_diff
FROM metrics1
)
SELECT
	order_year,
	country,
	total_sales,
	avg_sales,
	sales_diff,
	pct_sales_diff,
	CASE 
		WHEN sales_diff < 0 THEN 'Below Average Sales'
		WHEN sales_diff > 0 THEN 'Above Average Sales'
		ELSE 'Equal to Average Sales'
	END AS sales_status,
	total_profit,
	avg_profit,
	pct_profit_diff,
	profit_diff,
	CASE 
		WHEN profit_diff < 0 THEN 'Below Average Profit'
		WHEN profit_diff > 0 THEN 'Above Average Profit'
		ELSE 'Equal to Average Profit'
	END AS profit_status
FROM metrics2
ORDER BY country, order_year;


-- Within each country, is revenue & profit increasing with every passing year?
WITH metrics1 AS
(
SELECT
	YEAR(fo.order_date) AS order_year,
	dc.country,
	SUM(fo.sales_amount) AS current_sales,
	LAG(SUM(fo.sales_amount)) OVER(PARTITION BY dc.country ORDER BY YEAR(fo.order_date)) AS previous_sales,
	SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) AS current_profit,
	LAG(SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity)) OVER(PARTITION BY dc.country ORDER BY YEAR(fo.order_date)) AS previous_profit
FROM gold.fact_orders fo
LEFT JOIN gold.dim_customers dc
ON fo.customer_key = dc.customer_key
LEFT JOIN gold.dim_products dp
ON fo.product_key = dp.product_key
WHERE fo.order_date IS NOT NULL AND YEAR(fo.order_date) <> 2010 AND country <> 'N/A'
GROUP BY YEAR(fo.order_date), dc.country
)
, metrics2 AS
(
SELECT
	order_year,
	country,
	current_sales,
	previous_sales,
	current_sales - previous_sales AS sales_diff,
	ROUND((CAST((current_sales - previous_sales) AS FLOAT)/previous_sales) * 100, 2) AS pct_sales_diff,
	current_profit,
	previous_profit,
	ROUND((CAST((current_profit - previous_profit) AS FLOAT)/previous_profit) * 100, 2) AS pct_profit_diff,
	current_profit - previous_profit AS profit_diff
FROM metrics1
)
SELECT
	order_year,
	country,
	current_sales,
	previous_sales,
	sales_diff,
	pct_sales_diff,
	CASE 
		WHEN sales_diff < 0 THEN 'Below Previous Sales'
		WHEN sales_diff > 0 THEN 'Above Previous Sales'
		WHEN sales_diff = 0 THEN 'Equal to Previous Sales'
		ELSE NULL
	END AS sales_status,
	current_profit,
	previous_profit,
	pct_profit_diff,
	profit_diff,
	CASE 
		WHEN profit_diff < 0 THEN 'Below Previous Profit'
		WHEN profit_diff > 0 THEN 'Above Previous Profit'
		WHEN profit_diff = 0 THEN 'Equal to Previous Profit'
		ELSE NULL
	END AS profit_status
FROM metrics2
ORDER BY country, order_year;


-- Are most of our customers coming back to do business?
-- Within each year, how much of our customers are new and old?
-- Note: pct_new_customers includes both first-time buyers and 
-- previously lapsed customers returning after a gap year.
WITH customers AS
(
SELECT DISTINCT
	YEAR(order_date) AS order_year,
	customer_key
FROM gold.fact_orders
WHERE order_date IS NOT NULL AND YEAR(order_date) <> 2010
)
, metrics AS
(
SELECT
	c.order_year,
	COUNT(c.customer_key) AS total_customers,
	COUNT(p.customer_key) AS retained_customers
FROM customers c
LEFT JOIN customers p
ON c.customer_key = p.customer_key
AND c.order_year = P.order_year + 1
GROUP BY c.order_year
)
SELECT
	order_year,
	total_customers,
	retained_customers,
	ROUND((CAST(retained_customers AS FLOAT)/NULLIF(LAG(total_customers) OVER(ORDER BY order_year), 0)) * 100, 2) AS retention_rate,
	ROUND((CAST((retained_customers) AS FLOAT)/total_customers) * 100, 2) AS pct_retained_customers,
	ROUND((CAST((total_customers - retained_customers) AS FLOAT)/total_customers) * 100, 2) AS pct_new_customers
FROM metrics;
