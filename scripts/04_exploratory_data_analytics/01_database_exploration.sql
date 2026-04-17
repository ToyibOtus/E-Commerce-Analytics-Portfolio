/*
=====================================================================
Script    : 01_database_exploration.sql
Location  : 04_exploratory_data_analytics/
Author    : Otusanya Toyib Oluwatimilehin
Created   : 2026-04-17
=====================================================================
Script Purpose:
	This script explores relevant analytical objects, providing 
	insight into the number of analytical gold views present in the
	database as well as relevant information about them.

Gold Views Explored:
	gold.dim_customers
	gold.dim_products
	gold.fact_orders
=====================================================================
*/
USE SalesDB;
GO

-- Retrieve all analytical views from database
SELECT 
	TABLE_CATALOG,
	TABLE_SCHEMA,
	TABLE_NAME,
	TABLE_TYPE
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'gold' AND TABLE_TYPE = 'VIEW';

-- Retrieve all relevant information about gold views
SELECT 
	TABLE_CATALOG,
	TABLE_SCHEMA,
	TABLE_NAME,
	COLUMN_NAME,
	ORDINAL_POSITION,
	DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'gold';

-- Retrieve row counts of all gold views
SELECT COUNT(*) AS total_rows FROM gold.dim_customers;
SELECT COUNT(*) AS total_rows FROM gold.dim_products;
SELECT COUNT(*) AS total_rows FROM gold.fact_orders;
