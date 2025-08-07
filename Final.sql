CREATE DATABASE final_project;
CREATE DATABASE customers_transactions; 
Update customers set Gender = null where Gender ='';
Update customers set Age = null where Age ='';
Alter table Customers modify age int null;

Select * from customers;

create table transactions
(date_new date,
Id_check int,
ID_client int,
Count_products decimal(10,3),
Sum_payment decimal(10,2));

load data infile "\Users\armanbaigutdinov\Desktop\transactions_final.csv"
INTO table transactions 
fields terminated by ','
lines  terminated by '\n'
ignore 1 rows;

show variables like "secure_file_priv";

LOAD DATA LOCAL INFILE '/Users/armanbaigutdinov/Desktop/transactions_final.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

Select * from transactions_final;

SELECT * FROM customers LIMIT 5;
SELECT * FROM transactions_final LIMIT 5;

#1 задание

SELECT * FROM transactions_final
WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01';

SELECT 
  ID_client,
  COUNT(DISTINCT DATE_FORMAT(date_new, '%Y-%m')) AS months_active
FROM transactions_final
WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY ID_client
HAVING months_active = 12;

CREATE TEMPORARY TABLE active_clients AS
SELECT 
  ID_client
FROM transactions_final
WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY ID_client
HAVING COUNT(DISTINCT DATE_FORMAT(date_new, '%Y-%m')) = 12;

SELECT 
  t.ID_client,
  ROUND(AVG(t.Sum_payment), 2) AS avg_check,
  ROUND(SUM(t.Sum_payment)/12, 2) AS avg_monthly_sum,
  COUNT(*) AS total_operations
FROM transactions_final t
JOIN active_clients ac ON t.ID_client = ac.ID_client
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY t.ID_client
ORDER BY t.ID_client;

#2 Задание 
	#a
SELECT 
  DATE_FORMAT(date_new, '%Y-%m') AS month,
  ROUND(AVG(Sum_payment), 2) AS avg_check
FROM transactions_final
WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY month
ORDER BY month;

	#b
SELECT 
  DATE_FORMAT(date_new, '%Y-%m') AS month,
  COUNT(*) AS operations_count
FROM transactions_final
WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY month
ORDER BY month;

	#c
SELECT 
  DATE_FORMAT(date_new, '%Y-%m') AS month,
  COUNT(DISTINCT ID_client) AS unique_clients
FROM transactions_final
WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY month
ORDER BY month;

	#d
SELECT 
  DATE_FORMAT(t.date_new, '%Y-%m') AS month,
  c.Gender,
  COUNT(*) AS ops_count,
  ROUND(COUNT(*) * 100.0 / total_ops.ops_month, 2) AS ops_pct,
  ROUND(SUM(t.Sum_payment), 2) AS sum_total,
  ROUND(SUM(t.Sum_payment) * 100.0 / total_ops.sum_month, 2) AS sum_pct
FROM customers_transactions.transactions_final t
JOIN customers_transactions.customers c 
  ON t.ID_client = c.Id_client
JOIN (
    SELECT 
      DATE_FORMAT(date_new, '%Y-%m') AS month,
      COUNT(*) AS ops_month,
      SUM(Sum_payment) AS sum_month
    FROM customers_transactions.transactions_final
    WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
    GROUP BY DATE_FORMAT(date_new, '%Y-%m')
) total_ops 
  ON DATE_FORMAT(t.date_new, '%Y-%m') = total_ops.month
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY 
  DATE_FORMAT(t.date_new, '%Y-%m'), 
  c.Gender, 
  total_ops.ops_month, 
  total_ops.sum_month
ORDER BY 
  DATE_FORMAT(t.date_new, '%Y-%m'), 
  c.Gender;
  
  
	#e
SELECT
  DATE_FORMAT(t.date_new, '%Y-%m') AS month,
  c.Gender,
  COUNT(DISTINCT t.ID_client) AS clients_count,
  ROUND(COUNT(DISTINCT t.ID_client) * 100.0 / clients_month.total_clients, 2) AS client_pct,
  COUNT(*) AS ops_count,
  ROUND(COUNT(*) * 100.0 / total_ops.ops_month, 2) AS ops_pct,
  ROUND(SUM(t.Sum_payment), 2) AS sum_total,
  ROUND(SUM(t.Sum_payment) * 100.0 / total_ops.sum_month, 2) AS sum_pct
FROM customers_transactions.transactions_final t
JOIN customers_transactions.customers c
  ON t.ID_client = c.Id_client
JOIN (
    SELECT
      DATE_FORMAT(date_new, '%Y-%m') AS month,
      COUNT(*) AS ops_month,
      SUM(Sum_payment) AS sum_month
    FROM customers_transactions.transactions_final
    WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
    GROUP BY month
) total_ops
  ON DATE_FORMAT(t.date_new, '%Y-%m') = total_ops.month
JOIN (
    SELECT
      DATE_FORMAT(date_new, '%Y-%m') AS month,
      COUNT(DISTINCT ID_client) AS total_clients
    FROM customers_transactions.transactions_final
    WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
    GROUP BY month
) clients_month
  ON DATE_FORMAT(t.date_new, '%Y-%m') = clients_month.month
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY
  month,
  c.Gender,
  total_ops.ops_month,
  total_ops.sum_month,
  clients_month.total_clients
ORDER BY
  month,
  c.Gender;
  
  
#3 задание 
SELECT
  CONCAT(YEAR(t.date_new), '-Q', QUARTER(t.date_new)) AS quarter,
  CASE
    WHEN c.Age IS NULL THEN 'Unknown'
    WHEN c.Age BETWEEN 0 AND 9 THEN '00-09'
    WHEN c.Age BETWEEN 10 AND 19 THEN '10-19'
    WHEN c.Age BETWEEN 20 AND 29 THEN '20-29'
    WHEN c.Age BETWEEN 30 AND 39 THEN '30-39'
    WHEN c.Age BETWEEN 40 AND 49 THEN '40-49'
    WHEN c.Age BETWEEN 50 AND 59 THEN '50-59'
    ELSE '60+'
  END AS age_group,
COUNT(*) AS ops_count,
ROUND(SUM(t.Sum_payment), 2) AS total_sum,
ROUND(AVG(t.Sum_payment), 2) AS avg_payment,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY CONCAT(YEAR(t.date_new), '-Q', QUARTER(t.date_new))), 2) AS ops_pct,
ROUND(SUM(t.Sum_payment) * 100.0 / SUM(SUM(t.Sum_payment)) OVER (PARTITION BY CONCAT(YEAR(t.date_new), '-Q', QUARTER(t.date_new))), 2) AS sum_pct

FROM customers_transactions.transactions_final t

JOIN customers_transactions.customers c
  ON t.ID_client = c.Id_client

WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'

GROUP BY
  quarter,
  age_group

ORDER BY
  quarter,
  age_group;