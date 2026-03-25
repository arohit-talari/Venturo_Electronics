-- Ad Hoc Queries 

-- 1: Monthly Revenue in 2024 
SELECT 
	Order_Month AS Month, 
    SUM(usd_price) AS Gross_Revenue, 
    SUM(CASE 
    WHEN is_refunded = 1 THEN usd_price ELSE 0 END) AS Amount_Refunded,
    SUM(usd_price) - SUM(CASE WHEN is_refunded = 1 THEN usd_price ELSE 0 END) AS Net_Revenue,
    ROUND(SUM(is_refunded)/COUNT(DISTINCT os.order_id) * 100, 2) AS Refund_Rate
FROM orders o 
JOIN date_dim d
ON o.order_id = d.order_id
JOIN order_status os
ON d.order_id = os.order_id
WHERE order_month != ''
AND order_year = 2024
GROUP BY order_month, order_month_num
ORDER BY order_month_num;

-- 2: QoQ Revenue Growth Rate by Year 
WITH quarterly_growth AS 
(
SELECT 
	DISTINCT order_year, 
	order_quarter, 
	SUM(usd_price) AS Revenue
FROM date_dim d
JOIN orders o 
ON d.order_id = o.order_id
WHERE order_year IS NOT NULL
GROUP BY order_year, order_quarter
ORDER BY order_year
)
SELECT 
	Order_Year, 
    Order_Quarter,
    Revenue,
    LAG(Revenue, 1,NULL) OVER(ORDER BY order_year, order_quarter) AS Previous_Q_Revenue,
    ROUND((Revenue - LAG(Revenue, 1,NULL) OVER(ORDER BY order_year, order_quarter))/LAG(Revenue, 1,NULL) OVER(ORDER BY order_year, order_quarter) * 100, 2) AS QoQ_Growth_Rate
FROM quarterly_growth
ORDER BY order_year; -- Comparing Q4 of the prior year with Q1 of the following year is contracting high growth rates because of each year's macro narrative. 
-- Be sure to include this in the writeup 

-- 3: Order Volume vs. AOV by Year
SELECT 
	Order_Year,
	COUNT(d.order_id) AS Order_Volume,
    ROUND(AVG(usd_price),2) AS AOV
FROM date_dim d
JOIN orders o 
ON d.order_id = o.order_id
WHERE Order_Year IS NOT NULL
GROUP BY Order_Year
ORDER BY Order_Year;  

-- 4: MacBook Air and Samsung Galaxy S24 by quarter in NA
SELECT 
	Order_Year, 
	Order_Quarter, 
    Product_Name, 
    COUNT(product_id) AS Orders, 
    SUM(usd_price) AS Revenue, 
    ROUND(AVG(usd_price),2) AS AOV 
FROM orders o 
JOIN date_dim d 
ON o.order_id = d.order_id 
WHERE product_name IN("Apple Macbook Air", "Samsung Galaxy S24")
AND Order_Year IS NOT NULL
GROUP BY Order_Year, Order_Quarter, Product_Name
ORDER BY Order_Year;

-- 5: Products where refund rate exceeded 10% in 2024
WITH products_2024 AS 
(
SELECT 
	Product_Name, Product_ID, COUNT(product_id) AS 2024_Orders, SUM(is_refunded) AS 2024_Refunds
FROM orders o 
JOIN date_dim d 
ON o.order_id = d.order_id 
JOIN order_status os 
ON d.order_id = os.order_id
WHERE order_year = 2024
GROUP BY Product_Name, Product_ID
ORDER BY Product_ID
) 
SELECT Product_Name, Product_ID, 2024_Orders, 2024_Refunds, ROUND(2024_Refunds/2024_Orders * 100, 2) AS Refund_Rate
FROM products_2024
HAVING (2024_Refunds/2024_Orders) >= 0.1;

-- 2022 vs 2024 
WITH yearly_refund_rate AS 
(
SELECT 
	Order_Year, 
    Product_Name, 
    COUNT(product_id) AS Orders, 
    SUM(is_refunded) AS Refunded,
    ROUND(SUM(is_refunded)/COUNT(product_id) * 100 ,2) AS Refund_Rate
FROM orders o 
JOIN date_dim d
ON o.order_id = d.order_id
JOIN order_status os 
ON d.order_id = os.order_id
WHERE Order_Year IN(2022, 2024) 
AND Order_Year IS NOT NULL
GROUP BY Order_Year, Product_Name
ORDER BY Order_Year
)
SELECT *, 
LAG(Refund_Rate) OVER(PARTITION BY Product_Name ORDER BY Order_Year) AS 2022_refund_rate,
ROUND((Refund_Rate - LAG(Refund_Rate) OVER(PARTITION BY Product_Name ORDER BY Order_Year))/LAG(Refund_Rate) OVER(PARTITION BY Product_Name ORDER BY Order_Year) * 100, 2) AS pct_change
FROM yearly_refund_rate
ORDER BY pct_change DESC
LIMIT 10;

-- 6: 2024 to 2025 Revenue Recovery Rate by Product (identify which product lines bounced back)
WITH Yearly_Product_Revenue AS
(
SELECT 
	Order_Year, 
    Product_Name, 
    SUM(usd_price) AS Revenue
FROM orders o 
JOIN date_dim d 
ON o.order_id = d.order_id
WHERE Order_Year IN(2024, 2025)
GROUP BY Order_Year, Product_Name
ORDER BY Order_Year
)
SELECT Product_Name, 2025_Revenue, 2024_Revenue, Recovery_Rate 
FROM (SELECT 
	Order_Year, 
    Product_Name, 
    Revenue AS 2025_Revenue, 
    LAG(Revenue) OVER(PARTITION BY product_name ORDER BY order_year) AS 2024_Revenue,
    ROUND((Revenue - LAG(Revenue) OVER(PARTITION BY product_name ORDER BY order_year))/LAG(Revenue) OVER(PARTITION BY product_name ORDER BY order_year) * 100, 2) AS Recovery_Rate
FROM Yearly_Product_Revenue) AS recovery_rate_by_product
WHERE Order_Year = 2025
ORDER BY Recovery_Rate DESC;
    
-- 7: Loyalty Member Revenue (As a Percentage of Total, by Year)
WITH Loyalty_Member_Revenue AS 
(
SELECT 
	Order_Year, 
    SUM(usd_price) AS Revenue, 
    SUM(CASE WHEN is_loyalty_member = 1 THEN usd_price ELSE 0 END) AS Loyalty_Member_Revenue
FROM orders o 
JOIN customers c 
ON o.customer_id = c.user_id 
JOIN date_dim d
ON o.order_id = d.order_id
WHERE Order_Year IS NOT NULL
GROUP BY Order_Year
)
SELECT *,
ROUND((Loyalty_Member_Revenue/Revenue) * 100, 2) AS Loyalty_Member_Revenue_Contribution
FROM Loyalty_Member_Revenue
ORDER BY Order_Year;

-- 8: Loyalty vs. Non-Loyalty Customer Retention Rate – 2024 Cohort 
SELECT 
    c.Is_Loyalty_Member,
    COUNT(DISTINCT c2024.customer_id) AS Customers_2024,
    COUNT(DISTINCT c2025.customer_id) AS Returned_Customers_2025,
    ROUND(COUNT(DISTINCT c2025.customer_id) / 
          COUNT(DISTINCT c2024.customer_id) * 100, 2) AS Retention_Rate
FROM (
    SELECT DISTINCT o.customer_id 
    FROM orders o 
    JOIN date_dim d 
    ON o.order_id = d.order_id 
    WHERE d.order_year = 2024) c2024
JOIN customers c 
ON c2024.customer_id = c.user_id
LEFT JOIN (
    SELECT DISTINCT o.customer_id 
    FROM orders o 
    JOIN date_dim d 
    ON o.order_id = d.order_id 
    WHERE d.order_year = 2025) c2025 
ON c2024.customer_id = c2025.customer_id
GROUP BY c.Is_Loyalty_Member;

-- 9: 2024 to 2025 Revenue Recovery Rate, by Region
WITH Regional_Revenue AS 
(
SELECT 
	Order_Year, 
	Region, 
    SUM(usd_price) AS Revenue
FROM orders o 
JOIN date_dim d 
ON o.order_id = d.order_id 
JOIN customers c 
ON o.customer_id = c.user_id 
JOIN geo_lookup g 
ON c.country_code = g.country_code
WHERE Order_Year IN(2024,2025)
GROUP BY Order_Year, Region
ORDER BY Order_Year, Region
)
SELECT Region, 2025_Revenue, 2024_Revenue, Recovery_Rate 
FROM (SELECT 
		Order_Year, 
        Region, 
        Revenue AS 2025_Revenue,
		LAG(Revenue) OVER(PARTITION BY Region ORDER BY Order_Year, Region) AS 2024_Revenue,
		ROUND((Revenue - LAG(Revenue) OVER(PARTITION BY Region ORDER BY Order_Year, Region))/LAG(Revenue) OVER(PARTITION BY Region ORDER BY Order_Year, Region) * 100, 2) AS Recovery_Rate
FROM Regional_Revenue) Revenue_Recovery_Rate
WHERE Order_Year = 2025
ORDER BY Recovery_Rate DESC;

-- 10: Delivery time vs. Revenue, by Country (surfaces operational fulfillment investment argument)
SELECT 
	Country_Name, 
    ROUND(AVG(days_till_delivery),2) AS Avg_Delivery_Time, 
    SUM(usd_price) AS Revenue
FROM orders o 
JOIN order_status os 
ON o.order_id = os.order_id
JOIN customers c 
ON o.customer_id = c.user_id 
JOIN geo_lookup g 
ON c.country_code = g.country_code
GROUP BY Country_Name
ORDER BY Revenue DESC
LIMIT 20;

-- 11: Loyalty vs. Non-Loyalty Member Product Preference

WITH Loyalty_Status_Revenue_Contribution AS 
(
SELECT 
	Product_Name, 
    COUNT(CASE WHEN is_loyalty_member = 1 THEN order_id END) AS Loyalty_Orders, 
    COUNT(CASE WHEN is_loyalty_member = 0 THEN order_id END) AS Non_Loyalty_Orders,
    SUM(CASE WHEN is_loyalty_member = 1 THEN usd_price END) AS Loyalty_Revenue,
    SUM(CASE WHEN is_loyalty_member = 0 THEN usd_price END) AS Non_Loyalty_Revenue
FROM orders o 
JOIN customers c
ON o.customer_id = c.user_id
GROUP BY Product_Name
)
SELECT *, 
	ROUND(loyalty_revenue/(loyalty_revenue + non_loyalty_revenue) * 100, 2) AS Loyalty_Contribution,
    ROUND(non_loyalty_revenue/(loyalty_revenue + non_loyalty_revenue) * 100, 2) AS Non_Loyalty_Contribution
FROM  Loyalty_Status_Revenue_Contribution;