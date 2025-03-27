# Nivell 1
## Exercici 1
### La teva tasca és dissenyar i crear una taula anomenada "credit_card" que emmagatzemi 
### detalls crucials sobre les targetes de crèdit. La nova taula ha de ser capaç d'identificar 
### de manera única cada targeta i establir una relació adequada amb les altres dues taules 
### ("transaction" i "company"). Després de crear la taula serà necessari que ingressis la 
### informació del document denominat "dades_introduir_credit". Recorda mostrar el diagrama i 
### realitzar una breu descripció d'aquest.

CREATE TABLE credit_card (
    id VARCHAR(15) NOT NULL,
    iban VARCHAR(50) NULL,
    pan VARCHAR(50) NULL,
    pin INT NULL,
    cvv INT NULL,
    expiring_date varchar(8) NULL, 
    PRIMARY KEY (id)
) ENGINE = InnoDB;

ALTER TABLE transaction
ADD FOREIGN KEY fk_credit_card_id(credit_card_id)
REFERENCES credit_card(id);
   
   
## Exercici 2
### El departament de Recursos Humans ha identificat un error en el número de compte de l'usuari 
### amb ID CcU-2938. La informació que ha de mostrar-se per a aquest registre és: R323456312213576817699999. 
### Recorda mostrar que el canvi es va realitzar.

UPDATE credit_card SET iban = 'R323456312213576817699999' WHERE id = 'CcU-2938';
# Comprovem
SELECT id, iban
from credit_card where id = 'CcU-2938';

## Exercici 3
### En la taula "transaction" ingressa un nou usuari amb la següent informació:

# Si intentem fer-ho directament no ens deixa pq ens diu que aquestes dades no existeixen en les
# taules de dimensions i no les pot relacionar. Per tant, primer hem d'incorporar aquestes dades
# a company i credit card. 

INSERT INTO credit_card(id) VALUES ('CcU-9999');

INSERT INTO company(id) VALUES ('b-9999');

INSERT INTO transaction(id,credit_card_id,company_id,user_id,lat,longitude,amount, declined)
    VALUES('108B1D1D-5B23-A76C-55EF-C568E49A99DD','CcU-9999','b-9999',9999,829.999,-117.999,111.11,0);

# Comprovem
SELECT *
from transaction where id = '108B1D1D-5B23-A76C-55EF-C568E49A99DD';

## Exercici 4
### Des de recursos humans et sol·liciten eliminar la columna "pan" de la taula credit_card.

ALTER TABLE credit_card DROP COLUMN pan;
DESCRIBE credit_card;

# Nivell 2
## Exercici 1
### Elimina de la taula transaction el registre amb ID 02C6201E-D90A-1859-B4EE-88D2986D3B02 
# de la base de dades.

DELETE FROM transaction WHERE id = '02C6201E-D90A-1859-B4EE-88D2986D3B02';

## Exercici 2
### La secció de màrqueting desitja tenir accés a informació específica per a realitzar anàlisi 
### i estratègies efectives. S'ha sol·licitat crear una vista que proporcioni detalls clau sobre 
### les companyies i les seves transaccions. Serà necessària que creïs una vista anomenada 
### VistaMarketing que contingui la següent informació: 
### Nom de la companyia. Telèfon de contacte. País de residència. Mitjana de compra realitzat per cada companyia. 
### Presenta la vista creada, ordenant les dades de major a menor mitjana de compra.

CREATE VIEW VistaMarketing AS
SELECT company.company_name, company.phone, company.country, ROUND(AVG(transaction.amount),2) as meanAmount
FROM transaction
LEFT JOIN company
ON transaction.company_id = company.id
WHERE transaction.declined = 0
GROUP BY transaction.company_id
ORDER BY meanAmount DESC;

## Exercici 3
### Filtra la vista VistaMarketing per a mostrar només les companyies que 
### tenen el seu país de residència en "Germany".

SELECT company_name
FROM vistamarketing
WHERE country = 'Germany';

# Nivell 3
## Exercici 1
### La setmana vinent tindràs una nova reunió amb els gerents de màrqueting. 
### Un company del teu equip va realitzar modificacions en la base de dades, però no recorda 
### com les va realitzar. Et demana que l'ajudis a deixar els comandos executats per a obtenir 
### el següent diagrama:


## 1) La relació entre user i transaction està al revés (de molts a user a 1 a transaction).

### El problema aquí és que abans hem afegit un usuari nou, el qual no apareix a la taula de users. Per això SQL detecta que hi ha més usuaris a transaction que a user i interpreta que la relació és de molts a 1.
### Per solucionar-ho, fem un drop de la foreign key, creem un nou registre a user i generem la relació.   
ALTER TABLE user DROP FOREIGN KEY user_ibfk_1;

INSERT INTO user(id)
    VALUES('9999');

ALTER TABLE transaction
ADD FOREIGN KEY fk_user_id(user_id)
REFERENCES user(id);

## 2) El co-worker ha canviat el nom de la taula user per ‘data_user’. 

ALTER TABLE user
RENAME TO data_user;

## 3) A la taula user ha canviat el nom de la variable ‘email’ per ‘personal_email’
ALTER TABLE data_user
RENAME COLUMN email TO personal_email;

## 4) A la taula company el meu co-worker va eliminar la variable website. 
ALTER TABLE company DROP COLUMN website;

## 5) A la taula credit_card el pin el vaig fer INT però el co-worker el va posar com a VARCHAR(4).
ALTER TABLE credit_card
MODIFY COLUMN pin VARCHAR(4);

## 6) A la taula credit_card, el co-worker ha afegit la variable fecha_actual, amb type DATE.
ALTER TABLE credit_card
ADD fecha_actual DATE DEFAULT (CURRENT_DATE);

## Exercici 2

### L'empresa també et sol·licita crear una vista anomenada "InformeTecnico" que contingui 
### la següent informació (...). Mostra els resultats de la vista, ordena els resultats de manera 
### descendent en funció de la variable ID de transaction.

CREATE VIEW InformeTecnico AS
SELECT transaction.id as transaction_id, company.company_name as company, 
data_user.name as user_name, data_user.surname as user_surname, credit_card.iban, 
transaction.amount, transaction.declined
FROM transaction
LEFT JOIN company
ON transaction.company_id = company.id
LEFT JOIN data_user
ON transaction.user_id = data_user.id
LEFT JOIN credit_card
ON transaction.credit_card_id = credit_card.id
ORDER BY transaction_id DESC;

SELECT * FROM informetecnico;
