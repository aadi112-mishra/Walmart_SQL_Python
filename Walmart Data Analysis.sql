CREATE DATABASE WALMART_DB;
USE WALMART_DB;
SELECT COUNT(*) FROM walmart_clean;

SELECT PAYMENT_METHOD,COUNT(*) FROM
WALMART_CLEAN
GROUP BY PAYMENT_METHOD;

SELECT COUNT(DISTINCT BRANCH)
FROM WALMART_CLEAN;

-- BUSINESS PROBLEMS
-- Q1: Find different payment methods, number of transactions, and quantity sold by payment method

SELECT PAYMENT_METHOD,COUNT(*) AS NO_TRANSACTIONS,
SUM(QUANTITY) AS TOTAL_QUANTITY_SOLD
FROM WALMART_CLEAN
GROUP BY PAYMENT_METHOD;

-- Question #2: Identify the highest-rated category in each branch
-- Display the branch, category, and avg rating;
SELECT *
FROM (
    SELECT 
        branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS position
    FROM WALMART_CLEAN
    GROUP BY branch, category
) AS ranked
WHERE position = 1;

-- Q3: Identify the busiest day for each branch based on the number of transactions
select *
from(
select
 branch,count(*) as no_of_transactions,
 DAYNAME(STR_TO_DATE(date, '%d/%m/%Y')) AS day_name,
 RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS position
from walmart_clean
group by branch,day_name
) as ranked
where position=1;

-- Q4: Calculate the total quantity of items sold per payment method
SELECT PAYMENT_METHOD,SUM(QUANTITY) AS TOTAL_ITEMS_SOLD,COUNT(*) AS NO_TRANSACTION
FROM WALMART_CLEAN
GROUP BY PAYMENT_METHOD
ORDER BY NO_TRANSACTION DESC;

-- Q5: Determine the average, minimum, and maximum rating of categories for each city
SELECT
CITY,CATEGORY,
AVG(RATING) AS AVG_RATING,
MIN(RATING) AS MIN_RATING,
MAX(RATING) AS MAX_RATING
FROM WALMART_CLEAN
GROUP BY CITY,CATEGORY;

-- Q6: Calculate the total profit for each category
SELECT 
CATEGORY,
SUM(TOTAL_PRICE) AS TOTAL_REVENUE,
SUM( total_price * profit_margin) AS total_profit
FROM WALMART_CLEAN
GROUP BY CATEGORY
ORDER BY TOTAL_REVENUE DESC;

-- Q7: Determine the most common payment method for each branch
WITH CPM
AS(
SELECT BRANCH,
COUNT(*) AS TOTAL_TRANS,
PAYMENT_METHOD,
RANK()OVER(PARTITION BY BRANCH ORDER BY COUNT(*) DESC)AS RAN
FROM WALMART_CLEAN
GROUP BY BRANCH,PAYMENT_METHOD
)
SELECT * FROM CPM
WHERE RAN=1;

-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts
SELECT
    branch,
    CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS num_invoices
FROM WALMART_CLEAN
GROUP BY branch, shift
ORDER BY branch, num_invoices DESC;

-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total_price) AS revenue
    FROM walmart_clean
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total_price) AS revenue
    FROM walmart_clean
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;

-- Q10: CALCULATE THE MOST PROFITABLE CITY
SELECT city,
       SUM(total_price * profit_margin) AS total_profit
FROM walmart_CLEAN
GROUP BY city
ORDER BY total_profit DESC;

-- Q11: QUERIES FOR CALCULATE PEAK SHOPPING HOURS
SELECT HOUR(STR_TO_DATE(time, '%H:%i:%s')) AS hour_of_day,
       COUNT(*) AS transactions
FROM walmart_clean
GROUP BY hour_of_day
ORDER BY transactions DESC;

-- Q12: QUERIES FOR CALCULATE MONTHLY SALES TREND
SELECT DATE_FORMAT(STR_TO_DATE(date, '%d/%m/%y'), '%Y-%m') AS month,
       SUM(total_price) AS monthly_sales
FROM walmart_clean
GROUP BY month
ORDER BY month;

-- Q13: QUERY FOR CALCULATE SALES ON WEEKEND VS WEEKDAY
SELECT CASE
          WHEN DAYOFWEEK(STR_TO_DATE(date, '%d/%m/%y')) IN (1,7) THEN 'Weekend'
          ELSE 'Weekday'
       END AS day_type,
       SUM(total_price) AS revenue
FROM walmart_clean
GROUP BY day_type;

-- Q13: QUERY FOR CALCULATE TOP 5 MOST SOLD PRODUCT CATEGORY
SELECT category,
       SUM(QUANTITY) AS total_sold_products
FROM walmart_clean
GROUP BY category
ORDER BY total_sold_products desc
LIMIT 5;

 -- Q14: QUERY FOR CALCULATE TOP PAYING CUSTOMERS
 SELECT invoice_id,
       SUM(total_price) AS invoice_value
FROM walmart_clean
GROUP BY invoice_id
ORDER BY invoice_value DESC
LIMIT 10;

