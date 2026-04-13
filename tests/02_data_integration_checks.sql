/*
=====================================================================
Script    : 02_data_integration_checks.sql
Location  : tests/
Author    : Otusanya Toyib Oluwatimilehin
Created   : 2026-04-13
=====================================================================
Script Purpose:
	This script performs data integration checks on all analytical
	views.

Views Checked:
	gold.dim_customers
	gold.dim_products
	gold.fact_orders

Note:
	Ensure that all expectations are met prior to data consumption.
=====================================================================
*/
USE SalesDB;
GO

-- Check for NULLs in surrogate keys
-- Expectation: No Result
SELECT customer_key FROM gold.dim_customers
WHERE customer_key IS NULL;

SELECT product_key FROM gold.dim_products
WHERE product_key IS NULL;

SELECT product_key, customer_key FROM gold.fact_orders
WHERE product_key IS NULL OR customer_key IS NULL;


-- Check for duplicates in surrogate keys
-- Expectation: No Result
SELECT
	customer_key,
	COUNT(*) AS duplicate_chk
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

SELECT
	product_key,
	COUNT(*) AS duplicate_chk
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;


-- Retrieve row counts in gold tables
-- Expectation: Non-zero counts
SELECT COUNT(*) AS total_rows FROM gold.dim_customers;
SELECT COUNT(*) AS total_rows FROM gold.dim_products;
SELECT COUNT(*) AS total_rows FROM gold.fact_orders;


-- Check for broken joins
-- Expectation: No Result
SELECT 
	fo.order_number, 
	fo.product_key, 
	dp.product_key, 
	fo.customer_key,
	dc.customer_key 
FROM gold.fact_orders fo
LEFT JOIN gold.dim_products dp
ON fo.product_key = dp.product_key
LEFT JOIN gold.dim_customers dc
ON fo.customer_key = dc.customer_key
WHERE fo.product_key IS NOT NULL AND dp.product_key IS NULL
OR fo.customer_key IS NOT NULL AND dc.customer_key IS NULL;
