/*
========================================================================
Script    : 06_ranking_analysis.sql
Location  : 04_exploratory_data_analytics/
Author    : Otusanya Toyib Oluwatimilehin
Created   : 2026-04-17
========================================================================
Script Purpose:
	This script performs ranking analysis across key business dimensions,
	customers, countries, age groups, and products. It identifies top
	and bottom performers across multiple metrics (revenue, profit, and
	order volume) simultaneously, revealing whether high revenue rank 
	is consistent with high profit rank — or whether certain customers
	and products generate revenue at the expense of margin.

	At the product level, rankings are partitioned by category and
	subcategory to surface the best and worst performers within each
	segment, rather than globally. This enables targeted decisions on
	marketing investment, product discontinuation, and inventory 
	prioritisation for underperforming products.
========================================================================
*/
USE SalesDB;
GO

-- Who are our top 10 customers based on revenue?
WITH base_query AS
(
SELECT
	first_name,
	last_name,
	SUM(fo.sales_amount) AS total_sales,
	DENSE_RANK() OVER(ORDER BY SUM(fo.sales_amount) DESC) AS rank_sales
FROM gold.fact_orders fo
LEFT JOIN gold.dim_customers dc
ON fo.customer_key = dc.customer_key
GROUP BY 
	dc.customer_key,
	dc.first_name,
	dc.last_name
)
SELECT
	first_name,
	last_name,
	total_sales,
	rank_sales
FROM base_query
WHERE rank_sales <= 10;


-- Any deviation in profit rank from sales'?
WITH base_query AS
(
SELECT
	dc.first_name,
	dc.last_name,
	SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) AS total_profit,
	DENSE_RANK() OVER(ORDER BY SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) DESC) AS rank_profit
FROM gold.fact_orders fo
LEFT JOIN gold.dim_customers dc
ON fo.customer_key = dc.customer_key
LEFT JOIN gold.dim_products dp
ON fo.product_key = dp.product_key
GROUP BY
	dc.customer_key,
	dc.first_name,
	dc.last_name
)
SELECT
	first_name,
	last_name,
	total_profit,
	rank_profit
FROM base_query
WHERE rank_profit <= 10;


-- Who are our top 3 customers based on number of orders
WITH base_query AS
(
SELECT
	first_name,
	last_name,
	COUNT(DISTINCT fo.order_number) AS total_orders,
	DENSE_RANK() OVER(ORDER BY COUNT(DISTINCT fo.order_number) DESC) AS rank_orders
FROM gold.fact_orders fo
LEFT JOIN gold.dim_customers dc
ON fo.customer_key = dc.customer_key
GROUP BY 
	dc.customer_key,
	dc.first_name,
	dc.last_name
)
SELECT
	first_name,
	last_name,
	total_orders,
	rank_orders
FROM base_query
WHERE rank_orders <= 3;


-- Do our top revenue-generating customers have ranks consistent across other key metrics?
WITH base_query AS
(
SELECT
	dc.first_name,
	dc.last_name,
	SUM(fo.sales_amount) AS total_sales,
	SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) AS total_profit,
	COUNT(DISTINCT fo.order_number) AS total_orders,
	SUM(fo.sales_amount)/COUNT(DISTINCT fo.order_number) AS order_value
FROM gold.fact_orders fo
LEFT JOIN gold.dim_customers dc
ON fo.customer_key = dc.customer_key
LEFT JOIN gold.dim_products dp
ON fo.product_key = dp.product_key
GROUP BY
	dc.customer_key,
	dc.first_name,
	dc.last_name
)
, rank_metrics AS
(
SELECT
	first_name,
	last_name,
	total_sales,
	total_profit,
	total_orders,
	DENSE_RANK() OVER(ORDER BY total_sales DESC) AS rank_sales,
	DENSE_RANK() OVER(ORDER BY total_profit DESC) AS rank_profit,
	DENSE_RANK() OVER(ORDER BY total_orders DESC) AS rank_orders
FROM base_query
)
SELECT
	first_name,
	last_name,
	total_sales,
	total_profit,
	total_orders,
	rank_sales,
	rank_profit,
	rank_orders
FROM rank_metrics
WHERE rank_sales <= 10
ORDER BY rank_sales;



-- Who are our least performing customers based on revenue?
WITH base_query AS
(
SELECT
	dc.first_name,
	dc.last_name,
	SUM(fo.sales_amount) AS total_sales,
	SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) AS total_profit,
	COUNT(DISTINCT fo.order_number) AS total_orders,
	SUM(fo.sales_amount)/COUNT(DISTINCT fo.order_number) AS order_value
FROM gold.fact_orders fo
LEFT JOIN gold.dim_customers dc
ON fo.customer_key = dc.customer_key
LEFT JOIN gold.dim_products dp
ON fo.product_key = dp.product_key
GROUP BY
	dc.customer_key,
	dc.first_name,
	dc.last_name
)
, rank_metrics AS
(
SELECT
	first_name,
	last_name,
	total_sales,
	total_profit,
	total_orders,
	DENSE_RANK() OVER(ORDER BY total_sales) AS rank_sales,
	DENSE_RANK() OVER(ORDER BY total_profit) AS rank_profit,
	DENSE_RANK() OVER(ORDER BY total_orders) AS rank_orders
FROM base_query
)
SELECT
	first_name,
	last_name,
	total_sales,
	total_profit,
	total_orders,
	rank_sales,
	rank_profit,
	rank_orders
FROM rank_metrics
WHERE rank_sales <= 1
ORDER BY rank_sales;


-- What is the top revenue-generating country?
-- And are the ranks consistent across all key metrics?
SELECT
	dc.country,
	COUNT(DISTINCT fo.customer_key) AS total_customers,
	SUM(fo.sales_amount) AS total_sales,
	SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) AS total_profit,
	COUNT(DISTINCT fo.order_number) AS total_order,
	DENSE_RANK() OVER(ORDER BY COUNT(DISTINCT fo.customer_key) DESC) AS rank_customers,
	DENSE_RANK() OVER(ORDER BY SUM(fo.sales_amount) DESC) AS rank_sales,
	DENSE_RANK() OVER(ORDER BY SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) DESC) AS rank_profit,
	DENSE_RANK() OVER(ORDER BY COUNT(DISTINCT fo.order_number) DESC) AS rank_order
FROM gold.fact_orders fo  
LEFT JOIN gold.dim_customers dc
ON dc.customer_key = fo.customer_key
LEFT JOIN gold.dim_products dp
ON fo.product_key = dp.product_key
WHERE country <> 'N/A'
GROUP BY dc.country
ORDER BY rank_sales;


-- What are the top age groups by sales?
-- And is the rank consistent with other metrics?
WITH customer_age AS
(
SELECT
	customer_key,
	DATEDIFF(year, birth_date, GETDATE()) AS age
FROM gold.dim_customers
)
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
SELECT
	ag.age_group,
	COUNT(DISTINCT ag.customer_key) AS total_customers,
	SUM(fo.sales_amount) AS total_sales,
	SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) AS total_profit,
	COUNT(DISTINCT fo.order_number) AS total_orders,
	DENSE_RANK() OVER(ORDER BY COUNT(DISTINCT ag.customer_key) DESC) AS rank_customers,
	DENSE_RANK() OVER(ORDER BY SUM(fo.sales_amount) DESC) AS rank_sales,
	DENSE_RANK() OVER(ORDER BY SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) DESC) AS rank_profit,
	DENSE_RANK() OVER(ORDER BY COUNT(DISTINCT fo.order_number) DESC) AS rank_order
FROM age_group ag
LEFT JOIN gold.fact_orders fo
ON ag.customer_key = fo.customer_key
LEFT JOIN gold.dim_products dp
ON fo.product_key = dp.product_key
GROUP BY ag.age_group
ORDER BY rank_sales;


-- Within each category, what are the top 3 ranked subcategories based on revenue?
-- And how much do they differ from other metrics?
SELECT
	category,
	subcategory,
	total_sales,
	total_profit,
	total_orders,
	rank_sales,
	rank_profit,
	rank_orders
FROM
(
SELECT
	dp.category,
	dp.subcategory,
	SUM(fo.sales_amount) AS total_sales,
	SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) AS total_profit,
	COUNT(DISTINCT fo.order_number) AS total_orders,
	DENSE_RANK() OVER(PARTITION BY dp.category ORDER BY SUM(fo.sales_amount) DESC) AS rank_sales,
	DENSE_RANK() OVER(PARTITION BY dp.category ORDER BY SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) DESC) AS rank_profit,
	DENSE_RANK() OVER(PARTITION BY dp.category ORDER BY COUNT(DISTINCT fo.order_number) DESC) AS rank_orders
FROM gold.fact_orders fo
LEFT JOIN gold.dim_products dp
ON fo.product_key = dp.product_key
GROUP BY dp.category, dp.subcategory
)SUB
WHERE rank_sales <= 3
ORDER BY category, rank_sales;


-- Within each category & subcategory, what are the top ranked products based on revenue?
-- And how much do they differ from other metrics?
SELECT
	category,
	subcategory,
	product_name,
	total_sales,
	total_profit,
	total_orders,
	rank_sales,
	rank_profit,
	rank_orders
FROM
(
SELECT
	dp.category,
	dp.subcategory,
	dp.product_name,
	SUM(fo.sales_amount) AS total_sales,
	SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) AS total_profit,
	COUNT(DISTINCT fo.order_number) AS total_orders,
	DENSE_RANK() OVER(PARTITION BY dp.category, dp.subcategory ORDER BY SUM(fo.sales_amount) DESC) AS rank_sales,
	DENSE_RANK() OVER(PARTITION BY dp.category, dp.subcategory ORDER BY SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) DESC) AS rank_profit,
	DENSE_RANK() OVER(PARTITION BY dp.category, dp.subcategory ORDER BY COUNT(DISTINCT fo.order_number) DESC) AS rank_orders
FROM gold.fact_orders fo
LEFT JOIN gold.dim_products dp
ON fo.product_key = dp.product_key
GROUP BY dp.category, dp.subcategory, dp.product_name
)SUB
WHERE rank_sales = 1
ORDER BY category, subcategory, rank_sales;


-- What are the top 20 ranked products based on revenue?
-- And how much do they differ from other metrics?
SELECT
	product_name,
	total_sales,
	total_profit,
	total_orders,
	rank_sales,
	rank_profit,
	rank_orders
FROM
(
SELECT
	dp.product_name,
	SUM(fo.sales_amount) AS total_sales,
	SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) AS total_profit,
	COUNT(DISTINCT fo.order_number) AS total_orders,
	DENSE_RANK() OVER(ORDER BY SUM(fo.sales_amount) DESC) AS rank_sales,
	DENSE_RANK() OVER(ORDER BY SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) DESC) AS rank_profit,
	DENSE_RANK() OVER(ORDER BY COUNT(DISTINCT fo.order_number) DESC) AS rank_orders
FROM gold.fact_orders fo
LEFT JOIN gold.dim_products dp
ON fo.product_key = dp.product_key
GROUP BY dp.product_name
)SUB
WHERE rank_sales <= 20
ORDER BY rank_sales;


-- Within each category, what are the bottom 3 ranked subcategories based on revenue?
-- And how much do they differ from other metrics?
SELECT
	category,
	subcategory,
	total_sales,
	total_profit,
	total_orders,
	rank_sales,
	rank_profit,
	rank_orders
FROM
(
SELECT
	dp.category,
	dp.subcategory,
	SUM(fo.sales_amount) AS total_sales,
	SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) AS total_profit,
	COUNT(DISTINCT fo.order_number) AS total_orders,
	DENSE_RANK() OVER(PARTITION BY dp.category ORDER BY SUM(fo.sales_amount)) AS rank_sales,
	DENSE_RANK() OVER(PARTITION BY dp.category ORDER BY SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity)) AS rank_profit,
	DENSE_RANK() OVER(PARTITION BY dp.category ORDER BY COUNT(DISTINCT fo.order_number)) AS rank_orders
FROM gold.fact_orders fo
LEFT JOIN gold.dim_products dp
ON fo.product_key = dp.product_key
GROUP BY dp.category, dp.subcategory
)SUB
WHERE rank_sales <= 3
ORDER BY category, rank_sales;


-- Within each category & subcategory, which product has the lowest revenue?
SELECT
	category,
	subcategory,
	product_name,
	total_sales,
	total_profit,
	total_orders,
	rank_sales,
	rank_profit,
	rank_orders
FROM
(
SELECT
	dp.category,
	dp.subcategory,
	dp.product_name,
	SUM(fo.sales_amount) AS total_sales,
	SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) AS total_profit,
	COUNT(DISTINCT fo.order_number) AS total_orders,
	DENSE_RANK() OVER(PARTITION BY dp.category, dp.subcategory ORDER BY SUM(fo.sales_amount)) AS rank_sales,
	DENSE_RANK() OVER(PARTITION BY dp.category, dp.subcategory ORDER BY SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity)) AS rank_profit,
	DENSE_RANK() OVER(PARTITION BY dp.category, dp.subcategory ORDER BY COUNT(DISTINCT fo.order_number)) AS rank_orders
FROM gold.fact_orders fo
LEFT JOIN gold.dim_products dp
ON fo.product_key = dp.product_key
GROUP BY dp.category, dp.subcategory, dp.product_name
)SUB
WHERE rank_sales = 1
ORDER BY category, subcategory, rank_sales;


-- What are the bottom 20 ranked products based on revenue?
-- And how much do they differ from other metrics?
SELECT
	product_name,
	total_sales,
	total_profit,
	total_orders,
	rank_sales,
	rank_profit,
	rank_orders
FROM
(
SELECT
	dp.product_name,
	SUM(fo.sales_amount) AS total_sales,
	SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) AS total_profit,
	COUNT(DISTINCT fo.order_number) AS total_orders,
	DENSE_RANK() OVER(ORDER BY SUM(fo.sales_amount)) AS rank_sales,
	DENSE_RANK() OVER(ORDER BY SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity)) AS rank_profit,
	DENSE_RANK() OVER(ORDER BY COUNT(DISTINCT fo.order_number)) AS rank_orders
FROM gold.fact_orders fo
LEFT JOIN gold.dim_products dp
ON fo.product_key = dp.product_key
GROUP BY dp.product_name
)SUB
WHERE rank_sales <= 20
ORDER BY rank_sales;
