/*
***********************************************************************************
Scripts for Advanced Analysis (Run on Gold Layer) 
***********************************************************************************

Purpose: 
	A collect of scripts for performing 5 major catagories of BI Analysis 

Performs the following analytics: 
	1) Change-Over-Time Analysis
	2) Cumulative Analysis 
	3) Performance Analysis
	4) Part-to-Whole Analysis 
	5) Data Segmentation 

Usage: 
	This file is a collection of independent scripts. The file is not meant for producing a single report. For best
	performance, run each query seperately, as needed, within SQL Server Management Studio, against the data warehouse within
	this repository. 

*/



--Change-over-time analysis 
--Analyze how a measure evolves over time
--tracks trends and identifies seasonality in data
--Aggregation of a measure by a date dimension


SELECT 
	YEAR(order_date) AS order_year, 
	MONTH(order_date) AS order_month, 
	SUM(sales_total) AS sales_total_per_day,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY 
	YEAR(order_date),
	MONTH(order_date)

ORDER BY 
	YEAR(order_date), 
	MONTH(order_date)

--Same analysis with year/month in a single column 

SELECT 
	DATETRUNC(MONTH, order_date) AS order_date,
	SUM(sales_total) AS sales_total_per_day,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
ORDER BY DATETRUNC(MONTH, order_date)


--Same analysis with a different date format 
--This will create issues with sorting, format casts as a string 

SELECT 
	FORMAT(order_date, 'yyy-MMM') AS order_date,
	SUM(sales_total) AS sales_total_per_day,
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(quantity) AS total_quantity
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyy-MMM')
ORDER BY FORMAT(order_date, 'yyy-MMM')

--Cumulative Analysis 
--Aggregates data progressively over time
--contextualizes business metrics 
--Cumulative Measure by date dimension 



--Total sales per month 
--Running Total
SELECT 
	order_date, 
	total_sales, 
	--window function
	SUM(total_sales) OVER(PARTITION BY DATETRUNC(YEAR,order_date) ORDER BY order_date) AS running_total_sales
		--default frame is summation of unbounded preceding and current row
FROM
	(
	SELECT 
		DATETRUNC(MONTH, order_date) AS order_date,  
		SUM(sales_total) AS total_sales
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(MONTH, order_date)
	)t

ORDER BY DATETRUNC(MONTH, order_date)


--Rolling Average of Sales Total (Equally Weighted by Month)
SELECT 
	order_date, 
	total_sales, 
	--window function
	AVG(total_sales) OVER(
		ORDER BY DATETRUNC(MONTH,order_date)
		ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
		) AS rolling_avg_sales
			--default frame is summation of unbounded preceding and current row
FROM
	(
	SELECT 
		DATETRUNC(MONTH, order_date) AS order_date,  
		SUM(sales_total) AS total_sales
	FROM gold.fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATETRUNC(MONTH, order_date)
	)t

	--Performance Analysis 
	-- Comparing the current value to a target value 
	-- measures success and compares performance 
	--Current[Measure] - Target[Measure]



	--Yearly Performance of products compared to each product's sales to both it's average sales performance previous year's sales performance 
	
	--CTE
	WITH yearly_product_sales AS(
		SELECT 
			YEAR(f.order_date) AS order_year, 
			p.product_name, 
			SUM(f.sales_total) AS total_product_sales_by_year
		FROM gold.fact_sales f
		LEFT JOIN gold.dim_products p
		ON f.product_key=p.product_key
		WHERE f.order_date IS NOT NULL
		GROUP BY YEAR(f.order_date), p.product_name
	
	)
	--Query 

SELECT 
	order_year, 
	product_name, 
	total_product_sales_by_year,
	AVG(total_product_sales_by_year) OVER (PARTITION BY product_name) avg_sales, 
	total_product_sales_by_year - AVG(total_product_sales_by_year) OVER (PARTITION BY product_name) AS diff_from_avg,
	CASE WHEN total_product_sales_by_year - AVG(total_product_sales_by_year) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
		 WHEN total_product_sales_by_year - AVG(total_product_sales_by_year) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
		 ELSE 'Avg'
	END avg_change,
	LAG(total_product_sales_by_year) OVER (PARTITION BY product_name ORDER BY order_year) previous_year_sales, 
	total_product_sales_by_year - LAG(total_product_sales_by_year) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_previous_year,
	CASE WHEN total_product_sales_by_year - LAG(total_product_sales_by_year) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Over Previous Year'
		 WHEN total_product_sales_by_year - LAG(total_product_sales_by_year) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Under Previous Year'
		 ELSE 'No Change in Sales'
	END AS change_from_previous_year
FROM yearly_product_sales
ORDER BY product_name, order_year

--Part-to-Whole Analyis 
--Examine an how an individual part is performing compared to the overall
--Examines impact of category on the buisness 
--Measure/Total Measure *100 by Dimension 


-- Catagories contributing most to overall sales 

WITH catagory_sales AS (   
	SELECT 
		p.catagory, 
		sum(f.sales_total) AS total_sales
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_products p 
	ON p.product_key = f.product_key
	GROUP BY catagory)

SELECT 
	catagory, 
	total_sales, 
	SUM(total_sales) OVER () overall_sales, 
	CONCAT(ROUND((CAST(total_sales AS FLOAT)/SUM(total_sales) OVER()) *100 , 2), '%') AS percentage_of_total
FROM catagory_sales 
ORDER BY total_sales DESC

--Data Segmentation
--Group data based on a specific range
--Analysis of the correlation between two measures 
-- Creating a Dimension from a Measure 
--[Measure] By [Measure] 

--Segmenation of products into cost ranges and count of products in each segment 

WITH product_segments AS (
	SELECT 
		product_key,
		product_name, 
		product_cost, 
		CASE WHEN product_cost <100 THEN 'Under $100'
			 WHEN product_cost BETWEEN 100 AND 500 THEN '$100-$500'
			 WHEN product_cost BETWEEN 500 AND 1000 THEN '$500-$1000'
			 ELSE 'Above $1000'
	END cost_range
	FROM gold.dim_products 
) 

SELECT 
	cost_range, 
	COUNT(product_key) AS total_products 
FROM product_segments
GROUP BY cost_range 
ORDER BY total_products DESC

--Grouping of customers into three segments based on their spending behavior
--	VIP: 12 months history with 5,000 of spending 
--	Regular: 12 months of history with less than 5,000 of spending 
--  New: Lifespan less than 12 months 
--Find total number of customers in each group 

WITH customer_spending_lifespan AS (
	SELECT  
		c.customer_key, 
		SUM(f.sales_total) AS total_spending, 
		MIN(f.order_date) AS first_order, 
		MAX(f.order_date) AS last_order, 
		DATEDIFF(MONTH,MIN(f.order_date), MAX(f.order_date)) AS lifespan 
	FROM gold.fact_sales f
	LEFT JOIN gold.dim_customers c
	ON f.customer_key = c.customer_key 
	GROUP BY c.customer_key 
	)
SELECT
	customer_segment, 
	COUNT (customer_key) AS total_customers
FROM(
	SELECT 	
		customer_key, 
		CASE WHEN total_spending >= 5000 AND lifespan >=12 THEN 'VIP'
			 WHEN total_spending < 5000 AND lifespan >12 THEN 'Regular'
			 WHEN lifespan <12 THEN 'New' 
			 ELSE 'N/A'
		END customer_segment
	FROM customer_spending_lifespan 
) t
GROUP BY customer_segment 
ORDER BY total_customers DESC
