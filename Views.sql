CREATE OR REPLACE VIEW `Account Balance` AS
SELECT 
    acc_name AS `Account Name`, 
    accounts.balance AS Balance
FROM accounts;


CREATE OR REPLACE VIEW `Passbook` AS 
SELECT 
    id AS `Transaction ID`,  
    tdate AS `Date of Transaction`, 
    category_name AS `Category`, 
    amount AS `Amount`, 
    transaction_type AS `Credit/Debit`, 
    acc_name AS `Account Name` 
FROM transactions JOIN accounts USING (account_id) 
JOIN categories USING (category_id);
   

CREATE OR REPLACE VIEW `Monthly Expenditure Category Wise` AS
SELECT 
    YEAR(tdate) AS `Year`,
    MONTHNAME(tdate) AS `Month`, 
    category_name AS `Category`, 
    IFNULL(sum(amount), 0) AS `Spent` 
FROM transactions JOIN categories 
USING(category_id) 
WHERE transaction_type = 'D' 
GROUP BY YEAR(tdate), MONTHNAME(tdate), category_name
ORDER BY YEAR(tdate), MONTHNAME(tdate), sum(amount);


CREATE OR REPLACE VIEW `Month wise expenditure` AS
SELECT 
    YEAR(tdate) AS `Year`,
    MONTHNAME(tdate) AS `Month`, 
    IFNULL(sum(amount), 0) AS `Spent` 
FROM transactions 
WHERE transaction_type = 'D' 
GROUP BY YEAR(tdate), MONTHNAME(tdate) 
ORDER BY YEAR(tdate), MONTHNAME(tdate);

CREATE OR REPLACE VIEW `Month wise income` AS
SELECT 
    YEAR(tdate) AS `Year`,
    MONTHNAME(tdate) AS `Month`, 
    IFNULL(sum(amount), 0) AS `Income` 
FROM transactions 
WHERE transaction_type = 'C' 
GROUP BY YEAR(tdate), MONTHNAME(tdate) 
ORDER BY YEAR(tdate), MONTHNAME(tdate);

CREATE OR REPLACE VIEW `Category wise expenditure` AS
SELECT 
    category_id AS `Category ID`,
    category_name AS `Category`, 
    IFNULL(sum(amount), 0) AS `Spent`
FROM transactions JOIN categories 
USING (category_id) 
WHERE transaction_type = 'D' 
GROUP BY category_name, category_id
ORDER BY sum(amount), category_id;

CREATE OR REPLACE VIEW `Monthly Savings` AS 
SELECT DISTINCT
    YEAR(t1.tdate) as `Year`,
    MONTHNAME(t1.tdate) as `Month`, 
    (
        SELECT IFNULL(sum(t2.amount), 0) AS 'amt'
        FROM transactions t2 
        WHERE t2.transaction_type = 'C' 
        AND MONTHNAME(t2.tdate) = MONTHNAME(t1.tdate) 
        AND YEAR(t2.tdate) = YEAR(t1.tdate)
    ) - (
        SELECT IFNULL(sum(t3.amount), 0) as 'amt'
        FROM transactions t3 
        WHERE t3.transaction_type = 'D' 
        AND MONTHNAME(t3.tdate) = MONTHNAME(t1.tdate) 
        AND YEAR(t3.tdate) = YEAR(t1.tdate)
    ) AS `Savings` 
FROM transactions t1;