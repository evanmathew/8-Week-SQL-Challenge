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
WITH toppings_cte AS (
    -- Extras
    SELECT 
        cco.order_id,
        'Extra' AS type,
        STRING_AGG(pt.topping_name, ', ' ORDER BY pt.topping_name) AS topping_name
    FROM clean_customer_orders cco
    CROSS JOIN LATERAL
        UNNEST(string_to_array(cco.extras, ',')) AS e(value)
    JOIN pizza_toppings pt
        ON pt.topping_id = TRIM(e.value)::INT
    WHERE cco.extras IS NOT NULL
    GROUP BY cco.order_id

    UNION ALL

    -- Exclusions
    SELECT 
        cco.order_id,
        'Exclude' AS type,
        STRING_AGG(pt.topping_name, ', ' ORDER BY pt.topping_name) AS topping_name
    FROM clean_customer_orders cco
    CROSS JOIN LATERAL
        UNNEST(string_to_array(cco.exclusions, ',')) AS e(value)
    JOIN pizza_toppings pt
        ON pt.topping_id = TRIM(e.value)::INT
    WHERE cco.exclusions IS NOT NULL
    GROUP BY cco.order_id
)

SELECT 
    cco.order_id,
    cco.customer_id,
    cco.pizza_id,
    pn.pizza_name
    || COALESCE(
        ' - Exclude ' || excl.topping_name,
        ''
    )
    || COALESCE(
        ' - Extra ' || ext.topping_name,
        ''
    ) AS pizza_name
FROM clean_customer_orders cco
JOIN pizza_names pn
    ON pn.pizza_id = cco.pizza_id
LEFT JOIN toppings_cte excl
    ON excl.order_id = cco.order_id
   AND excl.type = 'Exclude'
LEFT JOIN toppings_cte ext
    ON ext.order_id = cco.order_id
   AND ext.type = 'Extra'
ORDER BY cco.order_id;
```

### Output:
| order_id | customer_id | pizza_id | pizza_name                                                      |
| -------- | ----------- | -------- | --------------------------------------------------------------- |
| 1        | 101         | 1        | Meatlovers                                                      |
| 2        | 101         | 1        | Meatlovers                                                      |
| 3        | 102         | 2        | Vegetarian                                                      |
| 3        | 102         | 1        | Meatlovers                                                      |
| 4        | 103         | 1        | Meatlovers - Exclude Cheese, Cheese, Cheese                     |
| 4        | 103         | 1        | Meatlovers - Exclude Cheese, Cheese, Cheese                     |
| 4        | 103         | 2        | Vegetarian - Exclude Cheese, Cheese, Cheese                     |
| 5        | 104         | 1        | Meatlovers - Extra Bacon                                        |
| 6        | 101         | 2        | Vegetarian                                                      |
| 7        | 105         | 2        | Vegetarian - Extra Bacon                                        |
| 8        | 102         | 1        | Meatlovers                                                      |
| 9        | 103         | 1        | Meatlovers - Exclude Cheese - Extra Bacon, Chicken              |
| 10       | 104         | 1        | Meatlovers - Exclude BBQ Sauce, Mushrooms - Extra Bacon, Cheese |
| 10       | 104         | 1        | Meatlovers - Exclude BBQ Sauce, Mushrooms - Extra Bacon, Cheese |


<br>

### 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

```sql
WITH base_ingredients AS (
    SELECT 
        cco.order_id,
        cco.customer_id,
        cco.pizza_id,
        cpr.toppings AS topping_id,
        1 AS qty
    FROM clean_customer_orders cco
    JOIN clean_pizza_recipes cpr
        ON cpr.pizza_id = cco.pizza_id
),

extra_toppings AS (
    SELECT 
        cco.order_id,
        cco.customer_id,
        cco.pizza_id,
        TRIM(val)::INT AS topping_id,
        1 AS qty
    FROM clean_customer_orders cco
    CROSS JOIN LATERAL
        UNNEST(string_to_array(cco.extras, ',')) val
    WHERE cco.extras IS NOT NULL
),

exclude_toppings AS (
    SELECT 
        cco.order_id,
        cco.customer_id,
        cco.pizza_id,
        TRIM(val)::INT AS topping_id,
        -1 AS qty
    FROM clean_customer_orders cco
    CROSS JOIN LATERAL
        UNNEST(string_to_array(cco.exclusions, ',')) val
    WHERE cco.exclusions IS NOT NULL
),

pizza_topping_agg AS (
    SELECT
        order_id,
        customer_id,
        pizza_id,
        topping_id,
        SUM(qty) AS final_qty
    FROM (
        SELECT * FROM base_ingredients
        UNION ALL
        SELECT * FROM extra_toppings
        UNION ALL
        SELECT * FROM exclude_toppings
    ) t
    GROUP BY order_id, customer_id, pizza_id, topping_id
    HAVING SUM(qty) > 0
),

final_ingredients AS (
    SELECT
        pta.order_id,
        pta.customer_id,
        pn.pizza_name,
        pt.topping_name,
        pta.final_qty
    FROM pizza_topping_agg pta
    JOIN pizza_names pn
        ON pn.pizza_id = pta.pizza_id
    JOIN pizza_toppings pt
        ON pt.topping_id = pta.topping_id
)

SELECT
    order_id,
    customer_id,
    pizza_name || ' : ' ||
    STRING_AGG(
        CASE
            WHEN final_qty > 1 THEN final_qty || 'x - ' || topping_name
            ELSE topping_name
        END,
        ', ' ORDER BY topping_name
    ) AS ingredient_list
FROM final_ingredients
GROUP BY order_id, customer_id, pizza_name
ORDER BY order_id;
```


### Output:
| order_id | customer_id | ingredient_list                                                                                                  |
| -------- | ----------- | ---------------------------------------------------------------------------------------------------------------- |
| 1        | 101         | Meatlovers : Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami                               |
| 2        | 101         | Meatlovers : Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami                               |
| 3        | 102         | Meatlovers : Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami                               |
| 3        | 102         | Vegetarian : Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce                                          |
| 4        | 103         | Meatlovers : 2x - Bacon, 2x - BBQ Sauce, 2x - Beef, 2x - Chicken, 2x - Mushrooms, 2x - Pepperoni, 2x - Salami    |
| 4        | 103         | Vegetarian : Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce                                                  |
| 5        | 104         | Meatlovers : 2x - Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami                          |
| 6        | 101         | Vegetarian : Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce                                          |
| 7        | 105         | Vegetarian : Bacon, Cheese, Mushrooms, Onions, Peppers, Tomatoes, Tomato Sauce                                   |
| 8        | 102         | Meatlovers : Bacon, BBQ Sauce, Beef, Cheese, Chicken, Mushrooms, Pepperoni, Salami                               |
| 9        | 103         | Meatlovers : 2x - Bacon, BBQ Sauce, Beef, 2x - Chicken, Mushrooms, Pepperoni, Salami                             |
| 10       | 104         | Meatlovers : 3x - Bacon, BBQ Sauce, 2x - Beef, 3x - Cheese, 2x - Chicken, Mushrooms, 2x - Pepperoni, 2x - Salami |

<br>

### 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

```sql
WITH base_ingredients AS (
    SELECT 
        cco.order_id,
        cpr.toppings AS topping_id,
        1 AS qty
    FROM clean_customer_orders cco
    JOIN clean_pizza_recipes cpr
        ON cpr.pizza_id = cco.pizza_id
    JOIN clean_runner_orders cro
        ON cro.order_id = cco.order_id
    WHERE cro.cancellation IS NULL
),

extra_toppings AS (
    SELECT 
        cco.order_id,
        TRIM(val)::INT AS topping_id,
        1 AS qty
    FROM clean_customer_orders cco
    JOIN clean_runner_orders cro
        ON cro.order_id = cco.order_id
    CROSS JOIN LATERAL
        UNNEST(string_to_array(cco.extras, ',')) val
    WHERE cco.extras IS NOT NULL
      AND cro.cancellation IS NULL
),

exclude_toppings AS (
    SELECT 
        cco.order_id,
        TRIM(val)::INT AS topping_id,
        -1 AS qty
    FROM clean_customer_orders cco
    JOIN clean_runner_orders cro
        ON cro.order_id = cco.order_id
    CROSS JOIN LATERAL
        UNNEST(string_to_array(cco.exclusions, ',')) val
    WHERE cco.exclusions IS NOT NULL
      AND cro.cancellation IS NULL
),

ingredient_totals AS (
    SELECT
        topping_id,
        SUM(qty) AS total_qty
    FROM (
        SELECT * FROM base_ingredients
        UNION ALL
        SELECT * FROM extra_toppings
        UNION ALL
        SELECT * FROM exclude_toppings
    ) t
    GROUP BY topping_id
    HAVING SUM(qty) > 0
)

SELECT
    pt.topping_name,
    it.total_qty
FROM ingredient_totals it
JOIN pizza_toppings pt
    ON pt.topping_id = it.topping_id
ORDER BY it.total_qty DESC;
```

### Output:
| topping_name | total_qty |
| ------------ | --------- |
| Bacon        | 12        |
| Mushrooms    | 11        |
| Cheese       | 10        |
| Pepperoni    | 9         |
| Salami       | 9         |
| Chicken      | 9         |
| Beef         | 9         |
| BBQ Sauce    | 8         |
| Tomato Sauce | 3         |
| Onions       | 3         |
| Peppers      | 3         |
| Tomatoes     | 3         |


