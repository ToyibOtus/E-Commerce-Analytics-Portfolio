/*
===============================================================================
Script    : 07_product_report.sql
Location  : 04_advanced_data_analytics/
Author    : Otusanya Toyib Oluwatimilehin
Created   : 2026-04-26
===============================================================================
Script Purpose:
	This script creates the gold.product_report view — a comprehensive
	product analytics object that consolidates transactional, financial,
	and lifecycle metrics for every active product.

	Three segmentation dimensions are applied:

	1. Composite Performance Score — a weighted PERCENT_RANK score
	   across five metrics: orders (15%), revenue (40%), profit (30%),
	   lifespan (10%), and recency (5%). Products are classified as
	   High Performer (score <= 0.30), Mid Performer (score <= 0.70),
	   or Low Performer (score > 0.70).

	2. Cost Tier — products are classified by unit cost into four
	   tiers: Low (<= $100), Mid (<= $500), High (<= $1,000), and
	   Very High (> $1,000), enabling pricing strategy analysis
	   across the product catalogue.

	3. Profit Margin Status — thresholds are anchored to the actual
	   margin distribution rather than absolute profitability benchmarks.
	   Since every active product generates a positive margin (range:
	   22.22% to 75.00%, mean: 44.04%, CV: 27.93%), traditional labels
	   such as "Unprofitable" are not applicable. Instead, products are
	   classified relative to catalogue performance using statistical
	   boundary points — P25 (36.30%), mean (44.04%), and P75 (50.00%):
	    
		*	Below 36.30%  → Low Margin
		*	36.30 - 44.04 → Below Average Margin
		*	44.04 - 50.00 → Above Average Margin
		*	Above 50.00%  → High Margin

	Key derived KPIs: average order revenue, average monthly revenue,
	profit margin percentage, average profit per order, average profit
	per quantity, and average shipping days. Reference date: 2014-01-31.
===============================================================================
*/
USE SalesDB;
GO

CREATE OR ALTER VIEW gold.product_report AS

-- Retrieve relevant columns from tables
WITH base_query AS
(
SELECT 
	dp.product_key,
	dp.product_id,
	dp.product_name,
	dp.product_line,
	dp.category,
	dp.subcategory,
	dp.maintenance,
	dp.cost,
	fo.order_number,
	fo.customer_key,
	fo.order_date,
	fo.ship_date,
	fo.sales_amount,
	fo.quantity,
	fo.price
FROM gold.fact_orders fo
LEFT JOIN gold.dim_products dp
ON fo.product_key = dp.product_key
WHERE fo.order_date IS NOT NULL
)
-- Retrieve product metric profile
, product_aggregation AS
(
SELECT
	product_key,
	product_id,
	product_name,
	product_line,
	category,
	subcategory,
	maintenance,
	cost,
	MIN(order_date) AS first_order_date,
	MAX(order_date) AS last_order_date,
	AVG(DATEDIFF(day, order_date, ship_date)) AS avg_shipping_days,
	DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan_month,
	DATEDIFF(month, MAX(order_date), '2014-01-31') AS recency_month,
	COUNT(DISTINCT customer_key) AS total_customers,
	COUNT(DISTINCT order_number) AS total_orders,
	SUM(quantity) AS total_quantity,
	SUM(sales_amount) AS total_sales,
	SUM(sales_amount) - SUM(cost * quantity) AS total_profit,
	SUM(sales_amount)/SUM(quantity) AS weighted_avg_price
FROM base_query
GROUP BY
	product_key,
	product_id,
	product_name,
	product_line,
	category,
	subcategory,
	maintenance,
	cost
)
-- Rank products based on relevant key metrics
, product_ranks AS
(
SELECT
	product_key,
	product_id,
	product_name,
	product_line,
	category,
	subcategory,
	maintenance,
	cost,
	first_order_date,
	last_order_date,
	avg_shipping_days,
	lifespan_month,
	recency_month,
	total_customers,
	total_orders,
	total_quantity,
	total_sales,
	total_profit,
	weighted_avg_price,
	PERCENT_RANK() OVER(ORDER BY total_orders DESC) AS pct_rank_orders,
	PERCENT_RANK() OVER(ORDER BY total_sales DESC) AS pct_rank_sales,
	PERCENT_RANK() OVER(ORDER BY total_profit DESC) AS pct_rank_profit,
	PERCENT_RANK() OVER(ORDER BY lifespan_month DESC) AS pct_rank_lifespan,
	PERCENT_RANK() OVER(ORDER BY recency_month) AS pct_rank_recency
FROM product_aggregation
)
-- Calculate performance metric
, product_performance_metric AS
(
SELECT
	product_key,
	product_id,
	product_name,
	product_line,
	category,
	subcategory,
	maintenance,
	cost,
	first_order_date,
	last_order_date,
	avg_shipping_days,
	lifespan_month,
	recency_month,
	total_customers,
	total_orders,
	total_quantity,
	total_sales,
	total_profit,
	weighted_avg_price,
	ROUND(CAST((pct_rank_orders * 0.15) + (pct_rank_sales * 0.40) + (pct_rank_profit * 0.30) + 
	(pct_rank_lifespan * 0.10) + (pct_rank_recency * 0.05) AS FLOAT), 2) AS performance_metric
FROM product_ranks
)
-- Segment products into various categories based on performance and cost, respectively
, product_segmentation AS
(
SELECT
	product_key,
	product_id,
	product_name,
	product_line,
	category,
	subcategory,
	maintenance,
	cost,
	first_order_date,
	last_order_date,
	avg_shipping_days,
	lifespan_month,
	recency_month,
	total_customers,
	total_orders,
	total_quantity,
	total_sales,
	total_profit,
	weighted_avg_price,
	CASE
		WHEN performance_metric <= 0.30 THEN 'High Performer'
		WHEN performance_metric <= 0.70 THEN 'Mid Performer'
		ELSE 'Low Performer'
	END AS product_performance_status,
	CASE
		WHEN cost <= 100 THEN 'Low Cost Product'
		WHEN cost <= 500 THEN 'Mid Cost Product'
		WHEN cost <= 1000 THEN 'High Cost Product'
		ELSE 'Very High Cost Product'
	END AS product_cost_status,
	CASE
		WHEN total_sales = 0 THEN 'No Sales'
		WHEN CAST(total_profit AS FLOAT)/total_sales * 100 < 36.30 THEN 'Low Margin'
		WHEN CAST(total_profit AS FLOAT)/total_sales * 100 < 44.04 THEN 'Below Average Margin'
		WHEN CAST(total_profit AS FLOAT)/total_sales * 100 < 50.00 THEN 'Above Average Margin'
    ELSE 'High Margin'
	END AS profit_margin_status
FROM product_performance_metric
)
-- Retrieve valuable KPIs
SELECT
	product_key,
	product_id,
	product_name,
	product_line,
	category,
	subcategory,
	maintenance,
	product_performance_status,
	profit_margin_status,
	product_cost_status,
	cost,
	first_order_date,
	last_order_date,
	avg_shipping_days,
	lifespan_month,
	recency_month,
	total_customers,
	total_orders,
	total_quantity,
	total_sales,
	total_profit,
	weighted_avg_price,
	CASE
		WHEN total_orders = 0 THEN 0
		ELSE total_sales/total_orders
	END AS avg_order_revenue,
	CASE
		WHEN lifespan_month = 0 THEN total_sales
		ELSE total_sales/lifespan_month 
	END AS avg_monthly_revenue,
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
FROM product_segmentation;
