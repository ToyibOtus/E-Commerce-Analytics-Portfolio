/*
=====================================================================
Script    : 01_bronze_tables.sql
Location  : scripts/01_bronze/
Author    : Otusanya Toyib Oluwatimilehin
Created   : 2026-04-08
=====================================================================
Script Purpose:
	This script drops and recreates all bronze layer tables.
	Run this script to reset the bronze schema structure.
	
Tables Created:
	bronze.crm_cust_info
	bronze.crm_prd_info
	bronze.crm_sales_details
	bronze.erp_cust_az12
	bronze.erp_loc_a101
	bronze.erp_px_cat_g1v2

Warning:
	All existing data in bronze tables will be lost.
=====================================================================
*/
USE SalesDB;
GO

-- Drop table [bronze.crm_cust_info] if exists
DROP TABLE IF EXISTS bronze.crm_cust_info;

-- Create table [bronze.crm_cust_info]
CREATE TABLE bronze.crm_cust_info
(
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_first_name NVARCHAR(50),
	cst_last_name NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE
);
GO

-- Drop table [bronze.crm_prd_info] if exists
DROP TABLE IF EXISTS bronze.crm_prd_info;

-- Create table [bronze.crm_prd_info]
CREATE TABLE bronze.crm_prd_info
(
	prd_id INT,
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(250),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATE,
	prd_end_dt DATE
);
GO

-- Drop table [bronze.crm_sales_details] if exists
DROP TABLE IF EXISTS bronze.crm_sales_details;

-- Create table [bronze.crm_sales_details]
CREATE TABLE bronze.crm_sales_details
(
	sls_ord_num NVARCHAR(50),
	sls_prd_key NVARCHAR(50),
	sls_cust_id INT,
	sls_order_dt INT,
	sls_ship_dt INT,
	sls_due_dt INT,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT
);
GO

-- Drop table [bronze.erp_cust_az12] if exists
DROP TABLE IF EXISTS bronze.erp_cust_az12;

-- Create table [bronze.erp_cust_az12]
CREATE TABLE bronze.erp_cust_az12
(
	cid NVARCHAR(50),
	bdate DATE,
	gen NVARCHAR(50)
);
GO

-- Drop table [bronze.erp_loc_a101] if exists
DROP TABLE IF EXISTS bronze.erp_loc_a101;

-- Create table [bronze.erp_loc_a101]
CREATE TABLE bronze.erp_loc_a101
(
	cid NVARCHAR(50),
	cntry NVARCHAR(50)
);
GO

-- Drop table [bronze.erp_px_cat_g1v2] if exists
DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;

-- Create table [bronze.erp_px_cat_g1v2]
CREATE TABLE bronze.erp_px_cat_g1v2
(
	id NVARCHAR(50),
	cat NVARCHAR(50),
	subcat NVARCHAR(50),
	maintenance NVARCHAR(50)
);
GO
