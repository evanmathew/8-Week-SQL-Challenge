# 🍕 Case Study #2-D: Pizza Runner- Pricing and Ratings (Solution)

### 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?

```sql
SELECT 
  CONCAT(
    '$ ',
    SUM(
      CASE 
        WHEN cco.pizza_id = 1 THEN 12
        ELSE 10  
        END)) AS "Total Money Earned "
FROM 
	clean_customer_orders cco 
JOIN 
	clean_runner_orders cro 
ON 
	cco.order_id = cro.order_id
WHERE 
	cro.cancellation IS NULL 
```

### Output:
| Total Money Earned  |
| ------------------- |
| $ 138               |

<br>

### 2. What if there was an additional $1 charge for any pizza extras? Add cheese is $1 extra

```sql
SELECT 
    '$ ' ||
    SUM(
        CASE 
            WHEN cco.pizza_id = 1 THEN 12
            ELSE 10
        END
        +
        COALESCE(extra.extra_count, 0)
    ) AS "Total Money Earned"
FROM 
  clean_customer_orders cco
JOIN 
  clean_runner_orders cro
ON 
  cco.order_id = cro.order_id

LEFT JOIN LATERAL (
    SELECT COUNT(*) AS extra_count
    FROM UNNEST(string_to_array(cco.extras, ',')) AS e(val)
) extra ON TRUE

WHERE 
  cro.cancellation IS NULL
```

### Output:
| Total Money Earned |
| ------------------ |
| $ 142              |


<br>

### 3. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?

```sql
WITH pizza_cost AS (
  SELECT 
    SUM(
      CASE 
        WHEN cco.pizza_id = 1 THEN 12
        ELSE 10
      END) AS total_pizza_cost
  FROM 
    clean_customer_orders cco 
  JOIN 
    clean_runner_orders cro ON cco.order_id = cro.order_id
  WHERE 
    cro.cancellation IS NULL
),
delivery_runners_cost AS (
  SELECT 
    ROUND(SUM(0.30*distance_in_km),2) AS delivery_cost
  FROM 
    clean_runner_orders
  WHERE 
    cancellation IS NULL
  )

SELECT 
  CONCAT(
    '$ ',
    (total_pizza_cost - delivery_cost)
    ) AS "Total Profit"
FROM 
  pizza_cost, delivery_runners_cost
```

### Output:
| Total Profit |
| ------------ |
| $ 94.44      |

