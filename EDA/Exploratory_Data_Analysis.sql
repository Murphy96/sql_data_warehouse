/*
***************************************************************************************************************
Scripts for Exploratory Data Analysis (Run on Gold Layer)
***************************************************************************************************************
Purpose: 
	A collection of scripts for performing 5 major catagories of Exploratory Data Analysis (EDA)

Performs the following explorations: 	
 	1) Dimension Exploration
	2) Date Exploration
	3) Measures Exploration 
	4) Magnitude Exploration 
	5) Ranking Exploration 

Usage: 
	This file is a collection of independent scripts. The file is not meant for producing a single report. For best 
	performance, run each query seperately, as needed. 

*/



/*
*********************************
Dimension Exploration 
*********************************
-Exploration of granularity 
*/


-- Explore All Countries Orders Placed In 

SELECT DISTINCT country FROM gold.dim_customers

-- Explore All Categories Lines for Products 

SELECT DISTINCT 
	catagory, 
	subcatagory, 
	product_name 
FROM gold.dim_products
ORDER BY 1,2,3

-- in this data set: 
-- aggregration by category will have 4 results
-- aggregation by subcategory will have 36 results
-- aggregation by product will have 295 results 





/*
*********************************
Date Exploration 
*********************************
An exploration of range:
- earliest and latest dates 
- scope of data and timespan
*/


-- Range of Dates of Orders in Dataset by Year, Month, and Days between First and Last Order 
SELECT 
	MIN(order_date) AS first_order_date, 
	MAX(order_date) AS last_order_date, 
	DATEDIFF(year, MIN(order_date), MAX(order_date)) AS order_range_years,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS order_range_months,
	DATEDIFF(DAY, MIN(order_date), MAX(order_date)) AS order_range_days
FROM gold.fact_sales


-- Youngest and Oldest Customers 

SELECT 
MIN(birthdate) AS oldest_birthdate, 
DATEDIFF(year, MIN(birthdate), GETDATE()) AS oldest_customer_age, 
MAX(birthdate) AS youngest_birthdate, 
DATEDIFF(year, MAX(birthdate), GETDATE()) AS youngest_customer_age 
FROM gold.dim_customers




-- Birthdate  Shared by Most Customers Using CTE


	--CTE

WITH CTE_birthdate_customer_count AS
	(
	SELECT 
		COUNT(*) AS customer_count,
		birthdate 
	FROM gold.dim_customers
	GROUP BY birthdate
	)

	--Main Query 

SELECT TOP 1 
	birthdate,
	customer_count

FROM CTE_birthdate_customer_count AS customer_count_highest_birthday
ORDER BY customer_count DESC


	
/*
*********************************
Measure Exploration 
*********************************
- Aggregation of Measures by Dimensions
*/

--Total Sales
SELECT 
	SUM(sales_total) AS total_sales
FROM gold.fact_sales 

--Total Items Sold
SELECT 
	SUM(quantity) AS total_items_sold
FROM gold.fact_sales

--Average Price per Product
SELECT
	AVG(price) AS avg_price
FROM gold.fact_sales

--Total Number of Orders
SELECT 
	COUNT(DISTINCT order_number) AS total_dist_order_number
FROM gold.fact_sales

--Total Number of Products
SELECT
	COUNT(product_id) AS total_num_products
FROM gold.dim_products


--Total Number of Customers
SELECT 
	COUNT(customer_id) AS total_num_customers
FROM gold.dim_customers

--Total Number of Customers that have placed orders 

SELECT
	COUNT(DISTINCT customer_key) AS total_customer_with_orders
FROM gold.fact_sales

--Report of All Metrics 

SELECT 'Total Sales' as measure_name,SUM(sales_total) AS measure_value FROM gold.fact_sales
UNION ALL 
SELECT 'Total Product Quantity' as measure_name,SUM(quantity) AS measure_value FROM gold.fact_sales
UNION ALL 
SELECT 'Average Price of Product' as measure_name, AVG(price) AS measure_value FROM gold.fact_sales
UNION ALL 
SELECT 'Total Number of Orders' as measure_name, COUNT(DISTINCT order_number) AS measure_value FROM gold.fact_sales
UNION ALL 
SELECT 'Number of Products Available for Sale' as measure_name, COUNT(product_id) AS measure_value FROM gold.dim_products
UNION ALL 
SELECT 'Total Customers' as measure_name, COUNT(customer_id) AS measure_value FROM gold.dim_customers
UNION ALL 
SELECT 'Total Customers with Orders' as measure_name, COUNT(customer_key) AS measure_value FROM gold.fact_sales

/*
*********************************
Magnitude Analysis 
*********************************
-Comparison of measure value by dimensions

*/

-- Total Customers by Countries
SELECT 
	country,
	COUNT(DISTINCT customer_id) AS total_customers_per_country	
FROM gold.dim_customers
GROUP BY country 
ORDER BY total_customers_per_country DESC

-- Total Customers by Gender
SELECT 
	gender,
	COUNT(DISTINCT customer_id) AS total_customers_by_gender 	
FROM gold.dim_customers
GROUP BY gender
ORDER BY total_customers_by_gender DESC

-- Total Products by Category 
SELECT
	catagory,
	COUNT(product_id) AS products_in_catagory 	
FROM gold.dim_products
GROUP BY catagory
ORDER BY products_in_catagory DESC

-- Average Price by Category
SELECT
	catagory,
	AVG(product_cost) AS avg_price_by_catagory 	
FROM gold.dim_products
GROUP BY catagory
ORDER BY avg_price_by_catagory DESC

-- Total Revenue Generated by Catagory 

SELECT 
	p.catagory,
	SUM(f.sales_total) AS sales_by_catagory 
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
ON f.product_key = p.product_key 
GROUP BY p.catagory
ORDER BY sales_by_catagory DESC

-- Total Revenue Generated by Customer
SELECT
	c.customer_key, 
	c.first_name,
	c.last_name,  
	SUM(f.sales_total) AS revenue_per_customer
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON f.customer_key = c.customer_key 
GROUP BY c.customer_key, c.first_name, c.last_name 
ORDER BY revenue_per_customer DESC


-- Distribution of Products Sold by Country 

SELECT 
	c.country, 
	SUM(f.quantity) AS total_products_sold
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
GROUP BY c.country 
ORDER BY total_products_sold DESC

/*
*********************************
Ranking Analysis 
*********************************
-Order values of dimensions by measures 
-Top and Bottom Preformers 
*/


--Top 5 Revenue Generating Products
SELECT TOP 5
	p.product_name,
	SUM(f.sales_total) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
ON f.product_key = p.product_key 
GROUP BY p.product_name
ORDER BY total_revenue DESC

--5 Worst-Preforming Products
SELECT TOP 5
	p.product_name,
	SUM(f.sales_total) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
ON f.product_key = p.product_key 
GROUP BY p.product_name
ORDER BY total_revenue 

--Top 5 Revenue Generating Subcatagories
SELECT TOP 5
	p.subcatagory,
	SUM(f.sales_total) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
ON f.product_key = p.product_key 
GROUP BY p.subcatagory
ORDER BY total_revenue DESC

--5 Worst-Preforming Subcatacories
SELECT TOP 5
	p.subcatagory,
	SUM(f.sales_total) AS total_revenue
FROM gold.fact_sales AS f
LEFT JOIN gold.dim_products AS p
ON f.product_key = p.product_key 
GROUP BY p.subcatagory 
ORDER BY total_revenue 

--Ranking Using Window Function
	--Useful for adding details, selecting columns or specific rows by rank 
SELECT * 
FROM (
	SELECT 
	p.product_name,
	SUM(f.sales_total) AS total_revenue, 
	ROW_NUMBER() OVER (ORDER BY SUM(f.sales_total) DESC) AS rank_products
	FROM gold.fact_sales AS f
	LEFT JOIN gold.dim_products AS p
	ON f.product_key = p.product_key
	GROUP BY p.product_name) t
WHERE rank_products <= 5
