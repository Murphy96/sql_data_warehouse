/*
*********************************************************************************************************************
Stored Procedure for Bronze Layer Data Load (Source -> Bronze)
*********************************************************************************************************************
Purpose: 
  Creates a stored procedure for loading raw data from CSV files into the Bronze Layer
  
Preforms the following actions: 
    - Truncates bronze tables before loading data
    - Uses BULK INSERT to load data from CSV files to bronze tables. 
    - Uses PRINT for error handling, duration tracking for load to identify bottlenecks, 
      optimize performance, monitor trends, and dectect issues on load printed in messages 

Parameters: 
  None, this stored procedure does not accept any parameters or return any values 

Usage Exmple: 
  EXEC bronze.load_bronze;

*/

-- Error handling, duration tracking to identify bottlenecks, optimize performance, monitor trends and detect issues 

CREATE or ALTER PROCEDURE bronze.load_bronze AS

BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME; 
	DECLARE @global_start_time DATETIME, @global_end_time DATETIME; 
	BEGIN TRY

		PRINT'****************************************************************';
		PRINT('                  Loading Bronze Layer');
		PRINT'****************************************************************';
		/*
		******************************************************************************************
		Bulk load of data from CRM system 
		******************************************************************************************
		*/

	
		SET @global_start_time = GETDATE();
		PRINT('Loading CRM Data');
		PRINT'****************************************************************';

		--loading data from cust_info.csv--
		SET @start_time = GETDATE();
		PRINT '>>Truncating Table: bronze.crm_cust_info'
		TRUNCATE TABLE bronze.crm_cust_info; 

		PRINT '>>Inserting Data Into Table: bronze.crm_cust_info'
		BULK INSERT bronze.crm_cust_info 
		FROM 'Data_Sets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2, 
			FIELDTERMINATOR = ',', 
			TABLOCK

		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '--------------------------------'
		--loading data from prd_info.csv--
		SET @start_time = GETDATE();
		PRINT '>>Truncating Table: bronze.crm_prd_info'
		TRUNCATE TABLE bronze.crm_prd_info; 

		PRINT '>>Inserting Data Into Table: bronze.crm_prd_info'
		BULK INSERT bronze.crm_prd_info 
		FROM 'Data_Sets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2, 
			FIELDTERMINATOR = ',', 
			TABLOCK

		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '--------------------------------'
		--loading data from sales_details.csv--
		SET @start_time = GETDATE();
		PRINT '>>Truncating Table: bronze.crm_sales_details'
		TRUNCATE TABLE bronze.crm_sales_details; 

		PRINT '>>Inserting Data Into Table: bronze.crm_sales_details'
		BULK INSERT bronze.crm_sales_details
		FROM 'Data_Sets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2, 
			FIELDTERMINATOR = ',', 
			TABLOCK

		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '--------------------------------'
		/*
		******************************************************************************************
		Bulk load of data from ERP system 
		******************************************************************************************
		*/
		
	
		PRINT('Loading ERP Data');
		PRINT'****************************************************************';


		--loading data from CUST_AZ12.csv--
		SET @start_time = GETDATE();
		PRINT '>>Truncating Table: bronze.erp_cust_az12'
		TRUNCATE TABLE bronze.erp_cust_az12; 

		PRINT '>>Inserting Data Into Table: bronze.erp_cust_az12'
		BULK INSERT bronze.erp_cust_az12
		FROM 'Data_Sets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2, 
			FIELDTERMINATOR = ',', 
			TABLOCK

		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '--------------------------------'
		--loading data from LOC_A101.csv--
		SET @start_time = GETDATE();
		PRINT '>>Truncating Table: bronze.erp_loc_a101'
		TRUNCATE TABLE bronze.erp_loc_a101; 

		PRINT '>>Inserting Data Into Table: bronze.erp_loc_a101'
		BULK INSERT bronze.erp_loc_a101
		FROM 'Data_Sets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2, 
			FIELDTERMINATOR = ',', 
			TABLOCK

		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '--------------------------------'
		--loading data from PX_CAT_G1V2.csv--

		SET @start_time = GETDATE();
		PRINT '>>Truncating Table: bronze.erp_px_cat_g1v2'
		TRUNCATE TABLE bronze.erp_px_cat_g1v2; 

		PRINT '>>Inserting Data Into Table: bronze.erp_px_cat_g1v2'
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'Data_Sets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2, 
			FIELDTERMINATOR = ',', 
			TABLOCK

		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + 'seconds';
		PRINT '--------------------------------'
		
		PRINT'****************************************************************';
		PRINT('                  Bronze Layer Load Complete');
		PRINT'****************************************************************';
		
		SET @global_end_time = GETDATE();
		PRINT '>> Bronze Layer Load Duration: ' + CAST(DATEDIFF(second, @global_start_time, @global_end_time) AS NVARCHAR) + 'seconds';
	END TRY
	BEGIN CATCH
		PRINT '******************************************************************'; 
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'; 
		PRINT 'Error Message' + ERROR_MESSAGE(); 
		PRINT 'Error Message' + CAST(ERROR_NUMBER() AS NVARCHAR);  
		PRINT 'Error Message' + CAST(ERROR_STATE() AS NVARCHAR);  
		PRINT '******************************************************************'; 
	END CATCH
END
