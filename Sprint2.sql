# Nivell 1
## Exercici 2
## Utilitzant JOIN realitzaràs les següents consultes:

### Llistat dels països que estan fent compres.
SELECT DISTINCT country 
FROM company
INNER JOIN transaction
ON company.id = transaction.company_id; 

### Des de quants països es realitzen les compres.
SELECT COUNT(DISTINCT country) as numberCountries
FROM company
INNER JOIN transaction
ON company.id = transaction.company_id;

### Identifica la companyia amb la mitjana més gran de vendes.
SELECT company_name, avg(amount) as mitjanaVendes
FROM transaction
INNER JOIN company
ON transaction.company_id = company.id
where declined = 0
GROUP BY company_name
ORDER BY mitjanaVendes DESC
LIMIT 1;


## Exercici 3
## Utilitzant només subconsultes (sense utilitzar JOIN):

### Mostra totes les transaccions realitzades per empreses d'Alemanya.
SELECT * 
FROM transaction
WHERE company_id IN (SELECT id
		FROM company
        WHERE country = 'Germany');

### Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
SELECT company_name
FROM company
WHERE id IN (SELECT DISTINCT company_id 
					 FROM transaction
					 WHERE amount > (SELECT AVG(amount)
									 FROM transaction));
                
### Eliminaran del sistema les empreses que no tenen transaccions registrades, entrega el llistat d'aquestes empreses.
SELECT DISTINCT company_name
FROM company
WHERE id NOT IN (SELECT DISTINCT company_id 
				 FROM transaction);
                 
# Nivell 2
## Exercici 1
### Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. Mostra la data de cada transacció juntament amb el total de les vendes.
# Trio una empresa
# Faig un group by per data (pero nomes el dia, no l'hora)
# I una suma d'amount

SELECT DATE(timestamp) AS transaction_date, SUM(amount) as totalVentes
FROM transaction
WHERE declined = 0  
GROUP BY transaction_date
ORDER BY totalVentes DESC
LIMIT 5;


## Exercici 2
### Quina és la mitjana de vendes per país? Presenta els resultats ordenats de major a menor mitjà.
SELECT country, avg(amount) as mitjanaVendes
FROM transaction
LEFT JOIN company
ON transaction.company_id = company.id
WHERE declined = 0
group by country
ORDER BY mitjanaVendes DESC;


## Exercici 3
### En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la companyia "Non Institute". Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.
### Mostra el llistat aplicant JOIN i subconsultes.

SELECT *
FROM transaction
LEFT JOIN company
ON transaction.company_id = company.id
WHERE country = (SELECT DISTINCT country
				 FROM company
				 WHERE company_name = "Non Institute") 
AND company_name != "Non Institute";

### Mostra el llistat aplicant solament subconsultes.

SELECT * 
FROM transaction
WHERE company_id IN (SELECT id
					 FROM company 
					 WHERE country = (SELECT DISTINCT country
									  FROM company
									  WHERE company_name = "Non Institute")              
					 AND company_name NOT IN ("Non Institute"));


# Nivell 3
## Exercici 1
### Presenta el nom, telèfon, país, data i amount, d'aquelles empreses que van realitzar 
### transaccions amb un valor comprès entre 100 i 200 euros i en alguna d'aquestes dates: 
### 29 d'abril del 2021, 20 de juliol del 2021 i 13 de març del 2022. 
### Ordena els resultats de major a menor quantitat.
SELECT company.company_name, company.phone, company.country, transaction.amount
FROM transaction
LEFT JOIN company
ON transaction.company_id = company.id
WHERE DATE(timestamp) IN ('2021-04-29', '2021-07-20', '2022-03-13') AND amount BETWEEN 100 AND 200
ORDER BY amount DESC;

# Exercici 2
# Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es 
# requereixi, per la qual cosa et demanen la informació sobre la quantitat de transaccions que 
# realitzen les empreses, però el departament de recursos humans és exigent i vol un llistat 
# de les empreses on especifiquis si tenen més de 4 transaccions o menys.

SELECT company.company_name, count(*) as numTrans,     
	CASE 
        WHEN COUNT(*) > 4 THEN 'Yes'
        ELSE 'No'
    END AS mes4Trans
FROM transaction
LEFT JOIN company
ON transaction.company_id = company.id
group by company_id
order by mes4Trans desc;

