# 🍜 Case Study #2-A: Pizza Runner- PIZZA METRICS (Solution)

###  1. How many pizzas were ordered?

```sql
SELECT COUNT(order_id) AS "Total Pizza Ordered" 
FROM clean_customer_orders 
```

#### Output:
| Total Pizza Ordered |
| ------------------- |
| 14                  |


<br>


### 2. How many unique customer orders were made?

```sql
SELECT 
  COUNT(DISTINCT order_id) AS "Number Of Unique Orders" 
FROM 
  clean_customer_orders 
```


### Output:
| Number Of Unique Orders |
| ----------------------- |
| 10                      |

<br>

### 3. How many successful orders were delivered by each runner?

```sql
SELECT 
  COUNT(order_id) AS "Number of Successfull Orders"
FROM 
  clean_runner_orders
WHERE 
  cancellation IS NULL
```

### Output:
| Number of Successfull Orders |
| ---------------------------- |
| 8                            |


<br>


### 4. How many of each type of pizza was delivered?

```sql
SELECT 
  co.pizza_id AS "Pizza ID",
  pizza_type.pizza_name AS "Pizza Type Name",
  COUNT(co.pizza_id) AS "Number of Pizza's delivered"
FROM 
  pizza_names AS pizza_type
JOIN 
  clean_customer_orders AS co
ON
  co.pizza_id = pizza_type.pizza_id
JOIN 
  clean_runner_orders AS ro
ON
  ro.order_id = co.order_id
WHERE 
  ro.cancellation IS NULL
GROUP BY 
  co.pizza_id, pizza_type.pizza_name
```

### Output:
| Pizza ID | Pizza Type Name | Number of Pizza's delivered |
| -------- | --------------- | --------------------------- |
| 1        | Meatlovers      | 9                           |
| 2        | Vegetarian      | 3                           |


<br>


###  5. How many Vegetarian and Meatlovers were ordered by each customer?

```sql
SELECT
  customer_id AS "Customer ID",
  SUM(
    CASE
      WHEN pizza_id = 1 THEN 1
      ELSE 0
    END
  ) AS "Count of Meat Type Pizza Ordered",
  SUM(
    CASE
      WHEN pizza_id = 2 THEN 1
      ELSE 0
    END
  ) AS "Count of Veg Type Pizza Ordered"
FROM
  clean_customer_orders
GROUP BY 
  customer_id
ORDER BY 
  customer_id
```

### Output:
| Customer ID | Count of Meat Type Pizza Ordered | Count of Veg Type Pizza Ordered |
| ----------- | -------------------------------- | ------------------------------- |
| 101         | 2                                | 1                               |
| 102         | 2                                | 1                               |
| 103         | 3                                | 1                               |
| 104         | 3                                | 0                               |
| 105         | 0                                | 1                               |


<br>


### 6. What was the maximum number of pizzas delivered in a single order?

```sql
SELECT 
  customer_id AS "Customer ID", 
  order_id AS "Order ID",
  COUNT(pizza_id) AS "Number of Pizza"
FROM 
  clean_customer_orders
GROUP BY 
  customer_id,order_id
ORDER BY "Number of Pizza" DESC
LIMIT 1
```


### Output:
| Customer ID | Order ID | Number of Pizza |
| ----------- | -------- | --------------- |
| 103         | 4        | 3               |


<br>

### 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?

```sql
SELECT 
  co.customer_id,
  SUM(
    CASE 
      WHEN co.exclusions IS NOT NULL OR co.extras IS NOT NULL THEN 1
      ELSE 0 
    END
  ) AS "No of Pizza's With Change",
  SUM(
    CASE 
      WHEN co.exclusions IS NULL AND co.extras IS NULL THEN 1
      ELSE 0 
    END 
  ) AS "No of Pizza's Without Change"
FROM clean_customer_orders AS co
JOIN
  clean_runner_orders AS ro
ON
  co.order_id = ro.order_id
WHERE
  ro.cancellation IS NULL
GROUP BY
  co.customer_id
ORDER BY 
  co.customer_id
```

### Output:
| customer_id | No of Pizza's With Change | No of Pizza's Without Change |
| ----------- | ------------------------- | ---------------------------- |
| 101         | 0                         | 2                            |
| 102         | 0                         | 3                            |
| 103         | 3                         | 0                            |
| 104         | 2                         | 1                            |
| 105         | 1                         | 0                            |


<br>


### 8. How many pizzas were delivered that had both exclusions and extras?

```sql
SELECT 
  co.customer_id,
  SUM(
    CASE 
      WHEN co.exclusions IS NOT NULL AND co.extras IS NOT NULL THEN 1
      ELSE 0
    END
  ) AS "Number of Pizza's That Had Both Exclusions & Extras"
FROM 
  clean_customer_orders AS co
JOIN 
  clean_runner_orders AS ro
ON
  co.order_id = ro.order_id
WHERE 
  ro.cancellation IS NULL 
GROUP BY 
  co.customer_id
```

### Output:
| customer_id | Number of Pizza's That Had Both Exclusions & Extras |
| ----------- | --------------------------------------------------- |
| 101         | 0                                                   |
| 102         | 0                                                   |
| 103         | 0                                                   |
| 104         | 1                                                   |
| 105         | 0                                                   |


<br>

### 9. What was the total volume of pizzas ordered for each hour of the day?

```sql
SELECT 
  EXTRACT(HOUR FROM order_time) AS "Hour Of The Day",
  COUNT(*) AS "Number of Pizza Ordered"
FROM 
  clean_customer_orders
GROUP BY 
  "Hour Of The Day"
ORDER BY 
  "Hour Of The Day"
```

### Output:
| Hour Of The Day | Number of Pizza Ordered |
| --------------- | ----------------------- |
| 11              | 1                       |
| 13              | 3                       |
| 18              | 3                       |
| 19              | 1                       |
| 21              | 3                       |
| 23              | 3                       |


<br>


### 10. What was the volume of orders for each day of the week?

```sql
SELECT 
  TO_CHAR(order_date,'Day') AS "Day Of The Week",
  COUNT(order_id) AS "Pizza Ordered",
  ROUND(100*COUNT(order_id)/SUM(COUNT(order_id)) OVER(),2) AS "Volume Percentage of Total Pizza Ordered"
FROM 
  clean_customer_orders
GROUP BY 
  "Day Of The Week"
ORDER BY 
  "Pizza Ordered" DESC 
```

### Output:
| Day Of The Week | Pizza Ordered | Volume Percentage of Total Pizza Ordered |
| --------------- | ------------- | ---------------------------------------- |
| Saturday        | 5             | 35.71                                    |
| Wednesday       | 5             | 35.71                                    |
| Thursday        | 3             | 21.43                                    |
| Friday          | 1             | 7.14                                     |