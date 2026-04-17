/*
=====================================================================
Script    : 03_dimension_exploration.sql
Location  : 04_exploratory_data_analytics/
Author    : Otusanya Toyib Oluwatimilehin
Created   : 2026-04-17
=====================================================================
Script Purpose:
	This script performs dimension exploration. It retrieves 
	relevant dimensions from each gold view, providing insight into
	product and customer profile.
=====================================================================
*/
USE SalesDB;
GO

-- How many countries does the business extend to?
SELECT COUNT(DISTINCT country) AS total_countries FROM gold.dim_customers;
SELECT DISTINCT country FROM gold.dim_customers;

-- How many unique genders exist?
SELECT COUNT(DISTINCT gender) AS total_genders FROM gold.dim_customers;
SELECT DISTINCT gender FROM gold.dim_customers;

-- How many unique marital status exist?
SELECT COUNT(DISTINCT marital_status) AS total_marital_status FROM gold.dim_customers;
SELECT DISTINCT marital_status FROM gold.dim_customers;

-- How many unique categories exist?
SELECT COUNT(DISTINCT category) AS total_categories FROM gold.dim_products;
SELECT DISTINCT category FROM gold.dim_products;

-- How many unique subcategories exist?
SELECT COUNT(DISTINCT subcategory) AS total_subcategories FROM gold.dim_products;
SELECT DISTINCT subcategory FROM gold.dim_products;

-- How many unique product lines exist?
SELECT COUNT(DISTINCT product_line) AS total_product_lines FROM gold.dim_products;
SELECT DISTINCT product_line FROM gold.dim_products;

-- How many unique products exist?
SELECT COUNT(DISTINCT product_name) AS total_products FROM gold.dim_products;
SELECT product_name FROM gold.dim_products;

-- Establish hierarchy between relevant fields
SELECT DISTINCT category, subcategory, product_name FROM gold.dim_products;

-- How many unique maintenance exists
SELECT COUNT(DISTINCT maintenance) AS total_maintenance FROM gold.dim_products;
SELECT DISTINCT maintenance FROM gold.dim_products;
