# 🧹 Data Cleaning 
<br>

## 📌 Overview


Before performing any analysis in the Pizza Runner case study, the raw data requires significant cleaning.


Several columns contain:

- Text values representing missing data ('null', 'NULL', empty strings)

- Mixed data types (numbers stored as text)

- Units embedded inside values (e.g. km, minutes)

- Incorrect or inconsistent timestamps

<br>
---
<br>

## **🍱 runner_orders**

### Issues Identified

- pickup_time contains 'null' and empty values

- distance includes units like km and invalid text

- duration includes text such as minutes

- Inconsistent casing (null, NULL, Null)

### Code:

```sql
DROP TABLE IF EXISTS clean_runner_orders;

CREATE TABLE clean_runner_orders AS
SELECT 
  order_id, 
  runner_id,
  -- Pickup Date
  CASE 
    WHEN 
    LOWER(pickup_time) = 'null' OR pickup_time = '' THEN NULL
    ELSE pickup_time::DATE 
  END  AS pickup_date,
-- Pickup Time
  CASE 
    WHEN LOWER(pickup_time) = 'null' OR pickup_time = '' THEN NULL
    ELSE pickup_time::TIME 
  END AS pickup_time,
-- Distance  
  CASE 
    WHEN LOWER(distance) = 'null' OR distance = '' THEN NULL
    ELSE REGEXP_REPLACE(distance, '[a-z]+','')::NUMERIC
  END AS distance_in_km,
-- Duration
CASE 
  WHEN LOWER(duration) = 'null' OR distance = '' THEN NULL
  ELSE REGEXP_REPLACE(duration, '[a-z]+','')::NUMERIC
END AS duration_in_min,
-- Cancellation
CASE 
  WHEN LOWER(cancellation) = 'null' OR cancellation = '' THEN NULL
  ELSE cancellation
END AS cancellation
FROM 
  runner_orders;
```
### Output:
| order_id | runner_id | pickup_date | pickup_time | distance_in_km | duration_in_min | cancellation            |
| -------- | --------- | ----------- | ----------- | -------------- | --------------- | ----------------------- |
| 1        | 1         | 2020-01-01  | 18:15:34    | 20             | 32              |                         |
| 2        | 1         | 2020-01-01  | 19:10:54    | 20             | 27              |                         |
| 3        | 1         | 2020-01-03  | 00:12:37    | 13.4           | 20              |                         |
| 4        | 2         | 2020-01-04  | 13:53:03    | 23.4           | 40              |                         |
| 5        | 3         | 2020-01-08  | 21:10:57    | 10             | 15              |                         |
| 6        | 3         |             |             |                |                 | Restaurant Cancellation |
| 7        | 2         | 2020-01-08  | 21:30:45    | 25             | 25              |                         |
| 8        | 2         | 2020-01-10  | 00:15:02    | 23.4           | 15              |                         |
| 9        | 2         |             |             |                |                 | Customer Cancellation   |
| 10       | 1         | 2020-01-11  | 18:50:20    | 10             | 10              |                         |


<br>
<br>

## **🧾 customer_orders**

### Issues Identified

Exclusions and extras contain:

- 'null'
- Empty strings
- Comma-separated values stored as text

Data Manipulation:

- Seperating timestamp into two columns such as `pickup_date` and `pickup_time` 
- Formating Distance and Duration into NUMERIC  

### Code
```sql
DROP TABLE IF EXISTS clean_customer_orders;
CREATE TABLE clean_customer_orders AS 
SELECT 
  order_id,
  customer_id,
  pizza_id,
  CASE
    WHEN exclusions = '' THEN NULL 
    WHEN (exclusions = 'null')  OR (exclusions = 'Null') THEN NULL
    ELSE exclusions
  END AS exclusions,
  CASE
    WHEN extras = '' THEN NULL 
    WHEN (extras = 'null')  OR (extras = 'Null') THEN NULL
    ELSE extras
  END AS extras,
  order_time::DATE AS order_date,
  order_time::TIME AS order_time
FROM 
  customer_orders
```

### Result

| order_id | customer_id | pizza_id | exclusions | extras | order_date | order_time |
| -------- | ----------- | -------- | ---------- | ------ | ---------- | ---------- |
| 1        | 101         | 1        |            |        | 2020-01-01 | 18:05:02   |
| 2        | 101         | 1        |            |        | 2020-01-01 | 19:00:52   |
| 3        | 102         | 1        |            |        | 2020-01-02 | 23:51:23   |
| 3        | 102         | 2        |            |        | 2020-01-02 | 23:51:23   |
| 4        | 103         | 1        | 4          |        | 2020-01-04 | 13:23:46   |
| 4        | 103         | 1        | 4          |        | 2020-01-04 | 13:23:46   |
| 4        | 103         | 2        | 4          |        | 2020-01-04 | 13:23:46   |
| 5        | 104         | 1        |            | 1      | 2020-01-08 | 21:00:29   |
| 6        | 101         | 2        |            |        | 2020-01-08 | 21:03:13   |
| 7        | 105         | 2        |            | 1      | 2020-01-08 | 21:20:29   |
| 8        | 102         | 1        |            |        | 2020-01-09 | 23:54:33   |
| 9        | 103         | 1        | 4          | 1, 5   | 2020-01-10 | 11:22:59   |
| 10       | 104         | 1        |            |        | 2020-01-11 | 18:34:49   |
| 10       | 104         | 1        | 2, 6       | 1, 4   | 2020-01-11 | 18:34:49   |


<br>
<br>

## **🍕 pizza_recipes**

### Issues Identified

- All the toppings id is been stored in a single row as string

#### Before cleaning:

| pizza_id | toppings                |
| -------- | ----------------------- |
| 1        | 1, 2, 3, 4, 5, 6, 8, 10 |
| 2        | 4, 6, 7, 9, 11, 12      | 


### Code
```sql
DROP TABLE IF EXISTS clean_pizza_recipes;

CREATE TABLE clean_pizza_recipes AS
SELECT pizza_id,
unnest(string_to_array(toppings,', '))::INT AS toppings 
FROM pizza_recipes;
```

### Result

| pizza_id | toppings |
| -------- | -------- |
| 1        | 1        |
| 1        | 2        |
| 1        | 3        |
| 1        | 4        |
| 1        | 5        |
| 1        | 6        |
| 1        | 8        |
| 1        | 10       |
| 2        | 4        |
| 2        | 6        |
| 2        | 7        |
| 2        | 9        |
| 2        | 11       |
| 2        | 12       |


<br>
<br>
