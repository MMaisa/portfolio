-- Data reference
https://www.kaggle.com/datasets/gauravtopre/bank-customer-churn-dataset/data
  
-- Creating the database
sqlite3 maisa_pf.db
SQLite version 3.37.0 2021-12-09 01:34:53
Enter ".help" for usage hints.
  
-- Deleting table if it exists
DROP TABLE IF EXISTS bank_churn;

-- Creating a table for the data
CREATE TABLE bank_churn (
    customer_id INTEGER PRIMARY KEY,
    credit_score INTEGER,
    country TEXT,
    gender TEXT,
    age INTEGER,
    tenure INTEGER,
    balance REAL,
    products_number INTEGER,
    credit_card INTEGER,
    active_member INTEGER,
    estimated_salary REAL,
    churn INTEGER
);

-- Importing data, had some issues with importing so I skipped the headers. 
.mode csv
.headers on
.import --skip 1 '/Users/maisamaki/Documents/churn_prediction_bank.csv' bank_churn

-- Checking that data was imported correctly
SELECT * FROM bank_churn LIMIT 6;

-- Checking if there were NULL values (non found)
SELECT COUNT(*) FROM bank_churn WHERE customer_id IS NULL;
SELECT COUNT(*) FROM bank_churn WHERE credit_score IS NULL;
SELECT COUNT(*) FROM bank_churn WHERE country IS NULL;
SELECT COUNT(*) FROM bank_churn WHERE gender IS NULL;
SELECT COUNT(*) FROM bank_churn WHERE age IS NULL;
SELECT COUNT(*) FROM bank_churn WHERE tenure IS NULL;
SELECT COUNT(*) FROM bank_churn WHERE balance IS NULL;
SELECT COUNT(*) FROM bank_churn WHERE products_number IS NULL;
SELECT COUNT(*) FROM bank_churn WHERE credit_card IS NULL;
SELECT COUNT(*) FROM bank_churn WHERE active_member IS NULL;
SELECT COUNT(*) FROM bank_churn WHERE estimated_salary IS NULL;
SELECT COUNT(*) FROM bank_churn WHERE churn IS NULL;

-- Calculing some customer statistics to get the generalidea of the data 
SELECT
    AVG(age) AS avg_age,
    AVG(balance) AS avg_balance,
    AVG(credit_score) AS avg_credit_score,
    AVG(estimated_salary) AS avg_salary
FROM bank_churn;

-- Counting churn rate
SELECT 
    (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bank_churn)) AS churn_rate 
FROM bank_churn 
WHERE churn = 1;

-- Churn rate by gender
SELECT gender, 
       (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bank_churn)) AS churn_rate 
FROM bank_churn 
WHERE churn = 1 
GROUP BY gender;

-- Churn rate by age groups
SELECT 
    CASE
        WHEN age < 25 THEN 'Under 25'
        WHEN age BETWEEN 25 AND 40 THEN '25-40'
        WHEN age BETWEEN 41 AND 55 THEN '41-55'
        WHEN age BETWEEN 56 AND 70 THEN '56-70'
        ELSE '70+'
    END AS age_group,
    COUNT(*) AS customer_count,
    (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bank_churn)) AS churn_rate 
FROM bank_churn 
WHERE churn = 1
GROUP BY age_group
ORDER BY 
    CASE 
        WHEN age_group = 'Under 25' THEN 1
        WHEN age_group = '25-40' THEN 2
        WHEN age_group = '41-55' THEN 3
        WHEN age_group = '56-70' THEN 4
        ELSE 5
    END;

-- Churn rate by credit score
SELECT 
    CASE
        WHEN credit_score < 500 THEN 'Low: <500'
        WHEN credit_score BETWEEN 500 AND 750 THEN 'Medium: 500-750'
        ELSE 'High'
    END AS credit_score_range,
    COUNT(*) AS customer_count,
    (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM bank_churn)) AS churn_rate 
FROM bank_churn 
WHERE churn = 1
GROUP BY credit_score_range
ORDER BY
    CASE 
        WHEN credit_score_range = 'Low: <500' THEN 1
        WHEN credit_score_range = 'Medium: 500-750' THEN 2 
        ELSE 3
    END;

-- Churn rate by country

SELECT country, 
       COUNT(*) AS total_customers, 
       SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) AS churned_customers, 
       (SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS churn_rate  
FROM bank_churn 
GROUP BY country;

-- Churn rate by amount of products
SELECT products_number, 
       COUNT(*) AS total_customers, 
       SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) AS churned_customers, 
       (SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS churn_rate  
FROM bank_churn 
GROUP BY products_number;

-- Churn rate by active membership
SELECT active_member, 
       COUNT(*) AS total_customers, 
       SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) AS churned_customers, 
       (SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS churn_rate  
FROM bank_churn 
GROUP BY active_member;

-- Churn rate by salary range
SELECT 
    CASE 
        WHEN estimated_salary < 50000 THEN 'Low Salary: <50K'
        WHEN estimated_salary BETWEEN 50000 AND 100000 THEN 'Mid Salary: 50K-100K'
        ELSE 'High Salary: 100K+'
    END AS salary_group, 
    COUNT(*) AS total_customers, 
    SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) AS churned_customers, 
    (SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS churn_rate  
FROM bank_churn 
GROUP BY salary_group
ORDER BY 
    CASE 
        WHEN salary_group = 'Low Salary: <50K' THEN 1
        WHEN salary_group = 'Mid Salary: 50K-100K' THEN 2
        ELSE 3
    END;


-- Churn rate by both active membership and number of products
SELECT active_member, products_number, 
       COUNT(*) AS total_customers, 
       SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) AS churned_customers,
       (SUM(CASE WHEN churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS churn_rate
FROM bank_churn
GROUP BY active_member, products_number
ORDER BY churn_rate DESC;


-- Exporting the data
.mode csv
.headers on
.output bank_churn.csv
SELECT * FROM bank_churn;
.output stdout
