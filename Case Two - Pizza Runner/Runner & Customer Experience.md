# 🍜 Case Study #2-B: Pizza Runner- RUNNER & CUSTOMER EXPERIENCE (Solution)

### 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)

```sql
SELECT
  --DATE_PART('WEEK', registration_date) AS week_number,
  TO_CHAR(registration_date,'WW') AS week_number,
  --FLOOR((registration_date - DATE '2021-01-01')/7) AS week_number, 
  COUNT(runner_id) AS no_of_runners_registered
FROM 
  runners 
GROUP BY 
  week_number
ORDER BY 
  week_number
```

### Output:
| week_number | no_of_runners_registered |
| ----------- | ------------------------ |
| 01          | 2                        |
| 02          | 1                        |
| 03          | 1                        |

<br>


### 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?

```sql
SELECT 
    cro.runner_id,
    ROUND(
        AVG(
            EXTRACT(
                EPOCH FROM (
                    (cro.pickup_date + cro.pickup_time)
                    - (cco.order_date + cco.order_time)
                )
            ) / 60
        ),
        2
    ) AS avg_minutes_to_pickup
FROM 
  clean_customer_orders cco
JOIN 
  clean_runner_orders cro
ON 
  cco.order_id = cro.order_id
WHERE 
  cro.pickup_time IS NOT NULL
GROUP BY 
  cro.runner_id
ORDER BY 
  cro.runner_id
```

### Output:
| runner_id | avg_minutes_to_pickup |
| --------- | --------------------- |
| 1         | 15.68                 |
| 2         | 23.72                 |
| 3         | 10.47                 |


<br>

### 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?

```sql
WITH order_metrics AS (
    SELECT
        cco.order_id,
        COUNT(*) AS count_of_pizza,
        EXTRACT(
            EPOCH FROM (
                (cro.pickup_date + cro.pickup_time)
                - (cco.order_date + cco.order_time)
            )
        ) / 60 AS prep_time
    FROM clean_customer_orders cco
    JOIN clean_runner_orders cro
        ON cro.order_id = cco.order_id
    WHERE cro.pickup_time IS NOT NULL
    GROUP BY
        cco.order_id,
        cro.pickup_date,
        cro.pickup_time,
        cco.order_date,
        cco.order_time
)
SELECT 
  count_of_pizza,
  ROUND(AVG(prep_time),2)
FROM order_metrics
GROUP BY count_of_pizza
ORDER BY count_of_pizza
```

### Output:
| count_of_pizza | round |
| -------------- | ----- |
| 3              | 29.28 |
| 2              | 18.38 |
| 1              | 12.36 |


<br>

### 4. What was the average distance travelled for each customer?

```sql
SELECT 
  cco.customer_id,
  ROUND(AVG(cro.distance_in_km),2) AS avg_distance
FROM 
  clean_runner_orders AS cro
JOIN 
  clean_customer_orders AS cco
ON 
  cro.order_id = cco.order_id
GROUP BY 
  cco.customer_id
ORDER BY 
  customer_id
```

### Output:
| customer_id | avg_distance |
| ----------- | ------------ |
| 101         | 20.00        |
| 102         | 16.73        |
| 103         | 23.40        |
| 104         | 10.00        |
| 105         | 25.00        |


<br>

### 5. What was the difference between the longest and shortest delivery times for all orders?

```sql

```