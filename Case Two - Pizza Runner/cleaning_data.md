# Data Cleaning 
<br>

## 📌 Overview


Before performing any analysis in the Pizza Runner case study, the raw data requires significant cleaning.


Several columns contain:

- Text values representing missing data ('null', 'NULL', empty strings)

- Mixed data types (numbers stored as text)

- Units embedded inside values (e.g. km, minutes)

- Incorrect or inconsistent timestamps

<br>
<br>


## 🗂️ Tables Cleaned:
<br>

### runner_orders


Issues Identified

- pickup_time contains 'null' and empty values

- distance includes units like km and invalid text

- duration includes text such as minutes

- Inconsistent casing (null, NULL, Null)
