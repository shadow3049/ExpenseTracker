DROP TABLE IF EXISTS categories, accounts, transactions;

CREATE TABLE categories (
    category_id INT AUTO_INCREMENT,
    category_name VARCHAR(30),
    PRIMARY KEY (category_id)
);

CREATE TABLE accounts (
    account_id INT AUTO_INCREMENT,
    acc_name VARCHAR(30),
    mode VARCHAR(10),
    balance DECIMAL(10, 2) DEFAULT 0,
    CHECK (balance >= 0),
    PRIMARY KEY (account_id)
);

CREATE TABLE transactions (
    id INT AUTO_INCREMENT,
    tdate DATE,
    tdescription VARCHAR(50),
    category_id INT,
    amount DECIMAL(10,2),
    CHECK (amount >= 0),
    transaction_type VARCHAR(1),
    account_id INT,
    CONSTRAINT FK_trans_categ 
    FOREIGN KEY (category_id) 
    REFERENCES categories(category_id),
    CONSTRAINT FK_trans_acc
    FOREIGN KEY (account_id) 
    REFERENCES accounts(account_id) 
    ON DELETE CASCADE,
    PRIMARY KEY (id)
);


DROP TRIGGER IF EXISTS date_of_transaction; 
DROP TRIGGER IF EXISTS category_of_transaction;
DROP TRIGGER IF EXISTS change_balance; 
DROP TRIGGER IF EXISTS no_neg_balance;
DROP TRIGGER IF EXISTS restore_balance;
DROP TRIGGER IF EXISTS delete_category;

DELIMITER $$

CREATE TRIGGER date_of_transaction 
BEFORE INSERT ON transactions 
FOR EACH ROW 
BEGIN 
    IF NEW.tdate IS NULL THEN 
        SET NEW.tdate := CURDATE(); 
    END IF; 
END $$ 

DELIMITER $$

CREATE TRIGGER category_of_transaction 
BEFORE INSERT ON transactions 
FOR EACH ROW 
BEGIN 
    IF (NEW.category_id IS NULL) OR (NEW.category_id = 1) THEN 
        SET NEW.category_id := 18; 
    ELSEIF NEW.transaction_type = 'D' 
        SET NEW.category_id := 1; 
    END IF; 
END $$

DELIMITER $$

CREATE TRIGGER change_balance 
AFTER INSERT ON transactions 
FOR EACH ROW 
BEGIN 
    IF NEW.transaction_type = 'D' THEN 
        UPDATE accounts 
        SET accounts.balance := (balance - NEW.amount) 
        WHERE accounts.account_id = NEW.account_id; 
    ELSEIF NEW.transaction_type = 'C' THEN 
        UPDATE accounts 
        SET balance := (balance + NEW.amount) 
        WHERE accounts.account_id = NEW.account_id; 
    ELSE 
        SIGNAL SQLSTATE '50000' 
        SET MESSAGE_TEXT = 'Incorrect Type of Transaction'; 
    END IF; 
END $$

DELIMITER $$

CREATE TRIGGER no_neg_balance 
BEFORE INSERT ON transactions 
FOR EACH ROW 
BEGIN 
    IF (NEW.amount > (SELECT balance
                     FROM accounts
                     WHERE accounts.account_id = NEW.account_id))
                     AND NEW.transaction_type = 'D' 
        THEN SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Not enough balance';
    END IF;
END $$

DELIMITER $$

CREATE TRIGGER restore_balance 
AFTER DELETE ON transactions 
FOR EACH ROW 
BEGIN 
    IF OLD.transaction_type = 'D' THEN 
        UPDATE accounts 
        SET balance := balance + OLD.amount 
        WHERE accounts.account_id = OLD.account_id;
    ELSEIF OLD.transaction_type = 'C' THEN
        UPDATE accounts 
        SET balance := balance - OLD.amount 
        WHERE accounts.account_id = OLD.account_id;
    END IF;
END $$

DELIMITER $$

-- Didn't use ON DELETE CASCADE because it won't activate
-- `restore_balance` on child rows that were deleted.  
CREATE TRIGGER delete_category 
AFTER DELETE ON categories 
FOR EACH ROW 
BEGIN 
    DELETE 
    FROM transactions 
    WHERE transactions.category_id = OLD.category_id;
END $$

DELIMITER ;

INSERT INTO categories 
    (category_name)
VALUES 
    ('Income'),
    ('Rent'),
    ('Transportation'),
    ('Groceries'),
    ('Home and Utilities'),
    ('Insurance'),
    ('Bills and EMIs'),
    ('Education'),
    ('Personal Care'),
    ('Medical Expenses'),
    ('Gifts'),
    ('Subscriptions'),
    ('Shopping and Entertainment'),
    ('Food and Dining'),
    ('Travel'),
    ('Memberships'),
    ('Self Transfer'),
    ('Other');

INSERT INTO accounts
    (acc_name, mode)
VALUES 
    ('Cash', 'cash'),
    ('Credit Card', 'card'),
    ('Savings Account', 'bank');
