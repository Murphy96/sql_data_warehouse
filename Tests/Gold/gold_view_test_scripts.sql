/*
*******************************************************************************************
Quality Check on DDL for Gold Layer
*******************************************************************************************

Script Purpose: 
	Performs quality checks for DDL integrity in the gold layer after joins and enrichment. 
It includes checks for: 
		- Column Names
		- Data Types
        - Max length
        - Nullibility 
Usage Notes: 
	- Run after creating the gold layer view
	- Resolve any discrepancies found during check based on expected results 
      this is the last check for data types found in the business ready data, 
      ensure accuracy. 
*/

/*
**************************************************************
Checks DDL for View gold.dim_customers
**************************************************************
*/
SELECT
    c.column_id,
    c.name AS column_name,
    t.name AS data_type,
    c.max_length,
    c.is_nullable
FROM sys.columns c
JOIN sys.types t
    ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID('DataWarehouse.gold.dim_customers')
ORDER BY c.column_id;

/*
**************************************************************
Checks DDL for View gold.dim_products
**************************************************************
*/

SELECT
    c.column_id,
    c.name AS column_name,
    t.name AS data_type,
    c.max_length,
    c.is_nullable
FROM sys.columns c
JOIN sys.types t
    ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID('DataWarehouse.gold.dim_products')
ORDER BY c.column_id;

/*
**************************************************************
Checks DDL for View gold.fact_sales
**************************************************************
*/

SELECT
    c.column_id,
    c.name AS column_name,
    t.name AS data_type,
    c.max_length,
    c.is_nullable
FROM sys.columns c
JOIN sys.types t
    ON c.user_type_id = t.user_type_id
WHERE c.object_id = OBJECT_ID('DataWarehouse.gold.fact_sales')
ORDER BY c.column_id;
