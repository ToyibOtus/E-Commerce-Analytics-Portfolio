/*
=====================================================================
Script    : 01_data_quality_checks.sql
Location  : tests/
Author    : Otusanya Toyib Oluwatimilehin
Created   : 2026-04-10
=====================================================================
Script Purpose:
	This script checks for data quality issues prior to 
	data integration in the gold layer.

Tables Checked:
	silver.crm_cust_info
	silver.crm_prd_info
	silver.crm_sales_details
	silver.erp_cust_az12
	silver.erp_loc_a101
	silver.erp_px_cat_g1v2

Note:
	Ensure all expectations are met before building the gold layer.
=====================================================================
*/
USE SalesDB;
GO

-- ============================================================
-- Data quality checks on silver.crm_cust_info
-- ============================================================

-- Check for duplicates & nulls in primary key
-- Expectation: No Result
SELECT
	cst_id,
	COUNT(*) AS duplicate_chk
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING cst_id IS NULL OR COUNT(*) > 1;

-- Check if there are customer keys that don't correspond to customer_id
-- Expectation: No Result
SELECT
	cst_id,
	cst_key,
	SUBSTRING(cst_key, 6, LEN(cst_key)) AS id
FROM silver.crm_cust_info
WHERE cst_id <> SUBSTRING(cst_key, 6, LEN(cst_key));

-- Check for unwanted spaces in string fields
-- Expectation: No Result
SELECT
	cst_key
FROM silver.crm_cust_info
WHERE cst_key <> TRIM(cst_key);

SELECT
	cst_first_name
FROM silver.crm_cust_info
WHERE cst_first_name <> TRIM(cst_first_name);

SELECT
	cst_last_name
FROM silver.crm_cust_info
WHERE cst_last_name <> TRIM(cst_last_name);


-- Check for unwanted values in string fields
-- Expectation: No Result
SELECT
	cst_key
FROM silver.crm_cust_info
WHERE cst_key IS NULL OR cst_key NOT LIKE ('AW000%');

SELECT
	cst_first_name
FROM silver.crm_cust_info
WHERE cst_first_name IS NULL OR TRIM(cst_first_name) = '';  

SELECT
	cst_last_name
FROM silver.crm_cust_info
WHERE cst_last_name IS NULL OR TRIM(cst_last_name) = ''; 


-- Data Standardization & Consistency on low cardinality string fields
-- Expectation: User-friendly values and no NULLs
SELECT DISTINCT 
	cst_marital_status
FROM silver.crm_cust_info;

SELECT DISTINCT 
	cst_gndr
FROM silver.crm_cust_info;


-- Check for invalid create date
-- Expectation: No Result
SELECT
	cst_create_date
FROM silver.crm_cust_info
WHERE cst_create_date > GETDATE();



-- ============================================================
-- Data quality checks on silver.crm_prd_info
-- ============================================================

-- Check for duplicates & nulls in primary key
-- Expectation: No Result
SELECT
	prd_id,
	COUNT(*) AS duplicate_chk
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING prd_id IS NULL OR COUNT(*) > 1;


-- Check for unwanted spaces in high cardinality string fields
-- Expectation: No Result
SELECT
	prd_key
FROM silver.crm_prd_info
WHERE prd_key <> TRIM(prd_key);

SELECT
	prd_nm
FROM silver.crm_prd_info
WHERE prd_nm <> TRIM(prd_nm);


-- Check for unwanted values in high cardinality string fields
-- Expectation: No Result
SELECT
	prd_key
FROM silver.crm_prd_info
WHERE TRIM(prd_key) = '';

SELECT
	prd_nm
FROM silver.crm_prd_info
WHERE TRIM(prd_nm) = '' OR prd_nm IS NULL;


-- Check for invalid product cost
-- Expectation: NULLs Only
SELECT
	prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;


-- Data Standardization & Consistency in Low Cardinality Fields
-- Expectation: User-Friendly values & no NULLs
SELECT DISTINCT
	prd_line
FROM silver.crm_prd_info;


-- Check for invalid dates
-- Expectation: No Result
SELECT
	prd_start_dt,
	prd_end_dt
FROM silver.crm_prd_info
WHERE prd_start_dt > prd_end_dt;


-- ============================================================
-- Data quality checks on silver.crm_sales_details
-- ============================================================

-- Check for unwanted spaces in high cardinality string fields
-- Expectation: No Result
SELECT
	sls_ord_num
FROM silver.crm_sales_details
WHERE sls_ord_num <> TRIM(sls_ord_num);

SELECT
	sls_prd_key
FROM silver.crm_sales_details
WHERE sls_prd_key <> TRIM(sls_prd_key);


-- Check for unwanted values in high cardinality string fields
-- Expectation: No Result
SELECT
	sls_ord_num
FROM silver.crm_sales_details
WHERE sls_ord_num IS NULL OR TRIM(sls_ord_num) = '';

SELECT
	sls_prd_key
FROM silver.crm_sales_details
WHERE sls_prd_key IS NULL OR TRIM(sls_prd_key) = '';


-- Check for invalid products
-- Expectation: No Result
SELECT sls_prd_key FROM silver.crm_sales_details WHERE sls_prd_key NOT IN
(SELECT prd_key FROM silver.crm_prd_info);

-- Check for invalid customers
-- Expectation: No Result
SELECT sls_cust_id FROM silver.crm_sales_details  WHERE sls_cust_id NOT IN
(SELECT cst_id FROM silver.crm_cust_info);

SELECT sls_cust_id FROM silver.crm_sales_details  WHERE sls_cust_id IS NULL;


-- Check for invalid dates
-- Expectation: No Result
SELECT
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_ship_dt > sls_due_dt OR
sls_order_dt > GETDATE() OR sls_ship_dt > GETDATE() OR sls_due_dt > GETDATE();


-- Check for invalid metrics
-- Expectation: No Result
SELECT
	sls_sales,
	sls_quantity,
	sls_price
FROM silver.crm_sales_details
WHERE sls_sales IS NULL OR sls_sales <= 0 OR sls_sales <> sls_quantity * sls_price OR
sls_quantity IS NULL OR sls_quantity <= 0 OR sls_quantity <> sls_sales / sls_price OR
sls_price IS NULL OR sls_price <= 0 OR sls_price <> sls_sales / sls_quantity;


-- ============================================================
-- Data quality checks on silver.erp_cust_az12
-- ============================================================

-- Check for nulls & duplicates in primary key
-- Expectation: No Result
SELECT
	cid,
	COUNT(*) AS duplicate_chk
FROM silver.erp_cust_az12
GROUP BY cid
HAVING cid IS NULL OR COUNT(*) > 1;


-- Check for unwanted spaces in high cardinality string fields
-- Expectation: No Result
SELECT
	cid
FROM silver.erp_cust_az12
WHERE cid <> TRIM(cid);


-- Check for invalid customers
-- Expectation: No Result
SELECT cid FROM silver.erp_cust_az12 WHERE cid NOT IN
(SELECT cst_key FROM silver.crm_cust_info);


-- Check for unwanted values in high cardinality string fields
-- Expectation: No Result
SELECT
	cid
FROM silver.erp_cust_az12
WHERE cid LIKE ('NAS%') OR TRIM(cid) = ''
ORDER BY cid;


-- Check for invalid birth date
-- Expectation: No Result
SELECT
	bdate
FROM silver.erp_cust_az12
WHERE bdate > GETDATE();


-- Data Standardization & Consistency on Low Cardinality String Fields
-- Expectation: User-Friendly Values & No NULLs
SELECT DISTINCT
	gen
FROM silver.erp_cust_az12;


-- ============================================================
-- Data quality checks on silver.erp_loc_a101
-- ============================================================

-- Check for nulls & duplicates in primary key
-- Expectation: No Result
SELECT
	cid,
	COUNT(*) AS duplicate_chk
FROM silver.erp_loc_a101
GROUP BY cid
HAVING cid IS NULL OR COUNT(*) > 1;


-- Check for invalid customers
-- Expectation: No Result
SELECT cid FROM silver.erp_loc_a101 WHERE cid NOT IN
(SELECT cst_key FROM silver.crm_cust_info);


-- Check for unwanted spaces in high cardinality string fields
-- Expectation: No Result
SELECT
	cid
FROM silver.erp_loc_a101
WHERE cid <> TRIM(cid);


-- Check for unwanted values in high cardinality string fields
-- Expectation: No Result
SELECT
	cid
FROM silver.erp_loc_a101
WHERE TRIM(cid) = '' OR cid LIKE ('%-%');


-- Data Standardization & Consistency on Low Cardinality String Fields
-- Expectation: User-Friendly Values & No NULLs
SELECT DISTINCT
	cntry
FROM silver.erp_loc_a101
ORDER BY cntry;


-- ============================================================
-- Data quality checks on silver.erp_px_cat_g1v2
-- ============================================================

-- Check for nulls & duplicates in primary key
-- Expectation: No Result
SELECT
	id,
	COUNT(*) AS duplicate_chk
FROM silver.erp_px_cat_g1v2
GROUP BY id
HAVING id IS NULL OR COUNT(*) > 1;


-- Check for unwanted spaces in high cardinality string fields
-- Expectation: No Result
SELECT
	id
FROM silver.erp_px_cat_g1v2
WHERE id <> TRIM(id);


-- Check for unwanted values in string fields
-- Expectation: No Result
SELECT
	id
FROM silver.erp_px_cat_g1v2
WHERE TRIM(id) = '';


-- Data Standardization & Consistency in Low Cardinality String Fields
-- Expectation: User-Friendly Values & No NULLs
SELECT DISTINCT
	cat
FROM silver.erp_px_cat_g1v2;

SELECT DISTINCT
	subcat
FROM silver.erp_px_cat_g1v2;

SELECT DISTINCT
	maintenance
FROM silver.erp_px_cat_g1v2;
