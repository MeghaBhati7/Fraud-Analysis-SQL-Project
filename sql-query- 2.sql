use bank;
 
SELECT * FROM TRANSACTIONS;


 WITH RECURSIVE fraud_chain as (
 SELECT nameOrig as initial_account,
 nameDest as next_account,
 step, amount, newbalanceOrig
 from transactions
 WHERE isFraud='1' and type = 'TRANSFER'
 
 UNION ALL
 
 SELECT fc.initial_account,
 t.nameDest, t.step, t.amount, t.newbalanceOrig
 FROM fraud_chain fc
 JOIN transactions t
 ON fc.next_account= t.nameOrig
 and fc.step < t.step
 WHERE t.isFraud = 1 and t.type = 'TRANSFER')
 SELECT * FROM fraud_chain;
 
 WITH large_transfers AS (
SELECT nameOrig, step, amount
FROM transactions
WHERE type = 'TRANSFER' AND amount > 500000), 

no_balance_change AS (
SELECT nameOrig, step, oldbalanceOrg, newbalanceOrig
FROM transactions
WHERE oldbalanceOrg = newbalanceOrig),

flagged_transactions AS (
SELECT nameOrig, step, isFlaggedFraud
FROM transactions
WHERE isFlaggedFraud = 1)

SELECT lt.nameOrig
FROM large_transfers lt
JOIN no_balance_change nbc ON lt.nameOrig = nbc.nameOrig AND lt.step = nbc.step
JOIN flagged_transactions ft ON lt.nameOrig = ft.nameOrig AND lt.step = ft.step;


WITH CTE AS (
SELECT amount,nameOrig,oldbalanceDest,newbalanceDest,(amount+ oldbalanceDest) as new_updatedbalance
FROM transactions)

SELECT * FROM CTE 
WHERE newbalanceDest = new_updatedbalance ;
    
    -- 5. Detect Transactions with Zero Balance Before or After
-- Question: Find transactions where the destination account had a zero balance before or after the transaction.
-- SQL Prompt: Write a query to list transactions where oldbalanceDest or newbalanceDest is zero.

SELECT nameOrig,newbalanceDest,oldbalanceDest,nameDest FROM transactions
WHERE  newbalanceDest = '0'  or oldbalanceDest = '0';
 