/*
*****************************************************************
Silver Layer Test Scripts: crm_cust_info  
*****************************************************************
*/


-- Check primary key for NULLS or duplicate values
-- Expectation: No Result
SELECT 
cst_id,  
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id 
HAVING COUNT(*) >1 OR cst_id IS NULL


-- Check for Unwanted spaces 
--Expectation: No Results
SELECT cst_firstname 
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname)

SELECT cst_lastname 
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname)

--Check the consistency of values in low cardinality columns 

SELECT DISTINCT cst_gndr
FROM silver.crm_cust_info 

SELECT DISTINCT cst_marital_status 
FROM silver.crm_cust_info 

SELECT * FROM silver.crm_cust_info 


/*
*****************************************************************
Silver Layer Test Scripts: crm_prd_info 
*****************************************************************
*/
-- Check primary key for NULLS or duplicate values
-- Expectation: No Result
SELECT 
prd_id,  
COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id 
HAVING COUNT(*) >1 OR prd_id IS NULL


--Checks to see if new catagory is found in the erp table as key for future joins. 
	--prd_key column: first 5 characters make up catagory key, necessary as a key for future joins
	--seperator is a different character from the seperator in the erp data. 
-- Expectation: Limited Results 

SELECT
	prd_id, 
	prd_key, 
	REPLACE(SUBSTRING(prd_key, 1, 5), '-' , '_' ) AS cat_id, 
	prd_nm, 
	prd_cost, 
	prd_line, 
	prd_start_dt, 
	prd_end_dt
FROM silver.crm_prd_info
WHERE REPLACE(SUBSTRING(prd_key, 1, 5), '-' , '_' ) NOT IN
	(SELECT distinct id from bronze.erp_px_cat_g1v2)

--Checks for unwanted spaces in prd_nm column 
--Expectation: No Results 

SELECT prd_nm
FROM silver.crm_prd_info 
WHERE prd_nm != TRIM(prd_nm)

--Checks for NULLS or negative numbers in prd_cost column 
-- Expectation: No Results 

SELECT prd_cost
FROM silver.crm_prd_info 
WHERE prd_cost <0 OR prd_cost IS NULL

--Checks for data standardization & consistenct in low cardinality column prd_line
SELECT DISTINCT prd_line 
FROM silver.crm_prd_info 

--Checks prd_start_dt and prd_end_dt for invalid date orders
--Expectation: all end dates fall after associated start dates 

SELECT * 
FROM silver.crm_prd_info 
WHERE prd_end_dt < prd_start_dt 

/*
*****************************************************************
Silver Layer Test Scripts: crm_sale_details  
*****************************************************************
*/

--Checks sls_ord_num for extra spaces
-- Expectation: No results
SELECT * 
FROM silver.crm_sales_details 
WHERE sls_ord_num != TRIM(sls_ord_num)

--Checks sls_prd_key mapping onto key values of crm_prd_info 
--Expectation: No results 

SELECT *
FROM silver.crm_sales_details 
WHERE sls_prd_key NOT IN (SELECT prd_key FROM silver.crm_prd_info)

--Check for invalid dates--

/*
--Check for negatives or 0s
--Expectation: No results
SELECT 
sls_order_dt, 
sls_ship_dt,
sls_due_dt
FROM silver.crm_sales_details
WHERE sls_order_dt <=0 OR sls_ship_dt <=0 OR sls_due_dt<=0 --can't cast a negatives or 0 as a date

--Check for uniform formatting prior to cast
--Expectation: All should be 8 characters
SELECT 
sls_order_dt
FROM silver.crm_sales_details 
WHERE LEN(sls_order_dt) != 8

--Check for outliers by validating boundaries of the date range
--Expectation: no results 
SELECT 
sls_order_dt
FROM silver.crm_sales_details 
WHERE sls_order_dt>20300101 AND sls_order_dt<20000101

--Check integrity of date order, order date earlier than ship date
--Expectation: no results
SELECT
*
FROM silver.crm_sales_details 
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

*/

--^^ Once the date is properly formatted into the silver layer, this will throw an Operand Type Clash error


--Check data consistency: sales, quantity, price
----Sales = quanitiy * price
----Values must not be NULL, 0 or negative 

SELECT 
sls_sales,  
sls_quantity, 
sls_price
FROM silver.crm_sales_details 
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity <= 0 OR sls_price <= 0 
ORDER BY sls_sales, sls_quantity, sls_price

---These kind of issues need to be resolved with the experts on the source system or process

--Check the whole table 
SELECt * FROM silver.crm_sales_details

/*
*****************************************************************
Silver Layer Test Scripts: erp_cust_az12  
*****************************************************************
*/

--Checks key transformation integrity against crm_cust_info key 
--Expectation: no results 
SELECT 
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
	 ELSE cid 
END AS cid, 
bdate, 
gen 
FROM silver.erp_cust_az12
WHERE CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
	 ELSE cid 
END NOT IN (SELECT DISTINCT cst_key FROM silver.crm_cust_info)

--Check for out of range dates in bdate
--Expectation: No values for birthdays in future 

SELECT DISTINCT
bdate
FROM silver.erp_cust_az12
WHERE bdate < '1926-01-01' OR bdate > GETDATE()

--Check for standardization & consistency in low cardality columns
--Expectation: standard values (Male, Female, Unknown)

SELECT DISTINCT 
gen 
FROM silver.erp_cust_az12

SELECT * 
FROM silver.erp_cust_az12

/*
*****************************************************************
Silver Layer Test Scripts: erp_loc_a101  
*****************************************************************
*/

--Checks the key transformation of cid onto cst_key from crm_cust_info
SELECT 
cid  
FROM silver.erp_loc_a101
WHERE cid NOT IN (SELECT cst_key FROM silver.crm_cust_info)

--Checks for standardization and consistency in low cardinality column cntry
SELECT DISTINCT 
cntry
FROM silver.erp_loc_a101

/*
*****************************************************************
Silver Layer Test Scripts: erp_px_cat_g1v2 
*****************************************************************
*/

--Checks the key id against crm_prd_info 
--Expectation: limited results 
SELECT 
id, 
cat, 
subcat, 
maintenance
FROM bronze.erp_px_cat_g1v2
WHERE id NOT IN (SELECT cat_id FROM silver.crm_prd_info)

--Check for unwanted spaces
--Expectation: no results

SELECT * 
FROM silver.erp_px_cat_g1v2
WHERE LEN(cat) != LEN(TRIM(cat));

SELECT * 
FROM silver.erp_px_cat_g1v2
WHERE LEN(subcat) != LEN(TRIM(subcat));

SELECT * 
FROM silver.erp_px_cat_g1v2
WHERE LEN(maintenance) != LEN(TRIM(maintenance));

--Data standardization and consistency in low cardinality columns cat, subcat, maintenance 

SELECT DISTINCT
cat
FROM silver.erp_px_cat_g1v2;

SELECT DISTINCT
subcat
FROM silver.erp_px_cat_g1v2;

SELECT DISTINCT
maintenance
FROM silver.erp_px_cat_g1v2;

SELECT * FROM silver.erp_px_cat_g1v2