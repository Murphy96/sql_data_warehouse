/*
**************************************************************************
Product Report
**************************************************************************

Purpose: 
	This report consolidates key product metrics and behaviors. 

Hightlights the following: 

	1) Gathers essential fields such as product name, catagory, subcatagory, and cost. 
	2) Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers. 
	3) Aggregates product-level metrics: 
			- Total Orders
			- Total Sales
			- Total Quantity Sold
			- Total Customers (unique) 
			- Lifespan (in months)
	4) Calculates the folling KPIs:
			- Recency (Months since last sale)
			- Average Order Revenue (AOR)
			- Average Monthly Revenue 
*/

CREATE VIEW gold.report_products AS 

WITH base_query AS (
/*--------------------------------------------------------------------
1) Base Query: Retrieves core columns from fact_sales and dim_products 
*/--------------------------------------------------------------------

SELECT 
	f.order_number, 
	f.order_date, 
	f.customer_key, 
	f.sales_total, 
	f.quantity, 
	p.product_name,
	p.product_key, 
	p.catagory, 
	p.subcatagory, 
	p.product_cost 
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p
ON f.product_key = p.product_key
WHERE order_date IS NOT NULL 
),

 product_aggregations AS (
/*--------------------------------------------------------------------
2) Product Aggregations: Summerizes key metrics at product level 
*/--------------------------------------------------------------------

SELECT 
	product_key, 
	product_name, 
	catagory, 
	subcatagory, 
	product_cost,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan, 
	MAX(order_date) AS last_sale_date, 
	COUNT(DISTINCT order_number) AS total_orders, 
	COUNT(DISTINCT customer_key) AS total_customers, 
	SUM(sales_total) AS total_sales, 
	SUM(quantity) AS total_quantity, 
	ROUND(AVG(CAST(sales_total AS FLOAT)/NULLIF(quantity, 0)), 1) AS avg_selling_price
	
FROM base_query 
GROUP BY 
	product_key,
	product_name, 
	catagory, 
	subcatagory, 
	product_cost
)

/*--------------------------------------------------------------------
3) Final Query: Combines all product results to one output  
*/--------------------------------------------------------------------

SELECT
	product_key, 
	product_name, 
	catagory,
	subcatagory, 
	product_cost, 
	last_sale_date, 
	DATEDIFF(MONTH, last_sale_date, GETDATE()) AS recency_in_months, 
	CASE
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END AS product_segment, 
	lifespan, 
	total_orders, 
	total_sales, 
	total_quantity, 
	total_customers, 
	avg_selling_price, 
	--Average Order Revenue (AOR)
	CASE
		WHEN total_orders = 0 THEN 0 
		ELSE total_sales/total_orders
	END avg_order_revenue,
	-- Average Monthly Revenue 
	CASE
		WHEN lifespan = 0 THEN total_sales
		ELSE total_sales/lifespan
	END avg_monthly_revenue 

FROM product_aggregations 

