# Nivell 1

## Creem la base de dades
CREATE DATABASE sprint4db;

## Creem l'estructura de les taules 

### Taula company
    CREATE TABLE sprint4db.companies (
        company_id VARCHAR(255) PRIMARY KEY,
        company_name VARCHAR(255),
        phone VARCHAR(255),
        email VARCHAR(255),
        country VARCHAR(255),
        website VARCHAR(255)
    );

### Taula credit_cards
CREATE TABLE sprint4db.credit_cards (
    id VARCHAR(255) PRIMARY KEY,
    user_id INT,
    iban VARCHAR(255),
    pan VARCHAR(255),
    pin VARCHAR(255),
    cvv VARCHAR(255),
    track1 VARCHAR(255),
    track2 VARCHAR(255),
    expiring_date varchar(255)
);

### Taula users
 CREATE TABLE sprint4db.users (
        id INT PRIMARY KEY,
        name VARCHAR(255),
        surname VARCHAR(255),
        phone VARCHAR(255),
        email VARCHAR(255),
        birth_date VARCHAR(255),
        country VARCHAR(255),
        city VARCHAR(255),
        postal_code VARCHAR(255),
        address VARCHAR(255)
    );

### Taula transactions
CREATE TABLE sprint4db.transactions (
  id VARCHAR(255) PRIMARY KEY,
  card_id VARCHAR(255),
  business_id VARCHAR(255),
  timestamp TIMESTAMP,
  amount DECIMAL(10, 2),
  declined BOOLEAN,
  product_ids VARCHAR(255),
  user_id INT,
  lat FLOAT,
  longitude FLOAT,
  FOREIGN KEY (business_id) REFERENCES companies(company_id),
  FOREIGN KEY (card_id) REFERENCES credit_cards(id),
  FOREIGN KEY (user_id) REFERENCES users(id)
  );
    
## Importem les dades dels csvs

### Passos previs per identificar per que no podia accedir als csvs
#show global variables like 'local_infile';
#show variables like 'secure_file_priv';
#set global local_infile=true;

### companies
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/companies.csv' 
INTO TABLE companies 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

## credit_cards
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/credit_cards.csv' 
INTO TABLE credit_cards 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

### users
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_ca.csv' 
INTO TABLE users 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_uk.csv' 
INTO TABLE users 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users_usa.csv' 
INTO TABLE users 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;

### transactions
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/transactions.csv' 
INTO TABLE transactions 
FIELDS TERMINATED BY ';' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;
## Exercici 1

### Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant 
### almenys 2 taules.

# SELECT user_id, name, surname, numTransac
# FROM (SELECT user_id, count(id) as numTransac
#	  FROM transactions
#      WHERE declined = 0
#      GROUP BY user_id) as TransacPerUser
#JOIN users
#ON user_id = id
#WHERE numTransac > 30;

SELECT name, surname
FROM users
WHERE id IN (
    SELECT user_id 
    FROM transactions 
    WHERE declined = 0 
    GROUP BY user_id 
    HAVING COUNT(id) > 30
);

## Exercici 2
### Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, 
### utilitza almenys 2 taules.

SELECT iban, ROUND(AVG(amount),2) as meanAmount, company_name
	  FROM transactions
	  LEFT JOIN credit_cards
	  ON card_id = credit_cards.id
      LEFT JOIN companies
      ON company_id = business_id
      WHERE declined = 0 AND company_name = "Donec Ltd"
	  GROUP BY iban, company_name;

# Nivell 2
### Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si 
### les últimes tres transaccions van ser declinades i genera la següent consulta:
CREATE TABLE credit_cards_status (
    card_id VARCHAR(255) PRIMARY KEY,
    card_status VARCHAR(255) 
);

INSERT INTO credit_cards_status 
SELECT card_id,
       CASE 
           WHEN SUM(declined) = 3 THEN 'not active'
           ELSE 'active'
       END AS card_status
FROM (SELECT card_id, declined
	  FROM (SELECT card_id, declined, timestamp,
			ROW_NUMBER() OVER (PARTITION BY card_id ORDER BY timestamp DESC) AS rn
			FROM transactions) as orderedTransac
	  WHERE rn <= 3) as threeLastTransac
GROUP BY card_id;

# SELECT * FROM credit_cards_status;
### La podem connectar amb la resta de taules. 
ALTER TABLE credit_cards_status
ADD FOREIGN KEY (card_id)
REFERENCES credit_cards(id);

## Exercici 1
###Quantes targetes estan actives?
SELECT COUNT(*) as numberActiveCards
FROM credit_cards_status
WHERE card_status = 'active';

# Nivell 3
### Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv 
### amb la base de dades creada, tenint en compte que des de transaction tens product_ids. 

CREATE TABLE ProductsPerTransaction (
    transaction_id VARCHAR(255),
    product_id INT,
    PRIMARY KEY (transaction_id, product_id)
);

INSERT INTO ProductsPerTransaction 
 WITH RECURSIVE ProductsPerTransaction AS (
        SELECT
            id,
            TRIM(SUBSTRING_INDEX(product_ids, ',', 1)) AS split_value,
            IF(LOCATE(',', product_ids) > 0, TRIM(SUBSTRING(product_ids, LOCATE(',', product_ids) + 1)), NULL) AS remaining_values
        FROM
            transactions
        UNION ALL
        SELECT
            id,
            TRIM(SUBSTRING_INDEX(remaining_values, ',', 1)) AS split_value,
            IF(LOCATE(',', remaining_values) > 0, TRIM(SUBSTRING(remaining_values, LOCATE(',', remaining_values) + 1)), NULL)
        FROM
            ProductsPerTransaction
        WHERE
            remaining_values IS NOT NULL
    )
    SELECT
        id as transaction_id,
        split_value as product_id
    FROM
        ProductsPerTransaction;

### Creem la taula productes:
CREATE TABLE sprint4db.products (
  id INT PRIMARY KEY,
  product_name VARCHAR(255),
  price VARCHAR(255),
  colour VARCHAR(255),
  weight FLOAT,
  warehouse_id VARCHAR(255) 
  );
### Hi carreguem les dades
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/products.csv' 
INTO TABLE products 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES;

#SELECT * FROM products;

# Ara relacionem les taules
ALTER TABLE productspertransaction
ADD FOREIGN KEY (product_id)
REFERENCES products(id);

ALTER TABLE productspertransaction
ADD FOREIGN KEY (transaction_id)
REFERENCES transactions(id);

## Exercici 1
### Necessitem conèixer el nombre de vegades que s'ha venut cada producte.
SELECT product_id, product_name, count(*) as soldItems
FROM (SELECT product_id, product_name
	  FROM productspertransaction
      LEFT JOIN transactions
      ON transaction_id = id
      LEFT JOIN products
      ON product_id = products.id
      WHERE declined = 0) as soldProducts
GROUP BY product_id
ORDER BY soldItems DESC;
