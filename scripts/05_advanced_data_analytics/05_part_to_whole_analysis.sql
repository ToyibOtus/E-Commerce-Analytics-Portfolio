/*
===============================================================================
Script    : 05_part_to_whole_analysis.sql
Location  : 04_advanced_data_analytics/
Author    : Otusanya Toyib Oluwatimilehin
Created   : 2026-04-24
===============================================================================
Script Purpose:
	This script performs part-to-whole analysis across multiple
	business dimensions — products, customers, categories, countries,
	and product lines. It quantifies proportional revenue contribution
	at each level and validates the Pareto principle across products
	and customers. A dual-model customer analysis combines composite
	performance segmentation (VIP/Regular/New) with RFM segmentation
	to surface cross-dimensional revenue concentration insights —
	specifically identifying which customer tiers contain at-risk or
	potentially lost segments and what share of total revenue they
	represent.
===============================================================================
*/
USE SalesDB;
GO

-- Is 20% of our products contributing to 80% of the total revenue?
WITH product_sales AS
(
SELECT
	dp.product_name,
	SUM(fo.sales_amount) AS total_sales
FROM gold.fact_orders fo
LEFT JOIN gold.dim_products dp
ON fo.product_key = dp.product_key
GROUP BY dp.product_name
)
, cumulative_metric AS
(
SELECT
	product_name,
	total_sales,
	SUM(total_sales) OVER(ORDER BY total_sales DESC) AS running_total_sales,
	ROW_NUMBER() OVER(ORDER BY total_sales DESC) AS product_count
FROM product_sales
)
SELECT
	product_name,
	total_sales,
	running_total_sales,
	product_count,
	ROUND((CAST(running_total_sales AS FLOAT)/SUM(total_sales) OVER()) * 100, 2) AS pct_sales_cont,
	ROUND((CAST(product_count AS FLOAT)/COUNT(product_name) OVER()) * 100, 2) AS pct_product_cont
FROM cumulative_metric;


-- Is 20% of our customers contributing to 80% of the total revenue?
WITH customer_sales AS
(
SELECT
	dc.customer_key,
	CONCAT_WS(' ', dc.first_name, dc.last_name) AS customer_name,
	SUM(fo.sales_amount) AS total_sales
FROM gold.fact_orders fo
LEFT JOIN gold.dim_customers dc
ON fo.customer_key = dc.customer_key
GROUP BY dc.customer_key, CONCAT_WS(' ', dc.first_name, dc.last_name)
)
, cumulative_metric AS
(
SELECT
	customer_name,
	total_sales,
	SUM(total_sales) OVER(ORDER BY total_sales DESC) AS running_total_sales,
	ROW_NUMBER() OVER(ORDER BY total_sales DESC) AS customer_count
FROM customer_sales
)
SELECT
	customer_name,
	total_sales,
	running_total_sales,
	customer_count,
	ROUND((CAST(running_total_sales AS FLOAT)/SUM(total_sales) OVER()) * 100, 2) AS pct_sales_cont,
	ROUND((CAST(customer_count AS FLOAT)/COUNT(customer_name) OVER()) * 100, 2) AS pct_customer_cont
FROM cumulative_metric;


-- Is 20% of subcategory of products contributing 80% to our total revenue? 
WITH metrics AS
(
SELECT
	dp.subcategory,
	SUM(fo.sales_amount) AS total_sales
FROM gold.fact_orders fo
LEFT JOIN gold.dim_products dp
ON fo.product_key = dp.product_key
GROUP BY dp.subcategory
)
, cumulative_metrics AS
(
SELECT
	subcategory,
	total_sales,
	SUM(total_sales) OVER(ORDER BY total_sales DESC) AS running_total_sales,
	ROW_NUMBER() OVER(ORDER BY total_sales DESC) AS product_count
FROM metrics
)
SELECT
	subcategory,
	total_sales,
	running_total_sales,
	product_count,
	ROUND((CAST(running_total_sales AS FLOAT)/SUM(total_sales) OVER()) * 100, 2) AS pct_subcat_cont,
	ROUND((CAST(product_count AS FLOAT)/COUNT(subcategory) OVER()) * 100, 2) AS pct_subcat_count
FROM cumulative_metrics;


-- Within each product_line, which category of product is purchased most?
-- And which generates the most revenue
-- Which product line drives almost 50% of revenue?
WITH metrics AS
(
SELECT
	dp.product_line,
	dp.category,
	COUNT(DISTINCT fo.order_number) AS total_orders,
	SUM(fo.quantity) AS total_quantity,
	SUM(fo.sales_amount) AS total_sales
FROM gold.fact_orders fo
LEFT JOIN gold.dim_products dp
ON fo.product_key = dp.product_key
GROUP BY dp.product_line, dp.category
)
SELECT
	product_line,
	category,
	total_orders,
	ROUND((CAST(total_orders AS FLOAT)/SUM(total_orders) OVER(PARTITION BY product_line)) * 100, 2) AS pct_orders_dist,
	total_quantity,
	ROUND((CAST(total_quantity AS FLOAT)/SUM(total_quantity) OVER(PARTITION BY product_line)) * 100, 2) AS pct_qty_dist,
	total_sales,
	ROUND((CAST(total_sales AS FLOAT)/SUM(total_sales) OVER(PARTITION BY product_line)) * 100, 2) AS pct_sales_dist,
	ROUND((CAST(total_sales AS FLOAT)/SUM(total_sales) OVER()) * 100, 2) AS overall_pct_sales_dist
FROM metrics
ORDER BY product_line, pct_orders_dist DESC;


-- Is over 90% of our revenue solely dependent on a category of product?
SELECT
	dp.category,
	SUM(fo.sales_amount) AS total_sales,
	ROUND((CAST(SUM(fo.sales_amount) AS FLOAT)/SUM(SUM(fo.sales_amount)) OVER()) * 100, 2) AS pct_sales_dist
FROM gold.fact_orders fo
LEFT JOIN gold.dim_products dp
ON fo.product_key = dp.product_key
GROUP BY dp.category
ORDER BY pct_sales_dist DESC;


-- Which country contributes most to revenue?
SELECT
	dc.country,
	SUM(fo.sales_amount) AS total_sales,
	ROUND((CAST(SUM(fo.sales_amount) AS FLOAT)/SUM(SUM(fo.sales_amount)) OVER()) * 100, 2) AS pct_sales_dist
FROM gold.fact_orders fo
LEFT JOIN gold.dim_customers dc
ON fo.customer_key = dc.customer_key
WHERE dc.country <> 'N/A'
GROUP BY dc.country
ORDER BY pct_sales_dist DESC;


-- How many of our customers haven't engaged with us for the past 30 months?
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
	COUNT(customer_key) AS total_customers,
	ROUND((CAST(COUNT(customer_key) AS FLOAT)/SUM(COUNT(customer_key)) OVER()) * 100, 2) AS pct_cust_dist
FROM customer_segment
GROUP BY customer_recency_segment
ORDER BY total_customers DESC;


-- Do most of our customers place 1 to 2 orders?
WITH metrics1 AS
(
SELECT
	customer_key,
	COUNT(DISTINCT order_number) AS total_orders
FROM gold.fact_orders
GROUP BY customer_key
)
, metrics2 AS
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
FROM metrics1
)
SELECT
	customer_orders_segment,
	COUNT(customer_key) AS total_customers,
	ROUND((CAST(COUNT(customer_key) AS FLOAT)/SUM(COUNT(customer_key)) OVER()) * 100, 2) AS pct_cust_dist
FROM metrics2
GROUP BY customer_orders_segment
ORDER BY pct_cust_dist DESC;


-- Are most of our customers low-revenue generating customers?
-- Are they the major contributors to the total revenue?
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
	COUNT(customer_key) AS total_customers,
	ROUND((CAST(COUNT(customer_key) AS FLOAT)/SUM(COUNT(customer_key)) OVER()) * 100, 2) AS pct_cust_dist,
	SUM(total_sales) AS total_sales,
	ROUND((CAST(SUM(total_sales) AS FLOAT)/SUM(SUM(total_sales)) OVER()) * 100, 2) AS pct_sales_dist
FROM customer_segment
GROUP BY customer_sales_segment
ORDER BY pct_sales_dist DESC;


-- Do most of our products generate less than $50,000 in revenue?
-- Do they contribute most to the total revenue?
WITH metrics AS
(
SELECT
	product_key,
	SUM(sales_amount) AS total_sales
FROM gold.fact_orders
GROUP BY product_key
)
, product_segment AS
(
SELECT
	product_key,
	total_sales,
	CASE
		WHEN total_sales >= 1000000 THEN '>= 1000000'
		WHEN total_sales >= 500000 THEN '>= 500000'
		WHEN total_sales >= 100000 THEN '>= 100000'
		WHEN total_sales >= 50000 THEN '>= 50000'
		ELSE '< 50000'
	END AS product_sales_segment
FROM metrics
)
SELECT
	product_sales_segment,
	COUNT(product_key) AS total_products,
	ROUND((CAST(COUNT(product_key) AS FLOAT)/SUM(COUNT(product_key)) OVER()) * 100, 2) AS pct_prd_dist,
	SUM(total_sales) AS total_sales,
	ROUND((CAST(SUM(total_sales) AS FLOAT)/SUM(SUM(total_sales)) OVER()) * 100, 2) AS pct_sales_dist
FROM product_segment
GROUP BY product_sales_segment
ORDER BY pct_sales_dist DESC;


-- How many of our products are high performers?
-- How much do they contribute to the total revenue?
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
, product_segmentation AS
(
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
)
SELECT
	product_status,
	COUNT(product_name) AS total_products,
	ROUND((CAST(COUNT(product_name) AS FLOAT)/SUM(COUNT(product_name)) OVER()) * 100, 2) AS pct_prd_dist,
	SUM(total_sales) AS total_sales,
	ROUND((CAST(SUM(total_sales) AS FLOAT)/SUM(SUM(total_sales)) OVER()) * 100, 2) AS pct_sales_cont
FROM product_segmentation
GROUP BY product_status
ORDER BY pct_sales_cont DESC;



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
-- How many of our customers are VIPs?
-- Is 80% of the total revenue contributed by VIPs?
SELECT 
	customer_status,
	COUNT(customer_key) AS total_customers,
	ROUND((CAST(COUNT(customer_key) AS FLOAT)/SUM(COUNT(customer_key)) OVER()) * 100, 2) AS pct_cust_dist,
	SUM(total_sales) AS total_sales,
	ROUND((CAST(SUM(total_sales) AS FLOAT)/SUM(SUM(total_sales)) OVER()) * 100, 2) AS pct_sales_cont
FROM #performance_segment
GROUP BY customer_status
ORDER BY pct_sales_cont DESC;


-- Step 4: Retrieve rfm segment result
-- How many potentially lost customers do we have?
-- Will the loss of these customers have a significant impact on the business?
SELECT 
	customer_segment,
	COUNT(customer_key) AS total_customers,
	ROUND((CAST(COUNT(customer_key) AS FLOAT)/SUM(COUNT(customer_key)) OVER()) * 100, 2) AS pct_cust_dist,
	SUM(monetary) AS total_sales,
	ROUND((CAST(SUM(monetary) AS FLOAT)/SUM(SUM(monetary)) OVER()) * 100, 2) AS pct_sales_cont
FROM #rfm_segment
GROUP BY customer_segment
ORDER BY pct_sales_cont DESC;


-- Step 5: How are VIP/Regular/New customers distributed across RFM segments?
-- How many VIPs need attention?
-- Can we afford to lose them?
SELECT
	ps.customer_status,
	rs.customer_segment,
	COUNT(ps.customer_key) AS total_customers,
	ROUND((CAST(COUNT(ps.customer_key) AS FLOAT)/SUM(COUNT(ps.customer_key)) OVER(PARTITION BY customer_status)) * 100, 2) AS pct_cust_dist,
	SUM(ps.total_sales) AS total_sales,
	ROUND((CAST(SUM(ps.total_sales) AS FLOAT)/SUM(SUM(ps.total_sales)) OVER(PARTITION BY customer_status)) * 100, 2) AS pct_sales_cont,
	ROUND((CAST(SUM(ps.total_sales) AS FLOAT)/SUM(SUM(ps.total_sales)) OVER()) * 100, 2) AS overall_pct_sales_cont
FROM #performance_segment ps
LEFT JOIN #rfm_segment rs
ON ps.customer_key = rs.customer_key
GROUP BY ps.customer_status, rs.customer_segment
ORDER BY ps.customer_status DESC, total_customers DESC;


DROP TABLE IF EXISTS #performance_segment;
DROP TABLE IF EXISTS #rfm_segment;
