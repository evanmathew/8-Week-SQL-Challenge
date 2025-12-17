# 🍜 Case Study #1: Danny's Diner (Solution)

### 1. What is the total amount each customer spent at the restaurant?

```sql
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
```

#### Result Set:
| customer_id | total_sales |
| ----------- | ----------- |
| A           | $76         |
| B           | $74         |
| C           | $36         |

<br>

###  2. How many days has each customer visited the restaurant?

```sql
SELECT 
  customer_id, 
  COUNT(DISTINCT (order_date))
FROM 
  sales
GROUP BY 
  customer_id
ORDER BY 
  customer_id ASC
```

#### Result Set:
| customer_id | visit_count |
| ----------- | ----------- |
| A           | 4           |
| B           | 6           |
| C           | 2           |


***