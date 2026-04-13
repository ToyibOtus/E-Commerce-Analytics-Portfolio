/*
=====================================================================
Script    : 01_gold_views.sql
Location  : scripts/03_gold/
Author    : Otusanya Toyib Oluwatimilehin
Created   : 2026-04-13
=====================================================================
Script Purpose:
	This script creates views over the silver layer that form the gold
	layer. It integrates data across sources, applies final business
	naming conventions, and exposes clean analytical objects for
	consumption in EDA and advanced analytics.

Views Created:
	gold.dim_customers
	gold.dim_products
	gold.fact_orders
=====================================================================
*/
USE SalesDB;
GO

-- Create or alter view [gold.dim_customers]
CREATE OR ALTER VIEW gold.dim_customers AS
SELECT
	ROW_NUMBER() OVER(ORDER BY ci.cst_id) AS customer_key,
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_first_name AS first_name,
	ci.cst_last_name AS last_name,
	la.cntry AS country,
	CASE
		WHEN ci.cst_gndr = 'N/A' AND ca.gen <> 'N/A' THEN ca.gen
		ELSE ci.cst_gndr
	END AS gender,
	ci.cst_marital_status AS marital_status,
	ca.bdate AS birth_date,
	ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid;
GO

-- Create or alter view [gold.dim_products]
CREATE OR ALTER VIEW gold.dim_products AS
SELECT
	ROW_NUMBER() OVER(ORDER BY pn.prd_id) AS product_key,
	pn.prd_id AS product_id,
	pn.prd_key AS product_number,
	pn.prd_nm AS product_name,
	pn.prd_line AS product_line,
	pn.cat_id AS category_id,
	CASE
		WHEN cg.cat IS NULL THEN 'N/A'
		ELSE cg.cat
	END AS category,
	CASE
		WHEN cg.subcat IS NULL THEN 'N/A'
		ELSE cg.subcat
	END AS subcategory,
	CASE
		WHEN cg.maintenance IS NULL THEN 'N/A'
		ELSE cg.maintenance
	END AS maintenance,
	pn.prd_cost AS cost,
	pn.prd_start_dt AS [start_date]
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 cg
ON pn.cat_id = cg.id
WHERE pn.prd_end_dt IS NULL;
GO

-- Create or alter view [gold.fact_orders]
CREATE OR ALTER VIEW gold.fact_orders AS
SELECT
	sd.sls_ord_num AS order_number,
	dp.product_key,
	dc.customer_key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS ship_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales_amount,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_customers dc
ON sd.sls_cust_id = dc.customer_id
LEFT JOIN gold.dim_products dp
ON sd.sls_prd_key = dp.product_number;
GO
