-- Schema: ecommerce
use ecommerce; 

-- Tables: ORDERS, CUSTOMERS, ORDER_STATUS, GEO_LOOKUP, DATE_DIM 
SELECT * FROM geo_lookup; 
SELECT * FROM customers; 
SELECT * FROM orders;
-- 3,353 records have order_ts as NULL = 3.03% 
SELECT * FROM order_status; -- Avg days_till_delivery = 6.4212 (reference back) 
-- 3,353 records have ship_ts, delivery_ts, refund_ts as NULL = 3.03%
-- is_refunded remains unaffected, stills tells us whether a user ended up returning their product 
SELECT * FROM date_dim; 
-- 3,353 records are NULL (order_ts, order_year, order_quarter, order_season, order_month, order_month_number, order_week_start, order_month_start, order_month_end )
-- No NULLs for order_id

-- ** Ecommerce EDA - Exploratory Data Analysis ** 

-- 1. Total Revenue, Orders, & AOV by Year 
SELECT 
	Order_Year AS Year, 
    SUM(usd_price) AS Revenue,
    COUNT(o.order_id) AS Orders, 
    ROUND(AVG(usd_price),2) AS AOV
FROM orders o 
LEFT JOIN date_dim d
ON o.order_id = d.order_id 
-- WHERE Order_Year IS NOT NULL 
GROUP BY Order_Year
ORDER BY Order_Year; 

-- 2. Total Revenue, Orders, & AOV by Region 
SELECT 
	Region,
    SUM(usd_price) AS Revenue,
    COUNT(o.order_id) AS Orders,
    ROUND(AVG(usd_price),2) AS AOV
FROM orders o 
JOIN customers c 
ON o.customer_id = c.user_id
JOIN geo_lookup g 
ON c.country_code = g.country_code
GROUP BY Region 
ORDER BY Revenue DESC;

-- 3. Refund Rate by Product
SELECT 
	Product_Name, 
    Product_ID, 
    COUNT(product_id) AS Orders, 
    SUM(is_refunded) AS Refunds, 
    ROUND(SUM(is_refunded)/COUNT(product_id) * 100, 2) AS Refund_Rate
FROM orders o 
JOIN order_status os 
ON o.order_id = os.order_id
GROUP BY Product_Name, Product_ID
ORDER BY Product_ID;

-- 4. Refund Rate by Year
SELECT 
	Order_Year, 
	COUNT(o.order_id) AS Orders, 
	SUM(os.is_refunded) AS Refunds,
	ROUND(SUM(os.is_refunded)/COUNT(o.order_id) * 100, 2) AS Refund_Rate
FROM date_dim d
JOIN orders o 
ON d.order_id = o.order_id
JOIN order_status os
ON o.order_id = os.order_id
WHERE Order_Year IS NOT NULL
GROUP BY Order_Year
ORDER BY Order_Year;

-- 5. Revenue by Region 
SELECT 
	Region, 
	SUM(usd_price) AS Revenue
FROM geo_lookup g
JOIN customers c 
ON g.country_code = c.country_code
JOIN orders o
ON c.user_id = o.customer_id
GROUP BY Region 
ORDER BY Revenue DESC;

-- 6. Loyalty vs. Non Loyalty AOV Comparison 
SELECT 
	Is_Loyalty_Member, 
    ROUND(AVG(usd_price),2) AS AOV
FROM customers c 
JOIN orders o 
ON c.user_id = o.customer_id
GROUP BY Is_Loyalty_Member;

-- 7. Loyalty vs. Non-Loyalty AOV Comparison, by Year
SELECT 
	Order_Year, 
    Is_Loyalty_Member, 
    ROUND(AVG(usd_price),2) AS AOV
FROM orders o 
JOIN date_dim d
ON o.order_id = d.order_id 
JOIN customers c 
ON o.customer_id = c.user_id 
AND order_year IS NOT NULL
GROUP BY Order_Year, Is_Loyalty_Member
ORDER by Order_Year;

-- 8. Average Days Till Delivery by Region 
SELECT 
	Region, 
	ROUND(AVG(days_till_delivery),2) AS Avg_Days_Till_Delivery,
	COUNT(o.order_id) AS Total_Orders
FROM geo_lookup g
JOIN customers c
ON g.country_code = c.country_code
JOIN orders o 
ON c.user_id = o.customer_id 
JOIN order_status os 
ON o.order_id = os.order_id
WHERE os.days_till_delivery IS NOT NULL
GROUP BY Region 
ORDER BY Avg_Days_Till_Delivery DESC;

-- 9. Total Revenue, Orders, & AOV by Quarter 
SELECT 
	 Order_Year,
     Order_Quarter, 
	SUM(usd_price) AS Revenue, 
	COUNT(o.order_id) AS Orders, 
	ROUND(AVG(usd_price),2) AS AOV
FROM orders o 
JOIN date_dim d
ON o.order_id = d.order_id 
WHERE Order_Year IS NOT NULL
GROUP BY Order_quarter, Order_year
ORDER BY Order_year, Order_quarter;

-- 10. Refund Rate by Product by Year 
SELECT 
	Order_Year, 
    Product_ID, 
    Product_Name, 
	COUNT(product_id) AS Orders, 
	SUM(is_refunded) AS Refunds, 
	ROUND(SUM(is_refunded)/COUNT(product_id) * 100, 2) AS Refund_Rate
FROM orders o 
JOIN order_status os
ON o.order_id = os.order_id
JOIN date_dim d
ON os.order_id = d.order_id
WHERE Order_Year IS NOT NULL
GROUP BY Order_Year, Product_ID, Product_Name
ORDER BY Order_Year, Product_ID;

-- 11. Revenue Contribution & Order Share by Product by Year 
SELECT 
	Order_Year, 
	Product_ID, 
    Product_Name, 
    SUM(usd_price) AS Revenue_Contribution,
	SUM(SUM(usd_price)) OVER(PARTITION BY order_year) AS Yearly_Revenue,
	ROUND(SUM(usd_price)/SUM(SUM(usd_price)) OVER(PARTITION BY order_year)* 100, 2) AS `Revenue Contribution %`,
    COUNT(o.order_id) AS Order_Contribution,
    SUM(COUNT(o.order_id)) OVER(PARTITION BY order_year) AS `Order Contribution %`,
    ROUND(COUNT(o.order_id)/SUM(COUNT(o.order_id)) OVER(PARTITION BY order_year) * 100, 2) AS `Order Share %`
FROM orders o
JOIN date_dim d 
ON o.order_id = d.order_id
WHERE Order_Year IS NOT NULL
GROUP BY Order_Year, Product_ID, Product_Name
ORDER BY Order_Year, Product_ID;

-- 12. Loyalty Adoption Rate by Year and Region 
SELECT 
	Order_Year, 
    Region, 
	COUNT(DISTINCT user_id) as Customers, 
	COUNT(DISTINCT CASE WHEN is_loyalty_member = 1 THEN user_id END) AS Loyalty_Members,
	ROUND(COUNT(DISTINCT CASE WHEN is_loyalty_member = 1 THEN user_id END)/COUNT(DISTINCT user_id) * 100, 2) AS Loyalty_Adoption_Rate
FROM orders o 
JOIN customers c 
ON o.customer_id = c.user_id
JOIN date_dim d
ON o.order_id = d.order_id
JOIN geo_lookup g 
ON c.country_code = g.country_code
WHERE Order_Year IS NOT NULL
GROUP BY Order_Year, Region 
ORDER BY Order_Year; 

-- 13. Orders per Customer (Loyalty vs. Non Loyalty Members)
SELECT 
	Is_Loyalty_Member, 
	COUNT(DISTINCT user_id) AS Customers, 
    COUNT(order_id) AS Orders, 
    ROUND(AVG(usd_price), 2) AS AOV,
    ROUND(COUNT(order_id)/COUNT(DISTINCT user_id),2) AS Orders_Per_Customer
FROM orders o 
JOIN customers c
ON o.customer_id = c.user_id
GROUP BY is_loyalty_member; 

-- 14. Top 10 Countries by Revenue Overall 
SELECT 
	Country_Name, 
	COUNT(order_id) AS Orders, 
    SUM(usd_price) AS Revenue
FROM geo_lookup g 
JOIN customers c 
ON g.country_code = c.country_code 
JOIN orders o 
ON c.user_id = o.customer_id
GROUP BY Country_Name
ORDER BY Revenue DESC 
LIMIT 10; 

-- 15. Top 10 Countries by Revenue within each Region 
SELECT 
	Region, 
    Country_Name, 
    Revenue 
FROM (SELECT 
		g.region,
        g.country_name, 
        SUM(o.usd_price) AS revenue,
		ROW_NUMBER() OVER(PARTITION BY region ORDER BY SUM(o.usd_price) DESC) AS row_num
FROM geo_lookup g
JOIN customers c
ON g.country_code = c.country_code
JOIN orders o
ON c.user_id = o.customer_id
GROUP BY g.Region, g.Country_Name
ORDER BY g.Region, Revenue DESC) AS Revenue_by_Country
WHERE row_num < 11;

-- 16. Product Performance by Region 
SELECT 
	Region, 
    Product_ID, 
    Product_Name, 
	COUNT(product_id) AS Orders, 
	ROUND(SUM(is_refunded)/COUNT(product_id) * 100, 2) AS Refund_Rate,
	SUM(usd_price) AS Generated_Revenue, 
	ROUND(SUM(usd_price)/COUNT(product_id),2) AS Revenue_Per_Order
FROM geo_lookup g
JOIN customers c 
ON g.country_code = c.country_code 
JOIN orders o 
ON c.user_id = o.customer_id
JOIN order_status os
ON o.order_id = os.order_id
GROUP BY Region, Product_ID, Product_Name
ORDER BY Region, Generated_Revenue DESC;

-- 17. Refund Rate by Region by Year
SELECT 
	g.Region, 
    d.Order_Year, 
    COUNT(os.order_id) AS Orders, 
    SUM(is_refunded) AS Refunds, 
    ROUND(SUM(is_refunded)/COUNT(os.order_id) * 100, 2) AS Refund_Rate
FROM order_status os
JOIN date_dim d
ON os.order_id = d.order_id
JOIN orders o
ON d.order_id = o.order_id
JOIN customers c
ON o.customer_id = c.user_id 
JOIN geo_lookup g
ON c.country_code = g.country_code
WHERE Order_Year IS NOT NULL
GROUP BY g.Region, d.Order_Year
ORDER BY g.Region, d.Order_Year ASC;

-- 18. Total Orders, Revenue by Marketing Channel by Year
SELECT 
	Order_Year,
	Marketing_Channel, 
    COUNT(o.order_id) AS Orders, 
    SUM(usd_price) AS Revenue
FROM orders o 
JOIN customers c 
ON o.customer_id = c.user_id
JOIN date_dim d
ON o.order_id = d.order_id
WHERE marketing_channel != ''
AND Order_Year IS NOT NULL
GROUP BY Marketing_Channel, Order_Year
ORDER BY Marketing_Channel, Order_Year;

-- 19. Total Orders, Revenue by Order Channel, Year
SELECT 
	Order_Year, 
    Order_Channel,
    COUNT(o.order_id) AS Orders, 
    SUM(usd_price) AS Revenue
FROM orders o 
JOIN date_dim d
ON o.order_id = d.order_id
WHERE Order_Year IS NOT NULL
GROUP BY Order_Channel, Order_Year
ORDER BY Order_Channel, Order_Year;