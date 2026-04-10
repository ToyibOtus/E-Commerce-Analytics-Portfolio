/*
=====================================================================
Script    : 02_load_bronze_layer.sql
Location  : scripts/01_bronze/
Author    : Otusanya Toyib Oluwatimilehin
Created   : 2026-04-09
=====================================================================
Script Purpose:
	This script loads data from the source system into the bronze
	layer. Minor logging system is embedded in the script to track
	relevant ETL process such as load status and number of rows
	inserted.

Tables Loaded:
	bronze.crm_cust_info
	bronze.crm_prd_info
	bronze.crm_sales_details
	bronze.erp_cust_az12
	bronze.erp_loc_a101
	bronze.erp_px_cat_g1v2

Parameter: None

Usage: EXEC bronze.load_bronze_layer
=====================================================================
*/
USE SalesDB;
GO

CREATE OR ALTER PROCEDURE bronze.load_bronze_layer AS
BEGIN
	SET NOCOUNT ON;

	PRINT('======================================================');
	PRINT('LOADING BRONZE LAYER                                  ');
	PRINT('======================================================');

	BEGIN TRY
		DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME, @rows_loaded INT;

		SET @batch_start_time = GETDATE();

		PRINT('------------------------------------------------------');
		PRINT('Loading bronze.crm_cust_info                          ');
		PRINT('------------------------------------------------------');

		SET @start_time = GETDATE();
		PRINT('>> Truncating Table: bronze.crm_cust_info');
		TRUNCATE TABLE bronze.crm_cust_info;

		PRINT('>> Inserting Into Table: bronze.crm_cust_info');
		BULK INSERT bronze.crm_cust_info FROM 'C:\sales_data\source_crm\cust_info.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT('>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds');
		SELECT @rows_loaded = COUNT(*) FROM bronze.crm_cust_info;
		PRINT('>> Rows Loaded: ' + CAST(@rows_loaded AS NVARCHAR));
		PRINT('>> Load Status: Success');

		PRINT('------------------------------------------------------');
		PRINT('Loading bronze.crm_prd_info                           ');
		PRINT('------------------------------------------------------');

		SET @start_time = GETDATE();
		PRINT('>> Truncating Table: bronze.crm_prd_info');
		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT('>> Inserting Into Table: bronze.crm_prd_info');
		BULK INSERT bronze.crm_prd_info FROM 'C:\sales_data\source_crm\prd_info.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT('>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds');
		SELECT @rows_loaded = COUNT(*) FROM bronze.crm_prd_info;
		PRINT('>> Rows Loaded: ' + CAST(@rows_loaded AS NVARCHAR));
		PRINT('>> Load Status: Success');

		PRINT('------------------------------------------------------');
		PRINT('Loading bronze.crm_sales_details                      ');
		PRINT('------------------------------------------------------');

		SET @start_time = GETDATE();
		PRINT('>> Truncating Table: bronze.crm_sales_details');
		TRUNCATE TABLE bronze.crm_sales_details;

		PRINT('>> Inserting Into Table: bronze.crm_sales_details');
		BULK INSERT bronze.crm_sales_details FROM 'C:\sales_data\source_crm\sales_details.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT('>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds');
		SELECT @rows_loaded = COUNT(*) FROM bronze.crm_sales_details;
		PRINT('>> Rows Loaded: ' + CAST(@rows_loaded AS NVARCHAR));
		PRINT('>> Load Status: Success');

		PRINT('------------------------------------------------------');
		PRINT('Loading bronze.erp_cust_az12                          ');
		PRINT('------------------------------------------------------');

		SET @start_time = GETDATE();
		PRINT('>> Truncating Table: bronze.erp_cust_az12');
		TRUNCATE TABLE bronze.erp_cust_az12;

		PRINT('>> Inserting Into Table: bronze.erp_cust_az12');
		BULK INSERT bronze.erp_cust_az12 FROM 'C:\sales_data\source_erp\CUST_AZ12.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT('>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds');
		SELECT @rows_loaded = COUNT(*) FROM bronze.erp_cust_az12;
		PRINT('>> Rows Loaded: ' + CAST(@rows_loaded AS NVARCHAR));
		PRINT('>> Load Status: Success');

		PRINT('------------------------------------------------------');
		PRINT('Loading bronze.erp_loc_a101                           ');
		PRINT('------------------------------------------------------');

		SET @start_time = GETDATE();
		PRINT('>> Truncating Table: bronze.erp_loc_a101');
		TRUNCATE TABLE bronze.erp_loc_a101;

		PRINT('>> Inserting Into Table: bronze.erp_loc_a101');
		BULK INSERT bronze.erp_loc_a101 FROM 'C:\sales_data\source_erp\LOC_A101.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT('>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds');
		SELECT @rows_loaded = COUNT(*) FROM bronze.erp_loc_a101;
		PRINT('>> Rows Loaded: ' + CAST(@rows_loaded AS NVARCHAR));
		PRINT('>> Load Status: Success');

		PRINT('------------------------------------------------------');
		PRINT('Loading bronze.erp_px_cat_g1v2                        ');
		PRINT('------------------------------------------------------');

		SET @start_time = GETDATE();
		PRINT('>> Truncating Table: bronze.erp_px_cat_g1v2');
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		PRINT('>> Inserting Into Table: bronze.erp_px_cat_g1v2');
		BULK INSERT bronze.erp_px_cat_g1v2 FROM 'C:\sales_data\source_erp\PX_CAT_G1V2.csv'
		WITH
		(
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT('>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds');
		SELECT @rows_loaded = COUNT(*) FROM bronze.erp_px_cat_g1v2;
		PRINT('>> Rows Loaded: ' + CAST(@rows_loaded AS NVARCHAR));
		PRINT('>> Load Status: Success');

		SET @batch_end_time = GETDATE();

		PRINT('======================================================');
		PRINT('LOADING BRONZE LAYER COMPLETED                        ');
		PRINT('======================================================');
		PRINT('Total Batch Duration: ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' seconds');
		PRINT('------------------------------------------------------');
	END TRY

	BEGIN CATCH
		PRINT('======================================================');
		PRINT('AN ERROR OCCURRED LOADING BRONZE LAYER');
		PRINT('Error Procedure: ' + ERROR_PROCEDURE());
		PRINT('Error Message: ' + ERROR_MESSAGE());
		PRINT('Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR));
		PRINT('Error State: ' + CAST(ERROR_STATE() AS NVARCHAR));
		PRINT('======================================================');

		THROW;
	END CATCH;
END;
