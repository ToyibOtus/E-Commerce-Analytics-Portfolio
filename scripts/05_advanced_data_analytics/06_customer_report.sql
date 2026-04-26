/*
===============================================================================
Script    : 06_customer_report.sql
Location  : 04_advanced_data_analytics/
Author    : Otusanya Toyib Oluwatimilehin
Created   : 2026-04-25
===============================================================================
Script Purpose:
	This script creates the gold.customer_report view — a comprehensive
	customer analytics object that consolidates demographic, behavioural,
	and financial metrics for every customer. It applies two complementary
	segmentation models: a composite performance score (VIP/Regular/New)
	based on weighted PERCENT_RANK across orders, revenue, profit, lifespan
	and recency; and an RFM model using threshold-based scoring calibrated
	to the durable goods nature of the business. Key derived KPIs include
	average order value, average monthly spend, profit margin, and profit
	per quantity. Reference date: 2014-01-31.
===============================================================================
*/
USE SalesDB;
GO

CREATE OR ALTER VIEW gold.customer_report AS

-- Retrieve relevant columns from tables
WITH base_query AS
(
SELECT
	dc.customer_key,
	dc.customer_id,
	dc.customer_number,
	CONCAT_WS(' ', dc.first_name, dc.last_name) AS customer_name,
	dc.country,
	dc.gender,
	dc.marital_status,
	dc.birth_date,
	fo.order_number,
	fo.product_key,
	fo.order_date,
	fo.sales_amount,
	fo.quantity,
	fo.price,
	dp.cost
FROM gold.fact_orders fo
LEFT JOIN gold.dim_customers dc
ON fo.customer_key = dc.customer_key
LEFT JOIN gold.dim_products dp
ON fo.product_key = dp.product_key
WHERE fo.order_date IS NOT NULL
)
-- Retrieve customer metric profile
, customer_aggregations AS
(
SELECT
	customer_key,
	customer_id,
	customer_number,
	customer_name,
	country,
	gender,
	marital_status,
	birth_date,
	DATEDIFF(year, birth_date, '2014-01-31') AS age,
	MIN(order_date) AS first_order_date,
	MAX(order_date) AS last_order_date,
	DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan_month,
	DATEDIFF(month, MAX(order_date), '2014-01-31') AS recency_month,
	COUNT(DISTINCT product_key) AS total_products,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(quantity) AS total_quantity,
	SUM(sales_amount) AS total_sales,
	SUM(sales_amount) - SUM(cost * quantity) AS total_profit
FROM base_query
GROUP BY
	customer_key,
	customer_id,
	customer_number,
	customer_name,
	country,
	gender,
	marital_status,
	birth_date
)
-- Rank customers based on relevant key metrics
, customer_ranks AS
(
SELECT
	customer_key,
	customer_id,
	customer_number,
	customer_name,
	country,
	gender,
	marital_status,
	birth_date,
	age,
	first_order_date,
	last_order_date,
	lifespan_month,
	recency_month,
	total_products,
	total_orders,
	total_quantity,
	total_sales,
	total_profit,
	PERCENT_RANK() OVER(ORDER BY total_orders DESC) AS pct_rank_orders,
	PERCENT_RANK() OVER(ORDER BY total_sales DESC) AS pct_rank_sales,
	PERCENT_RANK() OVER(ORDER BY total_profit DESC) AS pct_rank_profit,
	PERCENT_RANK() OVER(ORDER BY lifespan_month DESC) AS pct_rank_lifespan,
	PERCENT_RANK() OVER(ORDER BY recency_month) AS pct_rank_recency
FROM customer_aggregations
)
-- Calculate performance metric
, performance_metric AS
(
SELECT
	customer_key,
	customer_id,
	customer_number,
	customer_name,
	country,
	gender,
	marital_status,
	birth_date,
	age,
	first_order_date,
	last_order_date,
	lifespan_month,
	recency_month,
	total_products,
	total_orders,
	total_quantity,
	total_sales,
	total_profit,
	ROUND(CAST((pct_rank_orders * 0.15) + (pct_rank_sales * 0.40) + (pct_rank_profit * 0.30) + 
	(pct_rank_lifespan * 0.10) + (pct_rank_recency * 0.05) AS FLOAT), 2) AS performance_metric
FROM customer_ranks
)
-- Segment customers into various segments based on performance metric
, customer_performance_segmentation AS
(
SELECT
	customer_key,
	customer_id,
	customer_number,
	customer_name,
	country,
	gender,
	marital_status,
	birth_date,
	age,
	first_order_date,
	last_order_date,
	lifespan_month,
	recency_month,
	total_products,
	total_orders,
	total_quantity,
	total_sales,
	total_profit,
	CASE
		WHEN performance_metric <= 0.30 THEN 'VIP'
		WHEN performance_metric <= 0.70 THEN 'Regular'
		ELSE 'New'
	END AS customer_status
FROM performance_metric
)
-- Atrribute rfm scores to customers
, customer_rfm_score AS
(
SELECT
	customer_key,
	customer_id,
	customer_number,
	customer_name,
	country,
	gender,
	marital_status,
	birth_date,
	age,
	first_order_date,
	last_order_date,
	lifespan_month,
	recency_month,
	total_products,
	total_orders,
	total_quantity,
	total_sales,
	total_profit,
	customer_status,
	CASE
		WHEN recency_month <= 3 THEN 5
		WHEN recency_month <= 12 THEN 4
		WHEN recency_month <= 24 THEN 3
		WHEN recency_month <= 36 THEN 2
		ELSE 1
	END AS r_score,
	CASE
		WHEN total_orders >= 16 THEN 5
		WHEN total_orders >= 5 THEN 4
		WHEN total_orders = 4 THEN 3
		WHEN total_orders = 3 THEN 2
		ELSE 1
	END AS f_score,
	CASE
		WHEN total_sales >= 10000 THEN 5
		WHEN total_sales >= 5000 THEN 4
		WHEN total_sales >= 1000 THEN 3
		WHEN total_sales >= 500 THEN 2
		ELSE 1
	END AS m_score
FROM customer_performance_segmentation
)
-- Segment customers based on rfm scores
, customer_rfm_segmentation AS
(
SELECT
	customer_key,
	customer_id,
	customer_number,
	customer_name,
	country,
	gender,
	marital_status,
	birth_date,
	age,
	first_order_date,
	last_order_date,
	lifespan_month,
	recency_month,
	total_products,
	total_orders,
	total_quantity,
	total_sales,
	total_profit,
	customer_status,
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
	END AS customer_rfm_segment
FROM customer_rfm_score
)
-- Retrieve valuable KPIs
SELECT
	customer_key,
	customer_id,
	customer_number,
	customer_name,
	country,
	gender,
	marital_status,
	customer_status,
	customer_rfm_segment,
	birth_date,
	age,
	CASE
		WHEN age < 20 THEN 'Below 20'
		WHEN age < 30 THEN '20-29'
		WHEN age < 40 THEN '30-39'
		WHEN age < 50 THEN '40-49'
		ELSE 'Above 49'
	END AS age_group,
	first_order_date,
	last_order_date,
	lifespan_month,
	recency_month,
	total_products,
	total_orders,
	total_quantity,
	total_sales,
	total_profit,
	CASE
		WHEN total_orders = 0 THEN 0
		ELSE total_sales/total_orders
	END AS avg_order_value,
	CASE
		WHEN lifespan_month = 0 THEN total_sales
		ELSE total_sales/lifespan_month 
	END AS avg_monthly_spend,
	CASE
		WHEN total_sales = 0 THEN 0
		ELSE ROUND((CAST(total_profit AS FLOAT)/total_sales) * 100, 2) 
	END AS percent_profit_margin,
	CASE
		WHEN total_orders = 0 THEN 0
		ELSE total_profit/total_orders 
	END AS avg_profit_per_order,
	CASE
		WHEN total_quantity = 0 THEN 0
		ELSE total_profit/total_quantity 
	END AS avg_profit_per_quantity
FROM customer_rfm_segmentation;
