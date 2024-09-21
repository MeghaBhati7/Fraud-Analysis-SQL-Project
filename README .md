# Fraud Detection Analysis SQL Project

## Project Overview

**Project Title**: Fraud Detection Analysis  

This project is designed to demonstrate SQL skills and techniques typically used by data analysts to explore and analyze data. The project involves setting up a database.


## Project Structure

### 1. Create Schema 

- **Database Creation**: The project starts by creating a schema named `bank`.
- **Table Creation**: A table named `transactions` is created to store the  data. The table structure includes columns for step, type, amount, nameOrig, oldbalanceOrg, newbalanceOrig, nameDest, oldbalanceDest, newbalanceDest, isFraud, isFlaggedFraud.

```sql
Use bank

CREATE DATABASE bank;

CREATE TABLE transactions
(
step INT,
type VARCHAR(20),
amount DECIMAL(15,2),
nameOrig VARCHAR(20),
oldbalanceOrg DECIMAL(15,2),
newbalanceOrig DECIMAL(15,2),
 nameDest VARCHAR(20),
oldbalanceDest DECIMAL(15,2),
 newbalanceDest DECIMAL(15,2),
 isFraud TINYINT,
 isFlaggedFraud TINYINT
 );

```

### 2. Database Import

 ```sql
LOAD DATA INFILE
"D:/MYSQL/Bank data set/PS_20174392719_1491204439457_log.csv" 
 INTO TABLE transactions FIELDS TERMINATED BY ','
 ENCLOSED BY '"'
 LINES TERMINATED BY '\n' IGNORE 1 ROWS;
```

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. ** : Detecting Recursive Fraudulent Transactions
Question : Use a recursive CTE to identify potential money laundering chains where money is transferred from one account to another across multiple steps, with all transactions flagged as fraudulent.

Solution:
This query uses a recursive CTE to track the flow of money through multiple accounts over successive steps. The recursive part of the CTE allows us to follow the chain of transactions and identify patterns that could indicate money laundering activities. It filters out chains where all transactions are marked as fraudulent.**
```sql
WITH RECURSIVE fraud_chain AS (
    SELECT 
        nameOrig AS initial_account, 
        nameDest AS next_account, 
        step, 
        amount
    FROM 
        transactions
    WHERE 
        isFraud = 1 AND type = 'TRANSFER'
    
    UNION ALL
    
    SELECT 
        fc.initial_account, 
        t.nameDest, 
        t.step, 
        t.amount
    FROM 
        fraud_chain fc
    JOIN 
        transactions t 
    ON 
        fc.next_account = t.nameOrig AND fc.step < t.step
    WHERE 
        t.isFraud = 1 AND t.type = 'TRANSFER'
)
SELECT * FROM fraud_chain;
```

2. **Analyzing Fraudulent Activity over Time
Question:
Use a CTE to calculate the rolling sum of fraudulent transactions for each account over the last 5 steps.

Solution:
This query uses a CTE to calculate the cumulative sum of fraudulent transactions for each account over the last five steps. It helps in understanding the temporal distribution of fraudulent activities, which is crucial for identifying patterns over time.**

```sql
WITH rolling_fraud AS (
    SELECT 
        nameOrig, 
        step, 
        SUM(isFraud) OVER (PARTITION BY nameOrig ORDER BY step ROWS BETWEEN 4 PRECEDING AND CURRENT ROW) AS fraud_rolling_sum
    FROM 
        transactions
)
SELECT 
    nameOrig, 
    step, 
    fraud_rolling_sum
FROM 
    rolling_fraud
WHERE 
    fraud_rolling_sum > 0;
```

3. **Complex Fraud Detection Using Multiple CTEs
Question:
Use multiple CTEs to identify accounts with suspicious activity, including large transfers, consecutive transactions without balance change, and flagged transactions.

Solution:
This query combines multiple suspicious criteria using multiple CTEs. It identifies accounts involved in large transfers, followed by no balance changes, and also where at least one transaction was flagged. The result is a list of highly suspicious accounts for further investigation.**

```sql
WITH large_transfers AS (
    SELECT 
        nameOrig, 
        step, 
        amount
    FROM 
        transactions
    WHERE 
        type = 'TRANSFER' AND amount > 500000
), 

no_balance_change AS (
    SELECT 
        nameOrig, 
        step, 
        oldbalanceOrg, 
        newbalanceOrig
    FROM 
        transactions
    WHERE 
        oldbalanceOrg = newbalanceOrig
),

flagged_transactions AS (
    SELECT 
        nameOrig, 
        step, 
        isFlaggedFraud
    FROM 
        transactions
    WHERE 
        isFlaggedFraud = 1
)

SELECT 
    lt.nameOrig
FROM 
    large_transfers lt
JOIN 
    no_balance_change nbc ON lt.nameOrig = nbc.nameOrig AND lt.step = nbc.step
JOIN 
    flagged_transactions ft ON lt.nameOrig = ft.nameOrig AND lt.step = ft.step;
```

4. **Write me a query that checks if the computed new_updated_Balance is the same as the actual newbalanceDest in the table. If they are equal, it returns those rows.**
   
```sql
WITH cte AS (
SELECT 
        amount,
        nameOrig,
        oldbalanceDest,
        newbalanceDest,
        (amount + oldbalanceDest) AS new_updated_Balance 
FROM 
 transactions
)
SELECT  * 
FROM 
 cte 
WHERE 
    new_updated_Balance = newbalanceDest;
```

5. **Detect Transactions with Zero Balance Before or After
Question: Find transactions where the destination account had a zero balance before or after the transaction.
SQL Prompt: Write a query to list transactions where oldbalanceDest or newbalanceDest is zero.**
```sql
SELECT 
    nameOrig, 
    nameDest, 
    oldbalanceDest, 
    newbalanceDest, 
    amount
FROM 
    transactions
WHERE 
    oldbalanceDest = 0 OR newbalanceDest = 0;
```







