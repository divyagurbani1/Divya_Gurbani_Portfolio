CREATE DATABASE IF NOT EXISTS walmart_sales_data;

CREATE TABLE IF NOT EXISTS sales(
invoice_id varchar(30) NOT NULL PRIMARY KEY,
branch varchar(5) NOT NULL,
city varchar(30) NOT NULL,
customer_type varchar(30) NOT NULL,
gender varchar(10) NOT NULL,
product_line varchar(100) NOT NULL,
unit_price decimal(10,2) NOT NULL,
quantity int NOT NULL,
VAT float(6,4) NOT NULL,
total decimal(12, 4) NOT NULL,
date DATETIME NOT NULL,
time time NOT NULL,
payment_method varchar(10) NOT NULL,
cogs decimal(10,2) NOT NULL,
gross_margin_pct float(11,9) NOT NULL,
gross_income  decimal(12,4) NOT NULL,
rating float(2,1) NOT NULL
);



-- -------------------------------------------------------------------------------------------------------
-- -------------------------------------Feature Engineeing-------------------------------------
-- Processing data for analysis
-- time-of_day
SELECT 
	time,
    (case
    WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
    WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
    ELSE "Evening"
    END 
    ) As time_of_day
FROM sales;
-- Adding the new column to the database
ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = (case
    WHEN `time` BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
    WHEN `time` BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
    ELSE "Evening"
    END 
    ); 

-- day_name --

SELECT 
	date,
    DAYNAME(date) AS day_name
FROM sales;

-- adding the day column to the table
ALTER TABLE sales ADD COLUMN day_name varchar(20);

UPDATE sales
SET day_name = DAYNAME(date);

-- month_name

SELECT
	date, 
    MONTHNAME(date) AS month_name
FROM sales;

ALTER TABLE sales ADD COLUMN month_name varchar(20);
-- adding the month column to the table
UPDATE sales
SET month_name = MONTHNAME(date);
-- ----------------------------------------------------------------------------------------------------------------
-- ------------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------Answering business questions ---------------------------------------------------------
-- 1) How many unique cities does the data have?

SELECT 
DISTINCT city
FROM sales;

-- Three - Naypyitaw, Yangon and Mandalay

-- 2) In which city is each branch?

SELECT
DISTINCT branch
FROM sales;

SELECT 
DISTINCT city, branch
FROM sales;
/* 3 branches 
A - Yangon
B - Mandalay
C - Naypyitaw
*/

-- -----------------------------------------------------------------------------------
-- ----------------------------------------Product------------------------------------

-- How many unique product lines does the data have?
SELECT
COUNT(DISTINCT(product_line))
FROM sales;

SELECT
DISTINCT product_line
FROM sales;

-- What is the most common payment method?

SELECT 
payment_method,
COUNT(payment_method) AS cnt
FROM sales
GROUP BY payment_method
ORDER BY cnt DESC;

-- Cash is the most used payment method followed by ewallet

-- What is the most selling product line? (Visualised with Tableau)

SELECT 
product_line,
COUNT(product_line) AS cnt
FROM sales
GROUP BY product_line
ORDER BY cnt DESC;
-- Most selling product line is electronic accessories followed by fashion accessories.

-- What is the total revenue by month?
SELECT 
month_name AS month,
SUM(total) AS total_revenue
FROM sales
GROUP BY month_name
ORDER BY total_revenue DESC;
-- January had the most sales 

-- What month had the largest COGS?
SELECT
month_name AS month,
SUM(cogs) AS cogs
FROM sales
GROUP BY month_name
ORDER BY cogs desc;

-- COGS is highest in Jan. The higher the sales, the higher is the revenue.


-- What product line had the largest revenue?
SELECT
product_line,
sum(total) AS product_revenue
FROM sales
GROUP BY product_line
ORDER BY product_revenue DESC;
-- Home AND Lifestyle had the largest revenue

-- What is the city with the largest revenue?
SELECT
branch,
city,
sum(total) AS total_revenue
FROM sales
GROUP BY city, branch
ORDER BY total_revenue DESC;
-- Naypyitaw had the highest revenue out of all three cities.

-- What product line had the largest VAT?
SELECT
product_line,
Avg(VAT) as avg_tax
FROM sales
GROUP BY product_line
ORDER BY avg_tax DESC;

-- Home & Lifestyle had the largest tax.



-- Which branch sold more products than average product sold?
SELECT 
branch,
SUM(quantity) as qty
FROM sales
GROUP BY branch
HAVING SUM(quantity) > (SELECT AVG(quantity) FROM sales);
-- Branch C sold more products than average products sold.

-- What is the most common product line by gender?
SELECT
gender,
product_line,
COUNT(gender) as gender_count
FROM sales
GROUP BY product_line, gender
ORDER BY gender_count DESC;
-- Common product line among males is electronic accessories while among females is fashion accessories.
-- What is the average rating of each product line?

SELECT
round(AVG(rating), 2) AS avg_rating,
product_line
FROM sales
GROUP BY product_line
ORDER BY avg_rating DESC;

-- Highly rated product line is fashion accessories.

-- ----------------------------------------SALES-------------------------------------------
-- Number of sales made in each time of the day per weekday

SELECT
time_of_day,
count(*) AS total_sales
FROM sales
WHERE day_name = "Monday"
GROUP BY time_of_day
ORDER BY total_sales DESC;

/* Sales made at each time of the day
Afternoon - 264
Evening - 292
Morning - 130
*/

-- Which of the customer types brings the most revenue?
SELECT
customer_type,
SUM(total) as total_revenue
FROM sales
GROUP BY customer_type
ORDER BY total_revenue desc;
-- Normal customers bring more revenue than members.

-- Which city has the largest tax percent/ VAT (Value Added Tax)?
SELECT
city,
AVG(VAT) AS VAT
FROM sales
GROUP BY city
ORDER BY VAT DESC;
-- Naypyitaw has the largest tax percent/VAT

-- Which customer type pays the most in VAT?
SELECT
customer_type,
AVG(VAT) AS VAT
FROM sales
GROUP BY customer_type
ORDER BY VAT DESC;

-- Not a significant difference in terms of VAT 

-- ---------------------------Customers---------------------------------------------
-- How many unique customer types does the data have?
SELECT
COUNT(DISTINCT customer_type)
FROM sales;
-- 2 

-- How many unique payment methods does the data have? 
SELECT
DISTINCT payment_method
FROM sales;

-- Which customer type buys the most?
SELECT
customer_type,
COUNT(*) AS cust_count
FROM sales
GROUP BY customer_type;
-- Normal customers buy more

-- What is the gender distribution per branch?
SELECT
branch,
gender,
COUNT(*) AS gender_count
FROM sales
GROUP BY gender, branch;

/* Gender distribution of each branch
A
Female- 114
Male - 122
B
Female- 101
Male - 119
C
Female- 121
Male - 109
*/

-- Which time of the day do customers give most ratings? (Visualised with Tableau)
SELECT
time_of_day,
avg(rating) as avg_rating
FROM sales
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Which day fo the week has the best avg ratings?
SELECT
day_name,
AVG(rating) AS avg_rating
FROM sales
GROUP BY day_name
ORDER BY avg_rating desc;
-- Monday has the best average rating

-- Which day of the week has the best average ratings per branch? (Visualised with Tableau)
SELECT
day_name,
AVG(rating) AS avg_rating, 
branch
FROM sales
GROUP BY day_name, branch
ORDER BY avg_rating desc;
-- Branch A has the best rating for Friday, Branch B for Monday and Branch C for Sunday.















