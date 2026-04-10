/*
=====================================================================
Script    : 01_silver_tables.sql
Location  : scripts/02_silver/
Author    : Otusanya Toyib Oluwatimilehin
Created   : 2026-04-10
=====================================================================
Script Purpose:
	This script drops and recreates all silver layer tables.
	Run this script to reset the silver schema structure.
	
Tables Created:
	silver.crm_cust_info
	silver.crm_prd_info
	silver.crm_sales_details
	silver.erp_cust_az12
	silver.erp_loc_a101
	silver.erp_px_cat_g1v2

Warning:
	All existing data in silver tables will be lost.
=====================================================================
*/
USE SalesDB;
GO

-- Drop table [silver.crm_cust_info] if exists
DROP TABLE IF EXISTS silver.crm_cust_info;

-- Create table [silver.crm_cust_info]
CREATE TABLE silver.crm_cust_info
(
	cst_id INT,
	cst_key NVARCHAR(50),
	cst_first_name NVARCHAR(50),
	cst_last_name NVARCHAR(50),
	cst_marital_status NVARCHAR(50),
	cst_gndr NVARCHAR(50),
	cst_create_date DATE,
	dwh_create_date DATETIME2(0) DEFAULT GETDATE()
);
GO

-- Drop table [silver.crm_prd_info] if exists
DROP TABLE IF EXISTS silver.crm_prd_info;

-- Create table [silver.crm_prd_info]
CREATE TABLE silver.crm_prd_info
(
	prd_id INT,
	cat_id NVARCHAR(50),
	prd_key NVARCHAR(50),
	prd_nm NVARCHAR(250),
	prd_cost INT,
	prd_line NVARCHAR(50),
	prd_start_dt DATE,
	prd_end_dt DATE,
	dwh_create_date DATETIME2(0) DEFAULT GETDATE()
);
GO

-- Drop table [silver.crm_sales_details] if exists
DROP TABLE IF EXISTS silver.crm_sales_details;

-- Create table [silver.crm_sales_details]
CREATE TABLE silver.crm_sales_details
(
	sls_ord_num NVARCHAR(50),
	sls_prd_key NVARCHAR(50),
	sls_cust_id INT,
	sls_order_dt DATE,
	sls_ship_dt DATE,
	sls_due_dt DATE,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT,
	dwh_create_date DATETIME2(0) DEFAULT GETDATE()
);
GO

-- Drop table [silver.erp_cust_az12] if exists
DROP TABLE IF EXISTS silver.erp_cust_az12;

-- Create table [silver.erp_cust_az12]
CREATE TABLE silver.erp_cust_az12
(
	cid NVARCHAR(50),
	bdate DATE,
	gen NVARCHAR(50),
	dwh_create_date DATETIME2(0) DEFAULT GETDATE()
);
GO

-- Drop table [silver.erp_loc_a101] if exists
DROP TABLE IF EXISTS silver.erp_loc_a101;

-- Create table [silver.erp_loc_a101]
CREATE TABLE silver.erp_loc_a101
(
	cid NVARCHAR(50),
	cntry NVARCHAR(50),
	dwh_create_date DATETIME2(0) DEFAULT GETDATE()
);
GO

-- Drop table [silver.erp_px_cat_g1v2] if exists
DROP TABLE IF EXISTS silver.erp_px_cat_g1v2;

-- Create table [silver.erp_px_cat_g1v2]
CREATE TABLE silver.erp_px_cat_g1v2
(
	id NVARCHAR(50),
	cat NVARCHAR(50),
	subcat NVARCHAR(50),
	maintenance NVARCHAR(50),
	dwh_create_date DATETIME2(0) DEFAULT GETDATE()
);
GO
