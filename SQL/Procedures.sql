DROP PROCEDURE IF EXISTS delete_by_id;
DROP PROCEDURE IF EXISTS insert_transaction;
DROP PROCEDURE IF EXISTS custom_category;

DELIMITER $$
 
CREATE PROCEDURE delete_by_id(in input_id INT)
BEGIN 
    DELETE 
    FROM transactions
    WHERE transactions.id = input_id;
END; $$ 

DELIMITER $$

CREATE PROCEDURE insert_transaction(
    IN input_date DATE,
    IN input_desc VARCHAR(50),
    IN input_categ VARCHAR(30),
    IN input_amt DECIMAL(10, 2),
    IN input_type VARCHAR(1),
    IN input_account VARCHAR(30)
) BEGIN 
    DECLARE acc_id, cat_id INT;
    
    SET acc_id := (
        SELECT account_id FROM accounts
        WHERE acc_name = input_account
    ); 
    
    IF input_categ IS NOT NULL THEN 
        SET cat_id := (
            SELECT category_id 
            FROM categories 
            WHERE category_name = input_categ
        );
    ELSE 
        SET cat_id := NULL;
    END IF;

    INSERT INTO transactions (
        tdate,
        tdescription,
        category_id,
        amount,
        transaction_type,
        account_id 
    ) VALUES (
        input_date,
        input_desc,
        cat_id,
        input_amt,
        input_type,
        acc_id
    );
END $$ 

DELIMITER $$

CREATE PROCEDURE add_account(
    IN input_acc_name, 
    input_acc_mode 
) BEGIN 
    INSERT INTO accounts 
        (acc_name, mode) 
    VALUES 
        (input_acc_name, input_acc_mode);
END $$

DELIMITER $$

CREATE PROCEDURE custom_category(
    IN input_category
) BEGIN 
    INSERT INTO categories 
        (category_name) 
    VALUES
        (input_category);
END $$

DELIMITER $$

CREATE PROCEDURE delete_account(
    IN input_acc_name
) BEGIN 
    DELETE 
    FROM accounts 
    WHERE accounts.acc_name = input_acc_name;
END $$

DELIMITER ;