# 🥑 Case Study 3-B – Foodie-Fi - Data Analysis Questions (Solution)

### 1. How many customers has Foodie-Fi ever had?

```sql
SELECT 
  COUNT(DISTINCT customer_id) AS "Total Number of Customers"
FROM 
  subscriptions
```

### Output:
| Total Number of Customers |
| ------------------------- |
| 1000                      |

<br>

### 2.  What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value

```sql
SELECT 
  TO_CHAR(start_date, 'MM') AS "Month Number",
  COUNT(*) AS "Trial Plan Distribution"
FROM 
  subscriptions
WHERE 
  plan_id = 0
GROUP BY 
  "Month Number"
ORDER BY 
  "Month Number"
```

### Output:
| Month Number | Trial Plan Distribution |
| ------------ | ----------------------- |
| 01           | 88                      |
| 02           | 68                      |
| 03           | 94                      |
| 04           | 81                      |
| 05           | 88                      |
| 06           | 79                      |
| 07           | 89                      |
| 08           | 88                      |
| 09           | 87                      |
| 10           | 79                      |
| 11           | 75                      |
| 12           | 84                      |


<br>

### 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_namez

```sql
SELECT 
  plan.plan_name AS "Plan Name",
  COUNT(*) AS "Plan Count"
FROM  
  subscriptions AS sub
JOIN 
  plans AS plan
ON
  plan.plan_id = sub.plan_id
WHERE 
  TO_CHAR(sub.start_date,'YYYY')::NUMERIC > 2020
GROUP BY 
  sub.plan_id, plan.plan_name
ORDER BY 
  sub.plan_id
```

### Output:
| Plan Name     | Plan Count |
| ------------- | ---------- |
| basic monthly | 8          |
| pro monthly   | 60         |
| pro annual    | 63         |
| churn         | 71         |


<br>

### 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place? 