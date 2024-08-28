-- Create database
CREATE DATABASE WalmartSales;

-- Create table in Walmart Sales DB
USE [WalmartSales];
GO
CREATE TABLE sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT,
    gross_income DECIMAL(12, 4),
    rating FLOAT
);

-- Data cleaning
SELECT
	*
FROM dbo.sales;

-- Add the time_of_day column
SELECT time,
	(CASE
		WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END) AS time_of_day
FROM sales;
ALTER TABLE sales ADD [time_of_day] VARCHAR(20);

UPDATE sales
SET [time_of_day]= (
	CASE
		WHEN time BETWEEN '00:00:00' AND '12:00:00' THEN 'Morning'
        WHEN time BETWEEN '12:01:00' AND '16:00:00' THEN 'Afternoon'
        ELSE 'Evening'
    END
);

-- Add day_name column
SELECT date, DATENAME(day,date) FROM sales;
ALTER TABLE sales ADD [day_name] VARCHAR(10);
ALTER TABLE sales ADD [day_date] VARCHAR(10);
/*ALTER TABLE sales DROP COLUMN [day_date];*/

UPDATE sales
SET [day_date] = DATEPART(day, date);

UPDATE sales
SET [day_name] = (
	CASE
		WHEN day_date = 1 THEN 'MONDAY'
		WHEN day_date = 2 THEN 'TUEDAY'
		WHEN day_date = 3 THEN 'WEDNESDAY'
		WHEN day_date = 4 THEN 'THURSDAY'
		WHEN day_date = 5 THEN 'FRIDAY'
		WHEN day_date = 6 THEN 'SATURDAY'
		ELSE 'SUNDAY'
	END
);
SELECT day_name FROM sales;

/*SELECT date, DATEPART(day,date) FROM sales;
ALTER TABLE sales ADD [day_date] VARCHAR(10);

UPDATE sales 
/*SET [day_date] = DATEPART(day, date);*/
SET [day_date] = DATEPART(day, date);
SELECT day_date FROM sales;*/

-- Add month_name column
SELECT date, DATEPART(month, date)
FROM sales;

ALTER TABLE sales ADD [month_name] VARCHAR(10);
ALTER TABLE sales ADD [month_date] VARCHAR(10);
/*ALTER TABLE sales DROP COLUMN [month_name];*/

UPDATE sales
SET [month_date] = DATEPART(month, date);

UPDATE sales
SET [month_name] = (
	CASE
		WHEN month_date = 1 THEN 'JANUARY'
		WHEN month_date = 2 THEN 'FEBRUARY'
		WHEN month_date = 3 THEN 'MARCH'
		WHEN month_date = 4 THEN 'APRIL'
		WHEN month_date = 5 THEN 'MAY'
		WHEN month_date = 6 THEN 'JUNE'
		WHEN month_date = 7 THEN 'JULY'
		WHEN month_date = 8 THEN 'AUGUST'
		WHEN month_date = 9 THEN 'SEPTEMBER'
		WHEN month_date = 10 THEN 'OCTOBER'
		WHEN month_date = 11 THEN 'NOVEMBER'
		ELSE 'DECEMBER'
	END
);
SELECT month_name FROM sales;

--------------------------------------------------------------------
--------------------- Generic Question -----------------------------
--------------------------------------------------------------------
-- How many unique cities does the data have?
SELECT DISTINCT city FROM sales;

-- In which city is each branch?
SELECT DISTINCT city, branch FROM sales;

--------------------------------------------------------------------
------------------- Product Question -------------------------------
--------------------------------------------------------------------
-- How many unique product lines does the data have?
SELECT DISTINCT product_line FROM sales;

-- What is the most selling product line
SELECT SUM(quantity) as qty, product_line
FROM sales
GROUP BY product_line
ORDER BY qty DESC;

-- What is the most selling product line
SELECT SUM(quantity) as qty, product_line
FROM sales
GROUP BY product_line
ORDER BY qty DESC;

-- What is the total revenue by month
SELECT month_name AS month, SUM(total) AS total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue;

-- What month had the largest COGS?
SELECT month_name AS month, SUM(cogs) AS cogs
FROM sales
GROUP BY month_name 
ORDER BY cogs;

-- What product line had the largest revenue?
SELECT product_line, SUM(total) as total_revenue
FROM sales
GROUP BY product_line
ORDER BY total_revenue DESC;

-- What is the city with the largest revenue?
SELECT branch, city, SUM(total) AS total_revenue
FROM sales
GROUP BY city, branch 
ORDER BY total_revenue;

-- What product line had the largest VAT?
SELECT product_line, AVG(tax_5) as avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC;

-- Fetch each product line showing "Good", "Bad". Good if its greater than average sales
SELECT AVG(quantity) AS avg_qnty
FROM sales;
SELECT product_line,
	CASE
		WHEN AVG(quantity) > 6 THEN 'Good'
        ELSE 'Bad'
    END AS remark
FROM sales
GROUP BY product_line;

-- Which branch sold more products than average product sold?
SELECT branch, SUM(quantity) AS qnty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);

-- What is the most common product line by gender
SELECT gender, product_line, COUNT(gender) AS total_count
FROM sales
GROUP BY gender, product_line
ORDER BY total_count DESC;

-- What is the average rating of each product line
SELECT ROUND(AVG(rating), 2) as avg_rating,  product_line
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

--------------------------------------------------------------------
----------------- Customers Question -------------------------------
--------------------------------------------------------------------
-- How many unique customer types does the data have?
SELECT DISTINCT customer_type
FROM sales;

-- How many unique payment methods does the data have?
SELECT DISTINCT payment
FROM sales;

-- What is the most common customer type?
SELECT customer_type, COUNT(*) as count
FROM sales
GROUP BY customer_type
ORDER BY count DESC;

-- Which customer type buys the most?
SELECT customer_type, COUNT(*)
FROM sales
GROUP BY customer_type;


-- What is the gender of most of the customers?
SELECT gender, COUNT(*) as gender_count
FROM sales
GROUP BY gender
ORDER BY gender_count DESC;

-- What is the gender distribution per branch?
SELECT gender, COUNT(*) as gender_count
FROM sales
WHERE branch = 'C'
GROUP BY gender
ORDER BY gender_count DESC;

-- Which time of the day do customers give most ratings?
SELECT time_of_day, AVG(rating) AS avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Which time of the day do customers give most ratings per branch?
SELECT time_of_day, AVG(rating) AS avg_rating
FROM sales
WHERE branch = 'A'
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Which day fo the week has the best avg ratings?
SELECT day_name, AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name 
ORDER BY avg_rating DESC;

-- Which day of the week has the best average ratings per branch?
SELECT day_name, COUNT(day_name) AS total_sales
FROM sales
WHERE branch = 'C'
GROUP BY day_name
ORDER BY total_sales DESC;

--------------------------------------------------------------------
------------------------ Sales Question ----------------------------
--------------------------------------------------------------------
-- Number of sales made in each time of the day per weekday 
SET DATEFIRST 1
SELECT time_of_day, COUNT(*) AS total_sales
FROM sales
WHERE day_name = 'SUNDAY'
GROUP BY time_of_day 
ORDER BY total_sales DESC;

-- Which of the customer types brings the most revenue?
SELECT customer_type, SUM(total) AS total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue;

-- Which city has the largest tax/VAT percent?
SELECT city, ROUND(AVG(tax_5), 2) AS avg_tax_5percent
FROM sales
GROUP BY city 
ORDER BY avg_tax_5percent DESC;

-- Which customer type pays the most in VAT?
SELECT customer_type, AVG(tax_5) AS total_tax
FROM sales
GROUP BY customer_type
ORDER BY total_tax;