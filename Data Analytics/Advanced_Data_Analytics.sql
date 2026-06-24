/*

Advanced Analytics For Datawarehouse project

*******Working Draft***************

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


--Rolling Average of Price (Equally Weighted by Month, Partitioned by Year)
SELECT 
	order_date, 
	total_sales, 
	--window function
	AVG(total_sales) OVER
	(PARTITION BY DATETRUNC(YEAR,order_date) 
	ORDER BY order_date
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

ORDER BY DATETRUNC(MONTH, order_date)
