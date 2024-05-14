-- sales analysis
-- Total sales revenues by day
SELECT 
    order_date,
    SUM(total_revenue) OVER (
        ORDER BY order_date 
        ROWS BETWEEN 6 PRECEDING AND CURRENT ROW -- Adjust the window size as needed
    ) AS rolling_revenue
FROM (
    SELECT 
        DATE(created_at) AS order_date,
        SUM(price_usd) AS total_revenue
    FROM 
        orders
    GROUP BY 
        order_date
) AS subquery
ORDER BY 
    order_date;

 -- TopSellingProducts
SELECT p.product_id,
       p.product_name,
       SUM(o.price_usd) AS total_revenue
FROM orders o
JOIN products p ON o.primary_product_id = p.product_id
GROUP BY p.product_id, p.product_name
ORDER BY total_revenue DESC;

-- average order
SELECT AVG(price_usd) AS average_order_value
FROM orders;

-- Query to identify products frequently bought together for cross-selling strategies
SELECT 
    product1.product_id AS product_id_1,
    MAX(product1.product_name) AS product_name_1,
    product2.product_id AS product_id_2,
    MAX(product2.product_name) AS product_name_2,
    COUNT(*) AS co_occurrences
FROM 
    order_item AS item1
JOIN 
    order_item AS item2 ON item1.order_id = item2.order_id AND item1.product_id != item2.product_id
JOIN 
    products AS product1 ON item1.product_id = product1.product_id
JOIN 
    products AS product2 ON item2.product_id = product2.product_id
GROUP BY 
    product1.product_id, product2.product_id
ORDER BY 
    co_occurrences DESC
LIMIT 0, 1000;

-- -- Conversion performance analysis
-- Analysis of conversion performance from Funnels
SELECT 
            YEAR(wp.created_at) AS year, QUARTER(wp.created_at) AS quater, 
            pageview_url, COUNT(device_type) AS count
          FROM 
            website_pageviews AS wp
            LEFT JOIN `website _sessions` AS ws 
                ON wp.website_session_id = ws.website_session_id
          GROUP BY pageview_url, YEAR(wp.created_at), QUARTER(wp.created_at)
          HAVING pageview_url NOT IN ('/lander-1', '/lander-2', '/lander-3', '/lander-4', '/lander-5')
          ORDER BY YEAR(wp.created_at), QUARTER(wp.created_at)
          LIMIT 10;
-- Operational Efficiency Analysis
-- Calculate session-to-purchase time

SELECT 
    o.order_id,
    MIN(s.created_at) AS session_start_time,
    MAX(o.created_at) AS order_created_at,
    TIMEDIFF(MAX(o.created_at), MIN(s.created_at)) AS session_to_purchase_time
FROM 
    orders o
JOIN 
    `website _sessions` s ON o.website_session_id = s.website_session_id
GROUP BY 
    o.order_id;

-- website traffic analysis
SELECT 
            YEAR(wp.created_at) AS year, QUARTER(wp.created_at) AS quarter, 
            device_type, COUNT(device_type) AS count_devive
          FROM 
            website_pageviews AS wp
            LEFT JOIN `website _sessions` AS ws 
                ON wp.website_session_id = ws.website_session_id
          GROUP BY device_type, YEAR(wp.created_at), QUARTER(wp.created_at)
          ORDER BY YEAR(wp.created_at), QUARTER(wp.created_at)
          LIMIT 10;
-- Market basket analysis
-- Query to identify frequently co-occurring products
SELECT 
     product1.product_id AS product_id_1,
     MAX(product1.product_name) AS product_name_1,
     product2.product_id AS product_id_2,
     MAX(product2.product_name) AS product_name_2,
     COUNT(*) AS co_occurrences
 FROM 
     order_item AS item1
 JOIN 
     order_item AS item2 ON item1.order_id = item2.order_id AND item1.product_id < item2.product_id
 JOIN 
     products AS product1 ON item1.product_id = product1.product_id
 JOIN 
     products AS product2 ON item2.product_id = product2.product_id
 GROUP BY 
     product1.product_id, product2.product_id
 ORDER BY 
     co_occurrences DESC
 LIMIT 0, 1000;

-- revenue and margin analysis 
SELECT 
            YEAR(created_at) year, QUARTER(created_at) quater,
            SUM(price_usd) AS revenue,
            SUM(price_usd - cogs_usd) AS margin
          FROM orders AS o
          GROUP BY YEAR(created_at), QUARTER(created_at)
          ORDER BY YEAR(created_at), QUARTER(created_at)
          LIMIT 10;