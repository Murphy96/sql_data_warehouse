-- EDA Project

--*******************************************
--ROUGH DRAFT 6/22/26
--******************************************

-- Database Exploration 

/*
*********************************
Dimension Exploration 

Mainly an exploration of granularity 
*********************************
*/



-- Explore All Countries Orders Placed In 

SELECT DISTINCT country FROM gold.dim_customers

-- Explore All Categories Lines for Products 

SELECT DISTINCT catagory, subcatagory, product_name FROM gold.dim_products
ORDER BY 1,2,3

-- in this data set: 
-- aggregration by category will have 4 results
-- aggregation by subcategory will have 36 results
-- aggregation by product will have 295 results 





/*
*********************************
Date Exploration 

An exploration of range:
- earliest and latest dates 
- scope of data and timespan
*********************************
*/


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




-- What birthdate is shared by the most customers?


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
- Aggregation of Measures by Dimensions 
*********************************
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
