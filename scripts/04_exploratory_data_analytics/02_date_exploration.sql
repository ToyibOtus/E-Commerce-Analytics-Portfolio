/*
=====================================================================
Script    : 02_date_exploration.sql
Location  : 04_exploratory_data_analytics/
Author    : Otusanya Toyib Oluwatimilehin
Created   : 2026-04-17
=====================================================================
Script Purpose:
	This script performs date exploration. It provides insight into
	the years' worth of data for each gold view available in the
	database.
=====================================================================
*/
USE SalesDB;
GO

-- What is the date range of our transactional sales data?
SELECT
	MIN(YEAR(order_date)) AS first_order_year,
	MAX(YEAR(order_date)) AS last_order_year,
	MAX(YEAR(order_date)) - MIN(YEAR(order_date)) AS year_range
FROM gold.fact_orders;

-- Which individual years are represented in our sales data?
SELECT DISTINCT YEAR(order_date) AS order_year FROM gold.fact_orders WHERE order_date IS NOT NULL ORDER BY order_year;

-- What is the age range of our customer base?
SELECT
	DATEDIFF(year, MIN(birth_date), GETDATE()) AS oldest_age,
	DATEDIFF(year, MAX(birth_date), GETDATE()) AS youngest_age,
	DATEDIFF(year, MIN(birth_date), MAX(birth_date)) AS age_range
FROM gold.dim_customers;


-- How many years of customer records do we have?
SELECT
	MIN(YEAR(create_date)) AS earliest_year,
	MAX(YEAR(create_date)) AS latest_year,
	MAX(YEAR(create_date)) - MIN(YEAR(create_date)) AS year_range
FROM gold.dim_customers;


-- How many years of product catalogue history do we have?
SELECT
	MIN(YEAR([start_date])) AS earliest_year,
	MAX(YEAR([start_date])) AS latest_year,
	MAX(YEAR([start_date])) - MIN(YEAR([start_date])) AS year_range
FROM gold.dim_products;
