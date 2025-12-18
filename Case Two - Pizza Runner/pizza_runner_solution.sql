----------------------------------
-- CASE STUDY #1: DANNY'S DINER --
----------------------------------

-- Author: Evan Saju Mathew
-- Date: 17/12/2025 
-- Tool used: Postgres

--------------------------
-- CASE STUDY QUESTIONS --
--------------------------


-- 1. What is the total amount each customer spent at the restaurant?
SELECT 
  s.customer_id, 
  CONCAT('$ ',SUM(m.price)) AS TotalAmount
FROM 
  sales AS s
JOIN 
  menu as m 
ON 
  s.product_id = m.product_id
GROUP BY 
  s.customer_id
ORDER BY 
  s.customer_id ASC



-- 2. How many days has each customer visited the restaurant?
SELECT 
  customer_id, 
  COUNT(DISTINCT (order_date))
FROM 
  sales
GROUP BY 
  customer_id
ORDER BY 
  customer_id ASC



-- 3. What was the first item from the menu purchased by each customer?
WITH CTE AS(
  SELECT customer_id, MIN(order_date) as first_order
  FROM sales
  GROUP BY customer_id
  )

SELECT s.customer_id, STRING_AGG(distinct m.product_name,', ') AS product_name
FROM sales as s
JOIN menu AS m ON s.product_id = m.product_id
WHERE (s.customer_id, s.order_date) IN (SELECT * FROM CTE)
GROUP BY s.customer_id
ORDER BY customer_id



-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
WITH most_ordered_product AS (
  SELECT 
    product_id, 
    COUNT(*) AS no_of_times
  FROM 
    sales 
  GROUP BY 
    product_id
  ORDER BY 
    no_of_times DESC
  LIMIT 1
  )
  
SELECT 
  m.product_name AS Most_Purchased_Item, 
  mo.no_of_times AS number_of_times
FROM 
  most_ordered_product AS mo
JOIN 
  menu AS m
ON 
  m.product_id = mo.product_id
WHERE 
  (mo.product_id,mo.no_of_times) IN (SELECT * FROM most_ordered_product)




-- 5. Which item was the most popular for each customer?
WITH most_ordered_rank AS
  (
  SELECT 
    customer_id, 
    product_id,
    COUNT(*) AS no_of_times,
    DENSE_RANK() OVER(PARTITION BY customer_id ORDER BY COUNT(product_id) DESC) AS ordered_rank
  FROM 
    sales
  GROUP BY 
    customer_id,product_id
  )

SELECT 
  mop.customer_id, 
  STRING_AGG(m.product_name,', ') as product_name,
  no_of_times
FROM 
  most_ordered_rank AS mop
JOIN 
  menu AS m
ON mop.product_id = m.product_id
WHERE 
  ordered_rank = 1
GROUP BY 
  customer_id ,no_of_times



-- 6. Which item was purchased first by the customer after they became a member?
WITH first_order_date_after_memb AS (
  SELECT 
    s.customer_id, 
    MIN(s.order_date)
  FROM 
    sales AS s
  JOIN 
    members AS m ON (s.customer_id = m.customer_id) AND (m.join_date <= s.order_date)
  GROUP BY 
    s.customer_id
  )

  
SELECT 
  s.customer_id, 
  STRING_AGG(m.product_name,', ') AS product_names, 
  s.order_date
FROM 
  sales AS s
JOIN 
  menu AS m 
ON 
  s.product_id = m.product_id
WHERE 
  (s.customer_id, s.order_date) IN (SELECT * FROM first_order_date_after_memb)
GROUP BY 
  s.customer_id, order_date
ORDER BY s.customer_id ASC




-- 7. Which item was purchased just before the customer became a member?
WITH orders_date_before_memb AS (
  SELECT 
    s.customer_id, 
    MAX(s.order_date)
  FROM 
    sales AS s
  JOIN 
    members AS m ON (s.customer_id = m.customer_id) AND (s.order_date < m.join_date)
  GROUP BY 
    s.customer_id
  )

  
SELECT 
  s.customer_id, 
  STRING_AGG(m.product_name,', ') AS product_names, 
  s.order_date
FROM 
  sales AS s
JOIN 
  menu AS m 
ON 
  s.product_id = m.product_id
WHERE 
  (s.customer_id, s.order_date) IN (SELECT * FROM orders_date_before_memb)
GROUP BY 
  s.customer_id, order_date
ORDER BY s.customer_id ASC, product_names 



-- 8. What is the total items and amount spent for each member before they became a member?
SELECT 
  s.customer_id, 
  COUNT(s.product_id) AS Total_products,
  CONCAT('$ ',SUM(m.price)) AS Total_Amount
FROM 
  sales as s
JOIN 
  menu AS m 
ON 
  s.product_id =m.product_id
JOIN 
  members AS mb 
ON mb.customer_id = s.customer_id 
WHERE 
  s.order_date < mb.join_date
GROUP BY 
  s.customer_id
ORDER BY 
  s.customer_id



-- 9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
SELECT 
  s.customer_id,
  SUM(
    CASE WHEN m.product_name = 'sushi' THEN m.price*20 ELSE m.price*10 END
  ) AS total_points
FROM 
  sales AS s
JOIN
  menu AS m
ON 
  m.product_id = s.product_id
GROUP BY 
  s.customer_id
ORDER BY 
  s.customer_id



-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - 
-- how many points do customer A and B have at the end of January
-- Asssumption: Points is rewarded only after the customer joins in the membership program
WITH seven_day_offer_date AS (
  SELECT 
    customer_id,
    join_date + INTERVAL '6 DAYS' AS last_day,
    join_date
  FROM 
    members
  GROUP BY 
    customer_id, join_date
)

SELECT 
  s.customer_id,
  SUM(
    CASE
      WHEN s.order_date BETWEEN sod.join_date AND sod.last_day THEN m.price * 20
      WHEN s.order_date > sod.last_day AND m.product_name = 'sushi' THEN m.price * 20
      WHEN s.order_date > sod.last_day THEN m.price * 10
    END 
  ) AS customer_points
FROM 
  sales AS s
JOIN 
  seven_day_offer_date AS sod ON sod.customer_id = s.customer_id
JOIN
  menu AS m ON m.product_id = s.product_id
WHERE
  s.order_date::date <= DATE '2021-01-31'
GROUP BY 
  s.customer_id
ORDER BY 
  s.customer_id



----------------------------------
--             END              --
----------------------------------