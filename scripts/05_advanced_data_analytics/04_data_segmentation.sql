/*
===============================================================================
Script    : 04_data_segmentation.sql
Location  : 04_advanced_data_analytics/
Author    : Otusanya Toyib Oluwatimilehin
Created   : 2026-04-21
===============================================================================
Script Purpose:
	This script performs multi-dimensional segmentation of both products and 
	customers. Products are segmented by composite performance score 
	(weighted PERCENT_RANK across orders, revenue, profit, lifespan and recency) 
	and by cost tier. 
	
	Customers are segmented using two complementary approaches — a composite
	performance score identifying VIP, Regular, and New customers, and an RFM 
	(Recency, Frequency, Monetary) model using threshold-based scoring calibrated 
	to the durable goods nature of the business. The final query joins both 
	customer segmentation models to surface cross-dimensional insights such as 
	VIP customers showing at-risk RFM signals.

	Reference date: 2014-01-31 (end of last observed month).
	GETDATE() avoided to preserve meaningful recency differentiation
	within the 2010-2014 observation window.
===============================================================================
*/
USE SalesDB;
GO

-- How many of our products are high performers?
WITH metrics AS
(
SELECT
	dp.product_name,
	COUNT(DISTINCT fo.order_number) AS total_orders,
	SUM(fo.sales_amount) AS total_sales,
	SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) AS total_profit,
	DATEDIFF(month, MIN(fo.order_date), MAX(fo.order_date)) AS lifespan,
	DATEDIFF(month, MAX(fo.order_date), '2014-01-31') AS recency
FROM gold.fact_orders fo
LEFT JOIN gold.dim_products dp
ON fo.product_key = dp.product_key
WHERE fo.order_date IS NOT NULL
GROUP BY dp.product_name
)
, rank_products AS
(
SELECT
	product_name,
	total_orders,
	total_sales,
	total_profit,
	lifespan,
	recency,
	PERCENT_RANK() OVER(ORDER BY total_orders DESC) AS pct_rank_orders,
	PERCENT_RANK() OVER(ORDER BY total_sales DESC) AS pct_rank_sales,
	PERCENT_RANK() OVER(ORDER BY total_profit DESC) AS pct_rank_profit,
	PERCENT_RANK() OVER(ORDER BY lifespan DESC) AS pct_rank_lifespan,
	PERCENT_RANK() OVER(ORDER BY recency) AS pct_rank_recency
FROM metrics
)
, performance_metric AS
(
SELECT
	product_name,
	total_orders,
	total_sales,
	total_profit,
	lifespan,
	recency,
	ROUND(CAST((pct_rank_orders * 0.15) + (pct_rank_sales * 0.40) + (pct_rank_profit * 0.30) + 
	(pct_rank_lifespan * 0.10) + (pct_rank_recency * 0.05) AS FLOAT), 2) AS performance_metric
FROM rank_products
)
SELECT
	product_name,
	total_orders,
	total_sales,
	total_profit,
	lifespan,
	recency,
	performance_metric,
	CASE
		WHEN performance_metric <= 0.30 THEN 'High Performer'
		WHEN performance_metric <= 0.70 THEN 'Mid Performer'
		ELSE 'Low Performer'
	END AS product_status
FROM performance_metric
ORDER BY performance_metric;


-- How are our products distributed across cost tiers?
SELECT
	product_name,
	CASE
		WHEN cost <= 100 THEN 'Low Cost Product'
		WHEN cost <= 500 THEN 'Mid Cost Product'
		WHEN cost <= 1000 THEN 'High Cost Product'
		ELSE 'Very High Cost Product'
	END AS product_cost_status
FROM gold.dim_products;


-- How many of our customers have ordered between 0 to 1 month?
-- Note: Reference date set to 2014-01-31 (end of last month in dataset)
-- GETDATE() avoided as it would compress all recency values into
-- a 147-183 month range, eliminating meaningful differentiation
WITH metrics AS
(
SELECT
	customer_key,
	DATEDIFF(month, MAX(order_date), '2014-01-31') AS recency_month
FROM gold.fact_orders
WHERE order_date IS NOT NULL
GROUP BY customer_key
)
, customer_segment AS
(
SELECT
	customer_key,
	recency_month,
	CASE 
		WHEN recency_month > 30 THEN 'Above 30 Months'
		WHEN recency_month > 20 AND recency_month <= 30 THEN '21-30 Months'
		WHEN recency_month > 10 AND recency_month <= 20 THEN '11-20 Months'
		WHEN recency_month > 5 AND recency_month <= 10 THEN '6-10 Months'
		WHEN recency_month > 1 AND recency_month <= 5 THEN '2-5 Months'
		ELSE '0-1 Month'
	END AS customer_recency_segment
FROM metrics
)
SELECT
	customer_recency_segment,
	COUNT(customer_key) AS total_customers
FROM customer_segment
GROUP BY customer_recency_segment
ORDER BY total_customers DESC;


-- Do most of our customers place 1 to 2 orders?
WITH metrics AS
(
SELECT
	customer_key,
	COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_orders
GROUP BY customer_key
)
, customer_segment AS
(
SELECT
	customer_key,
	total_orders,
	CASE
		WHEN total_orders >= 16 THEN 'Above 15 Orders'
		WHEN total_orders >= 5 THEN '5-15 Orders'
		WHEN total_orders = 4 THEN '4 Orders'
		WHEN total_orders = 3 THEN '3 Orders'
		ELSE '1-2 Orders'
	END AS customer_orders_segment
FROM metrics
)
SELECT
	customer_orders_segment,
	COUNT(customer_key) AS total_customers
FROM customer_segment
GROUP BY customer_orders_segment
ORDER BY total_customers DESC;


-- How many of our customers have generated more than $10,000
WITH metrics AS
(
SELECT
	customer_key,
	SUM(sales_amount) AS total_sales
FROM gold.fact_orders
GROUP BY customer_key
)
, customer_segment AS
(
SELECT
	customer_key,
	total_sales,
	CASE
		WHEN total_sales >= 10000 THEN '>= 10000'
		WHEN total_sales >= 5000 THEN '>= 5000'
		WHEN total_sales >= 1000 THEN '>= 1000'
		WHEN total_sales >= 500 THEN '>= 500'
		ELSE '< 500'
	END AS customer_sales_segment
FROM metrics
)
SELECT
	customer_sales_segment,
	COUNT(customer_key) AS total_customers
FROM customer_segment
GROUP BY customer_sales_segment
ORDER BY total_customers DESC;


-- Step 1: Compute composite performance segmentation and store in temp table
DROP TABLE IF EXISTS #performance_segment;

WITH metrics AS
(
SELECT
	dc.customer_key,
	CONCAT_WS(' ', dc.first_name, dc.last_name) AS customer_name,
	COUNT(DISTINCT fo.order_number) AS total_orders,
	SUM(fo.sales_amount) AS total_sales,
	SUM(fo.sales_amount) - SUM(dp.cost * fo.quantity) AS total_profit,
	DATEDIFF(month, MIN(fo.order_date), MAX(fo.order_date)) AS lifespan,
	DATEDIFF(month, MAX(fo.order_date), '2014-01-31') AS recency
FROM gold.fact_orders fo
LEFT JOIN gold.dim_customers dc
ON fo.customer_key = dc.customer_key
LEFT JOIN gold.dim_products dp
ON fo.product_key = dp.product_key
WHERE fo.order_date IS NOT NULL
GROUP BY dc.customer_key, CONCAT_WS(' ', dc.first_name, dc.last_name) 
)
, rank_customers AS
(
SELECT
	customer_key,
	customer_name,
	total_orders,
	total_sales,
	total_profit,
	lifespan,
	recency,
	PERCENT_RANK() OVER(ORDER BY total_orders DESC) AS pct_rank_orders,
	PERCENT_RANK() OVER(ORDER BY total_sales DESC) AS pct_rank_sales,
	PERCENT_RANK() OVER(ORDER BY total_profit DESC) AS pct_rank_profit,
	PERCENT_RANK() OVER(ORDER BY lifespan DESC) AS pct_rank_lifespan,
	PERCENT_RANK() OVER(ORDER BY recency) AS pct_rank_recency
FROM metrics
)
, performance_metric AS
(
SELECT
	customer_key,
	customer_name,
	total_orders,
	total_sales,
	total_profit,
	lifespan,
	recency,
	ROUND(CAST((pct_rank_orders * 0.15) + (pct_rank_sales * 0.40) + (pct_rank_profit * 0.30) + 
	(pct_rank_lifespan * 0.10) + (pct_rank_recency * 0.05) AS FLOAT), 2) AS performance_metric
FROM rank_customers
)
SELECT
	customer_key,
	customer_name,
	total_orders,
	total_sales,
	total_profit,
	lifespan,
	recency,
	CASE
		WHEN performance_metric <= 0.30 THEN 'VIP'
		WHEN performance_metric <= 0.70 THEN 'Regular'
		ELSE 'New'
	END AS customer_status
	INTO #performance_segment
FROM performance_metric;


-- Step 2: Compute RFM segmentation and store in temp table
DROP TABLE IF EXISTS #rfm_segment;

WITH rfm AS
(
SELECT
	dc.customer_key,
	CONCAT_WS(' ', dc.first_name, dc.last_name) AS customer_name,
	DATEDIFF(month, MAX(fo.order_date), '2014-01-31') AS recency_month,
	COUNT(DISTINCT fo.order_number) AS frequency,
	SUM(fo.sales_amount) AS monetary
FROM gold.fact_orders fo
LEFT JOIN gold.dim_customers dc
ON fo.customer_key = dc.customer_key
WHERE fo.order_date IS NOT NULL
GROUP BY dc.customer_key, CONCAT_WS(' ', dc.first_name, dc.last_name)
)
, rfm_score AS
(
SELECT	
	customer_key,
	customer_name,
	recency_month,
	frequency,
	monetary,
	CASE
		WHEN recency_month <= 3 THEN 5
		WHEN recency_month <= 12 THEN 4
		WHEN recency_month <= 24 THEN 3
		WHEN recency_month <= 36 THEN 2
		ELSE 1
	END AS r_score,
	CASE
		WHEN frequency >= 16 THEN 5
		WHEN frequency >= 5 THEN 4
		WHEN frequency = 4 THEN 3
		WHEN frequency = 3 THEN 2
		ELSE 1
	END AS f_score,
	CASE
		WHEN monetary >= 10000 THEN 5
		WHEN monetary >= 5000 THEN 4
		WHEN monetary >= 1000 THEN 3
		WHEN monetary >= 500 THEN 2
		ELSE 1
	END AS m_score
FROM rfm
)
SELECT
	customer_key,
	customer_name,
	recency_month,
	frequency,
	monetary,
	CASE
		WHEN (r_score >= 4) AND (f_score >= 3) AND (m_score >= 4) THEN 'Champion'
		WHEN (r_score >= 3) AND (f_score >= 2) AND (m_score >= 4) THEN 'High-Value Loyal Customer'
		WHEN (r_score >= 3) AND (f_score >= 2) AND (m_score = 3) THEN 'Mid-Value Loyal Customer'
		WHEN (r_score >= 3) AND (f_score >= 2) AND (m_score <= 2) THEN 'Low-Value Loyal Customer'
		WHEN ((r_score >= 3) AND (f_score = 1) AND (m_score >= 3)) OR ((r_score >= 4) AND (f_score = 1) AND (m_score <= 2)) THEN 'Potential Loyalist'
		WHEN ((r_score = 2) AND (f_score >= 1) AND (m_score >= 3)) OR ((r_score = 3) AND (f_score >= 1) AND (m_score <= 2)) THEN 'Needs Attention'
		WHEN (r_score = 1) AND (f_score >= 2) AND (m_score >= 4) THEN 'Cannot Lose Them'
		WHEN (r_score = 1) AND (f_score >= 2) THEN 'At risk Customers'
		WHEN (r_score >= 4) AND (f_score = 1) THEN 'Recent Customer'
		WHEN ((r_score = 1) AND (f_score = 1)) OR ((r_score <= 2) AND (f_score = 1) AND (m_score <= 2)) THEN 'Potentially Lost Customers'
	END AS customer_segment
	INTO #rfm_segment
FROM rfm_score rfm;


-- Step 3: Retrieve performance segment result
-- How many of our customers are VIPs
SELECT * FROM #performance_segment ORDER BY customer_status DESC;


-- Step 4: Retrieve rfm segment result
-- How many potentially lost customers do we have?
SELECT * FROM #rfm_segment ORDER BY customer_segment;


-- Step 3: Join the two materialised results
-- Which VIPs are showing at-risk RFM signals?
SELECT
	ps.customer_name,
	ps.lifespan,
	rs.recency_month,
	rs.frequency,
	rs.monetary,
	ps.customer_status,
	rs.customer_segment
FROM #performance_segment ps
LEFT JOIN #rfm_segment rs
ON ps.customer_key = rs.customer_key
ORDER BY customer_status DESC, customer_segment;


-- Summary: How are VIP/Regular/New customers distributed across RFM segments?
SELECT
	ps.customer_status,
	rs.customer_segment,
	COUNT(ps.customer_key) AS total_customers
FROM #performance_segment ps
LEFT JOIN #rfm_segment rs
ON ps.customer_key = rs.customer_key
GROUP BY ps.customer_status, rs.customer_segment
ORDER BY ps.customer_status DESC, total_customers DESC;


DROP TABLE IF EXISTS #performance_segment;
DROP TABLE IF EXISTS #rfm_segment;
