-- Walmart Project Queries - MySQL

SELECT * FROM walmart;

SELECT date FROM walmart LIMIT 10;


-- DROP TABLE walmart;

-- Count total records
SELECT COUNT(*) FROM walmart;

-- Count payment methods and number of transactions by payment method
SELECT 
    payment_method,
    COUNT(*) AS no_payments
FROM walmart
GROUP BY payment_method;

SELECT 
     COUNT(DISTINCT branch) 
FROM walmart;


SELECT MAX(quantity) FROM walmart;

-- Business problems
-- 1.Different payment method and number of transaction and qunatity sold

SELECT 
    payment_method,
    COUNT(*) as  no_payments,
    SUM(quantity) as no_qnty_sold
FROM walmart
GROUP BY payment_method;


-- 2.Identify the highest-rated category in each branch ,display the branch ,category,avg rating

WITH avg_ratings AS (
    SELECT 
        branch, 
        category, 
        AVG(rating) AS avg_rating
    FROM walmart
    GROUP BY branch, category
)
SELECT *
FROM (
    SELECT 
        branch,
        category,
        avg_rating,
        RANK() OVER (PARTITION BY branch ORDER BY avg_rating DESC) AS `rank`
    FROM avg_ratings
) AS ranked_data
WHERE `rank` = 1;
-- 3.Identify the busiest day for each branch based on the no of transactions
SELECT branch, day_name, no_transactions
FROM (
    SELECT 
        branch,
        DAYNAME(STR_TO_DATE(date, '%d/%m/%Y')) AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS `ranked_position`
    FROM walmart
    GROUP BY branch, day_name
) AS ranked
WHERE `ranked_position` = 1;


-- Q4: Calculate the total quantity of items sold per payment method

SELECT 
    payment_method,
    SUM(quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method;


-- Q5: Determine the average, minimum, and maximum rating of categories for each city
SELECT 
    city,
    category,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating,
    AVG(rating) AS avg_rating
FROM walmart
GROUP BY city, category;


-- Q6: Calculate the total profit for each category
SELECT 
    category,
    SUM(unit_price * quantity * profit_margin) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;


-- Q7: Determine the most common payment method for each branch
WITH cte AS (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS total_trans,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranked_position  -- Renamed rank
    FROM walmart
    GROUP BY branch, payment_method
)
SELECT branch, payment_method AS preferred_payment_method
FROM cte
WHERE ranked_position = 1;  -- Updated alias


-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts
SELECT
    branch,
    CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS num_invoices
FROM walmart
GROUP BY branch, shift
ORDER BY branch, num_invoices DESC;

-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
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







