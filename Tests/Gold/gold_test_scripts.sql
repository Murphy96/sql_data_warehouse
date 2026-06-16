--  Check information in duplicate gender column 
--In cases of data discrepancies, the crm source system is more accurate 
SELECT DISTINCT

	ci.cst_gndr, 
	ca.gen, 
	CASE WHEN ci.cst_gndr != 'Unknown' THEN ci.cst_gndr
	     ELSE COALESCE( ca. gen, 'Unknown')
	END AS new_gen

FROM silver.crm_cust_info ci 

LEFT JOIN silver.erp_cust_az12 ca
ON		  ci.cst_key = ca.cid 
LEFT JOIN silver.erp_loc_a101 la
ON		  ci.cst_key = la.cid
ORDER BY 1,2



SELECT * FROM gold.dim_customers

SELECT distinct gender FROM gold.dim_customers

SELECT * FROM gold.dim_products

SELECT * FROM gold.fact_sales

--Foreign Key Integrity (Dimensions)
SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL 


SELECT *
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
WHERE c.customer_key IS NULL 