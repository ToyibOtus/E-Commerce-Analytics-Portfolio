/*
=====================================================================
Script    : 02_load_silver_layer.sql
Location  : scripts/02_silver/
Author    : Otusanya Toyib Oluwatimilehin
Created   : 2026-04-10
=====================================================================
Script Purpose:
	This script loads data from the bronze layer to the silver
	layer. Minor logging system is embedded in the script to track
	relevant ETL process such as load status and number of rows
	inserted.

Tables Loaded:
	silver.crm_cust_info
	silver.crm_prd_info
	silver.crm_sales_details
	silver.erp_cust_az12
	silver.erp_loc_a101
	silver.erp_px_cat_g1v2

Parameter: None

Usage: EXEC silver.load_silver_layer
=====================================================================
*/
USE SalesDB;
GO

CREATE OR ALTER PROCEDURE silver.load_silver_layer AS
BEGIN
	SET NOCOUNT ON;

	PRINT('======================================================');
	PRINT('LOADING SILVER LAYER');
	PRINT('======================================================');

	BEGIN TRY
		DECLARE @start_time DATETIME, @end_time DATETIME, @rows_loaded INT, @batch_start_time DATETIME, @batch_end_time DATETIME;

		SET @batch_start_time = GETDATE();


		PRINT('------------------------------------------------------');
		PRINT('Loading silver.crm_cust_info');
		PRINT('------------------------------------------------------');

		SET @start_time = GETDATE();

		PRINT('>> Truncating Table: silver.crm_cust_info');
		TRUNCATE TABLE silver.crm_cust_info;

		PRINT('>> Inserting Into Table: silver.crm_cust_info');
		WITH base_query AS
		(
		SELECT
			cst_id,
			cst_key,
			cst_first_name,
			cst_last_name,
			cst_marital_status,
			cst_gndr,
			cst_create_date,
			ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS recent_record
		FROM bronze.crm_cust_info
		WHERE cst_id IS NOT NULL
		)
		,data_transformations AS
		(
		SELECT
			cst_id,
			cst_key,
			CASE
				WHEN cst_first_name IS NULL THEN 'N/A'
				ELSE TRIM(cst_first_name)
			END AS cst_first_name,
			CASE
				WHEN cst_last_name IS NULL THEN 'N/A'
				ELSE TRIM(cst_last_name)
			END AS cst_last_name,
			CASE
				WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				ELSE 'N/A'
			END AS cst_marital_status,
			CASE
				WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				ELSE 'N/A'
			END AS cst_gndr,
			cst_create_date
		FROM base_query
		WHERE recent_record = 1
		)
		INSERT INTO silver.crm_cust_info
		(
			cst_id,
			cst_key,
			cst_first_name,
			cst_last_name,
			cst_marital_status,
			cst_gndr,
			cst_create_date
		)
		SELECT
			cst_id,
			cst_key,
			cst_first_name,
			cst_last_name,
			cst_marital_status,
			cst_gndr,
			cst_create_date
		FROM data_transformations;
		SET @rows_loaded = @@ROWCOUNT;
		SET @end_time = GETDATE();
		PRINT('>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds');
		PRINT('>> Rows Loaded: ' + CAST(@rows_loaded AS NVARCHAR));
		PRINT('>> Load Status: Success');


		PRINT('------------------------------------------------------');
		PRINT('Loading silver.crm_prd_info');
		PRINT('------------------------------------------------------');

		SET @start_time = GETDATE();

		PRINT('>> Truncating Table: silver.crm_prd_info');
		TRUNCATE TABLE silver.crm_prd_info;

		PRINT('>> Inserting Into Table: silver.crm_prd_info');
		WITH data_transformations AS
		(
		SELECT
			prd_id,
			REPLACE(SUBSTRING(TRIM(prd_key), 0, 6), '-', '_') AS cat_id,
			SUBSTRING(TRIM(prd_key), 7, LEN(prd_key)) AS prd_key,
			TRIM(prd_nm) AS prd_nm,
			prd_cost,
			CASE UPPER(TRIM(prd_line))
				WHEN 'M' THEN 'Mountain'
				WHEN 'R' THEN 'Road'
				WHEN 'S' THEN 'Other Sales'
				WHEN 'T' THEN 'Touring'
				ELSE 'N/A'
			END AS prd_line,
			prd_start_dt,
			CASE
				WHEN prd_end_dt < prd_start_dt THEN DATEADD(day, -1, LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt))
				ELSE prd_end_dt 
			END	AS prd_end_dt
		FROM bronze.crm_prd_info
		)
		INSERT INTO silver.crm_prd_info
		(
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		FROM data_transformations;
		SET @rows_loaded = @@ROWCOUNT;
		SET @end_time = GETDATE();
		PRINT('>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds');
		PRINT('>> Rows Loaded: ' + CAST(@rows_loaded AS NVARCHAR));
		PRINT('>> Load Status: Success');


		PRINT('------------------------------------------------------');
		PRINT('Loading silver.crm_sales_details');
		PRINT('------------------------------------------------------');

		SET @start_time = GETDATE();

		PRINT('>> Truncating Table: silver.crm_sales_details');
		TRUNCATE TABLE silver.crm_sales_details;

		PRINT('>> Inserting Into Table: silver.crm_sales_details');
		WITH data_transformations AS
		(
		SELECT
			TRIM(sls_ord_num) AS sls_ord_num,
			TRIM(sls_prd_key) AS sls_prd_key,
			sls_cust_id,
			CASE
				WHEN LEN(sls_order_dt) <> 8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS NVARCHAR) AS DATE)
			END AS sls_order_dt,
			CAST(CAST(sls_ship_dt AS NVARCHAR) AS DATE) AS sls_ship_dt,
			CAST(CAST(sls_due_dt AS NVARCHAR) AS DATE) AS sls_due_dt,
			CASE
				WHEN sls_sales IS NULL OR sls_sales <> sls_quantity * sls_price THEN ABS(sls_quantity * sls_price)
				ELSE sls_sales
			END AS sls_sales,
			sls_quantity,
			CASE 
				WHEN sls_price < 0 THEN ABS(sls_price)
				WHEN sls_price IS NULL THEN sls_sales / sls_quantity
				ELSE sls_price
			END AS sls_price
		FROM bronze.crm_sales_details
		)
		INSERT INTO silver.crm_sales_details
		(
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		FROM data_transformations;
		SET @rows_loaded = @@ROWCOUNT;
		SET @end_time = GETDATE();
		PRINT('>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds');
		PRINT('>> Rows Loaded: ' + CAST(@rows_loaded AS NVARCHAR));
		PRINT('>> Load Status: Success');


		PRINT('------------------------------------------------------');
		PRINT('Loading silver.erp_cust_az12');
		PRINT('------------------------------------------------------');

		SET @start_time = GETDATE();

		PRINT('>> Truncating Table: silver.erp_cust_az12');
		TRUNCATE TABLE silver.erp_cust_az12;

		PRINT('>> Inserting Into Table: silver.erp_cust_az12');
		WITH data_transformations AS
		(
		SELECT
			CASE
				WHEN TRIM(cid) LIKE ('NAS%') THEN SUBSTRING(TRIM(cid), 4, LEN(cid))
				ELSE TRIM(cid)
			END AS cid,
			CASE
				WHEN bdate > GETDATE() THEN NULL
				ELSE bdate
			END AS bdate,
			CASE
				WHEN gen IS NULL OR TRIM(gen) = '' THEN 'N/A'
				WHEN UPPER(gen) IN ('F', 'FEMALE') THEN 'Female'
				WHEN UPPER(gen) IN ('M', 'MALE') THEN 'Male'
				ELSE 'N/A'
			END AS gen
		FROM bronze.erp_cust_az12
		)
		INSERT INTO silver.erp_cust_az12
		(
			cid,
			bdate,
			gen
		)
		SELECT
			cid,
			bdate,
			gen
		FROM data_transformations;
		SET @rows_loaded = @@ROWCOUNT;
		SET @end_time = GETDATE();
		PRINT('>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds');
		PRINT('>> Rows Loaded: ' + CAST(@rows_loaded AS NVARCHAR));
		PRINT('>> Load Status: Success');


		PRINT('------------------------------------------------------');
		PRINT('Loading silver.erp_loc_a101');
		PRINT('------------------------------------------------------');

		SET @start_time = GETDATE();

		PRINT('>> Truncating Table: silver.erp_loc_a101');
		TRUNCATE TABLE silver.erp_loc_a101;

		PRINT('>> Inserting Into Table: silver.erp_loc_a101');
		WITH data_transformations AS
		(
		SELECT
			REPLACE(TRIM(cid), '-', '') AS cid,
			CASE
				WHEN UPPER(TRIM(cntry)) IN ('DE', 'GERMANY') THEN 'Germany'
				WHEN UPPER(TRIM(cntry)) IN ('USA', 'US', 'UNITED STATES') THEN 'United States'
				WHEN cntry IS NULL OR TRIM(cntry) = '' THEN 'N/A'
				ELSE cntry
			END AS cntry
		FROM bronze.erp_loc_a101
		)
		INSERT INTO silver.erp_loc_a101
		(
			cid,
			cntry
		)
		SELECT
			cid,
			cntry
		FROM data_transformations;
		SET @rows_loaded = @@ROWCOUNT;
		SET @end_time = GETDATE();
		PRINT('>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds');
		PRINT('>> Rows Loaded: ' + CAST(@rows_loaded AS NVARCHAR));
		PRINT('>> Load Status: Success');


		PRINT('------------------------------------------------------');
		PRINT('Loading silver.erp_px_cat_g1v2');
		PRINT('------------------------------------------------------');

		SET @start_time = GETDATE();

		PRINT('>> Truncating Table: silver.erp_px_cat_g1v2');
		TRUNCATE TABLE silver.erp_px_cat_g1v2;

		PRINT('>> Inserting Into Table: silver.erp_px_cat_g1v2');
		WITH data_transformations AS
		(
		SELECT
			TRIM(id) AS id,
			TRIM(cat) AS cat,
			TRIM(subcat) AS subcat,
			TRIM(maintenance) AS maintenance
		FROM bronze.erp_px_cat_g1v2
		)
		INSERT INTO silver.erp_px_cat_g1v2
		(
			id,
			cat,
			subcat,
			maintenance
		)
		SELECT
			id,
			cat,
			subcat,
			maintenance
		FROM data_transformations;
		SET @rows_loaded = @@ROWCOUNT;
		SET @end_time = GETDATE();
		PRINT('>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds');
		PRINT('>> Rows Loaded: ' + CAST(@rows_loaded AS NVARCHAR));
		PRINT('>> Load Status: Success');

		SET @batch_end_time = GETDATE();

		PRINT('======================================================');
		PRINT('LOADING SILVER LAYER COMPLETED');
		PRINT('======================================================');
		PRINT('Total Batch Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds');
		PRINT('------------------------------------------------------');
	END TRY

	BEGIN CATCH
		PRINT('======================================================');
		PRINT('AN ERROR OCCURRED LOADING SILVER LAYER');
		PRINT('Error Procedure: ' + ERROR_PROCEDURE());
		PRINT('Error Message: ' + ERROR_MESSAGE());
		PRINT('Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR));
		PRINT('Error State: ' + CAST(ERROR_STATE() AS NVARCHAR));
		PRINT('======================================================');

		THROW;
	END CATCH;
END;
