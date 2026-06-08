/*
*********************************************
Script for creating empty bronze layer tables
*********************************************

Purpose: 
Creates empty tables for the bronze layer following the naming conventions of tables named for their source systems 
and columns named for the columns from their source system. 

WARNING
**********************************************************************************************************************************
This script will drop tables if they exist, if data is present, it will be lost if this script is run, back up data before running
**********************************************************************************************************************************
*/



IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
	DROP TABLE bronze.crm_cust_info;
CREATE TABLE bronze.crm_cust_info(
	cst_id INT, 
	cst_key NVARCHAR(50), 
	cst_firstname NVARCHAR(50), 
	cst_lastname NVARCHAR(50), 
	cst_marital_status NVARCHAR(50), 
	cst_gndr NVARCHAR(50), 
	cst_create_date DATE
);

IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
	DROP TABLE bronze.crm_prd_info;
CREATE TABLE bronze.crm_prd_info(
	prd_id INT, 
	prd_key NVARCHAR(50), 
	prd_nm NVARCHAR(50), 
	prd_cost INT, 
	prd_line NVARCHAR(15),
	prd_start_dt DATE, 
	prd_end_dt DATE
);

IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
	DROP TABLE bronze.crm_sales_details;
CREATE TABLE bronze.crm_sales_details(
	sls_ord_num NVARCHAR(50), 
	sls_prd_key NVARCHAR(50), 
	sls_cust_id INT, 
	sls_order_dt DATE, 
	sls_ship_dt DATE, 
	sls_due_dt DATE, 
	sls_sales INT, 
	sls_quantity INT, 
	sls_price INT
);

IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
	DROP TABLE bronze.erp_cust_az12;
CREATE TABLE bronze.erp_cust_az12(
	cid NVARCHAR(50), 
	bdate DATE, 
	gen NVARCHAR (50)
);

IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
	DROP TABLE bronze.erp_loc_a101;
CREATE TABLE bronze.erp_loc_a101 (
	cid NVARCHAR(50), 
	cntry NVARCHAR(50)
);

IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
	DROP TABLE bronze.erp_px_cat_g1v2;
CREATE TABLE bronze.erp_px_cat_g1v2 (
	id NVARCHAR(50), 
	cat NVARCHAR(50), 
	subcat NVARCHAR(50), 
	maintenance NVARCHAR(50)
);
