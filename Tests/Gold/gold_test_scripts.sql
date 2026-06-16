/*
*******************************************************************************************
Quality Checks
*******************************************************************************************

Script Purpose: 
	Performs quality checks for key integrity in the gold layer after joins and enrichment. 
It includes checks for: 
		- Null or duplicate primary keys
		- Checks for information discrepenancies between systems. 
Usage Notes: 
	- Run after creating the gold layer view
	- Resolve any discrepancies found during check based on expected results 
*/


/*
*******************************************************
Check on gold.dim_customers view for duplication errors
*******************************************************
*/
-- Check information in duplicate gender column 
--Expectation: No conflicting information between tables
SELECT * FROM gold.dim_customers

SELECT distinct gender FROM gold.dim_customers
/*
************************************************
Quick check to ensure column order, data
************************************************
*/
SELECT * FROM gold.dim_customers	

SELECT * FROM gold.dim_products

SELECT * FROM gold.fact_sales

/*
************************************************
Foreign Key Integrity (Dimensions)
************************************************
*/
--gold.dim_customer key integrity 
SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
WHERE c.customer_key IS NULL 	

	--gold.dim_products key integrity 
SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL 
