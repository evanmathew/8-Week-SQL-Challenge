# 🍕 Case Study #2-C: Pizza Runner- INGREDIENT OPTIMISATION(Solution)

### 1. What are the standard ingredients for each pizza?

```sql
SELECT
  pn.pizza_name,
  STRING_AGG(pt.topping_name::TEXT, ', ')
FROM
  clean_pizza_recipes AS cpr 
JOIN 
  pizza_toppings AS pt 
ON 
  pt.topping_id = cpr.toppings
JOIN 
  pizza_names AS pn
ON 
  pn.pizza_id = cpr.pizza_id
GROUP BY pn.pizza_name
```

### Output:
| pizza_name | string_agg                                                            |
| ---------- | --------------------------------------------------------------------- |
| Meatlovers | BBQ Sauce, Pepperoni, Cheese, Salami, Chicken, Bacon, Mushrooms, Beef |
| Vegetarian | Tomato Sauce, Cheese, Mushrooms, Onions, Peppers, Tomatoes            |


<br>

### 2. What was the most commonly added extra?

```sql
WITH most_toppings_added AS (
  SELECT
    order_id,
    TRIM(UNNEST(string_to_array(extras, ','))) AS extras
  FROM 
    clean_customer_orders
  WHERE 
    extras IS NOT NULL
)

SELECT
  pt.topping_name AS "Topping Name",
  COUNT(extras) AS "Total Count of Most Extra Topping's Added"
FROM 
  most_toppings_added as mta 
JOIN 
  pizza_toppings AS pt 
ON pt.topping_id = mta.extras::NUMERIC
GROUP BY 
  pt.topping_name
ORDER BY 
  "Total Count of Most Extra Topping's Added" DESC
LIMIT 1
```

### Output:
| Topping Name | Total Count of Most Extra Topping's Added |
| ------------ | ----------------------------------------- |
| Bacon        | 4                                         |


<br>

### 3. What was the most common exclusion?

```sql
WITH most_toppings_added AS (
  SELECT
    order_id,
    TRIM(UNNEST(string_to_array(exclusions, ','))) AS exclusions
  FROM 
    clean_customer_orders
  WHERE 
    exclusions IS NOT NULL
)

SELECT
  pt.topping_name AS "Topping Name",
  COUNT(exclusions) AS "Total Count of Most Topping Removed"
FROM 
  most_toppings_added as mta 
JOIN 
  pizza_toppings AS pt 
ON pt.topping_id = mta.exclusions::NUMERIC
GROUP BY 
  pt.topping_name
ORDER BY 
  "Total Count of Most Topping Removed" DESC
LIMIT 1
```

### Output:
| Topping Name | Total Count of Most Topping Removed |
| ------------ | ----------------------------------- |
| Cheese       | 4                                   |

<br>

### 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
- Meat Lovers
- Meat Lovers - Exclude Beef
- Meat Lovers - Extra Bacon
- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers

```sql

```