/*
**************************************************************************
Customer Report
**************************************************************************

Purpose: 
	This report consolidates key customer metrics and behaviors. 

Hightlights the following: 

	1) Gathers essential fields such as names, ages, and transaction details. 
	2) Segments customers into catagories (VIP, Regular, New) and age groups. 
	3) Aggregates customer-level metrics: 
			- Total Orders
			- Total Sales
			- Total Quantity Purchased
			- Total Products
			- Lifespan (in months)
	4) Calculates the folling KPIs:
			- Recency (Months since last order)
			- Average Order Value
			- Average Monthly Spend 
*/

CREATE VIEW gold.report_customers AS

WITH base_query AS (

/*
--------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
--------------------------------------------------------------
*/

	SELECT 
		f.order_number, 
		f.product_key, 
		f.order_date, 
		f.sales_total, 
		f.quantity, 
		c.customer_key, 
		c.customer_number, 
		CONCAT(c.first_name, ' ', c.last_name) AS customer_name, 
		DATEDIFF(YEAR, c.birthdate, GETDATE()) AS age, 
		c.first_name, 
		c.last_name, 
		c.birthdate
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers c
	ON c.customer_key = f.customer_key 
	WHERE order_date IS NOT NULL
	) 
, customer_aggregation AS (

/*
------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at customer level
------------------------------------------------------------------
*/
	SELECT
		customer_key, 
		customer_number, 
		customer_name, 
		age, 
		COUNT(DISTINCT order_number) AS total_orders, 
		SUM(sales_total) AS total_sales, 
		SUM(quantity) AS total_quantity, 
		COUNT(DISTINCT product_key) AS total_products,  
		MAX(order_date) AS last_order, 
		DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
	FROM base_query
	GROUP BY 
		customer_key, 
		customer_number, 
		customer_name, 
		age
) 

SELECT 
	customer_key, 
	customer_number, 
	customer_name, 
	age, 
	CASE 
		WHEN age < 20 THEN 'Under 20'
		WHEN age BETWEEN 20 AND 29 THEN '20-29'
		WHEN age BETWEEN 30 AND 39 THEN '30-39'
		WHEN age BETWEEN 40 AND 49 THEN '40-49'
		WHEN age >=50 THEN '50 and above' 
		ELSE 'N/A'
	END age_group, 
	CASE 
		WHEN total_sales >= 5000 AND lifespan >=12 THEN 'VIP'
		WHEN total_sales < 5000 AND lifespan >12 THEN 'Regular'
		WHEN lifespan <12 THEN 'New' 
		ELSE 'N/A'
	END customer_segment, 
	last_order, 
	DATEDIFF(MONTH, last_order, GETDATE()) AS recency,
	total_orders, 
	total_sales, 
	total_quantity, 
	total_products,  
	lifespan,
	--Compute average order value (AVO)
	CASE WHEN total_orders = 0 THEN 0 
		 ELSE total_sales/total_orders 
	END AS avg_order_value,  
	
	--Compute average monthly spend 
	CASE WHEN lifespan = 0 THEN total_sales 
		 ELSE total_sales/lifespan 
	END avg_monthly_spend

FROM customer_aggregation 

