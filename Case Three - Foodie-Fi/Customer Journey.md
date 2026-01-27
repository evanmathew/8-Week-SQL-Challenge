# 🥑 Case Study 3-A – Foodie-Fi - Customer Journey (Solution)

### 1. Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!

<br>
For this Scenerio, I would be taking following random customer_id's from the subscriptions table to view their onboarding journey. Checking the following customer_id's : 1,21,73,87,99,193,290,400
<br>

```sql
SELECT 
  sub.customer_id AS "Customer ID",
  plan.plan_name AS "Plan Name",
  TO_CHAR(sub.start_date,'DD Month YYYY') AS "Start Date of the Plan"
FROM 
  subscriptions AS sub 
JOIN 
  plans AS plan
ON 
  sub.plan_id = plan.plan_id
WHERE 
  sub.customer_id IN (1,21,73,87,99,193,290,400)
GROUP BY 
  sub.customer_id, plan.plan_name, sub.start_date
ORDER BY 
  sub.customer_id, sub.start_date
```

#### Output:
| Customer ID | Plan Name     | Start Date of the Plan |
| ----------- | ------------- | ---------------------- |
| 1           | trial         | 01 August    2020      |
| 1           | basic monthly | 08 August    2020      |
| 21          | trial         | 04 February  2020      |
| 21          | basic monthly | 11 February  2020      |
| 21          | pro monthly   | 03 June      2020      |
| 21          | churn         | 27 September 2020      |
| 73          | trial         | 24 March     2020      |
| 73          | basic monthly | 31 March     2020      |
| 73          | pro monthly   | 13 May       2020      |
| 73          | pro annual    | 13 October   2020      |
| 87          | trial         | 08 August    2020      |
| 87          | pro monthly   | 15 August    2020      |
| 87          | pro annual    | 15 September 2020      |
| 99          | trial         | 05 December  2020      |
| 99          | churn         | 12 December  2020      |
| 193         | trial         | 19 May       2020      |
| 193         | basic monthly | 26 May       2020      |
| 193         | pro monthly   | 21 September 2020      |
| 193         | pro annual    | 21 October   2020      |
| 290         | trial         | 10 January   2020      |
| 290         | basic monthly | 17 January   2020      |
| 400         | trial         | 27 April     2020      |
| 400         | basic monthly | 04 May       2020      |

<br>

#### 🧑‍🍳 Customer Onboarding Journeys

- **Customer 1**
  - Started with a trial and quickly upgraded to the basic monthly plan, remaining active.

- **Customer 21**
  Moved from trial → basic monthly → pro monthly, then churned after several months.

- **Customer 73**
  - Progressed steadily from trial → basic monthly → pro monthly → pro annual, showing strong long-term commitment.

- **Customer 87**
  - Upgraded rapidly from trial to pro monthly, then converted to pro annual within one month.

- **Customer 99**
  - Signed up for a trial and churned shortly after, without converting to a paid plan.

- **Customer 193**
  - Transitioned from trial → basic monthly → pro monthly → pro annual, indicating increasing engagement over time.

- **Customer 290**
  - Converted from trial to basic monthly and remained on that plan.

- **Customer 400**
  - Upgraded from trial to basic monthly with no further plan changes recorded.

