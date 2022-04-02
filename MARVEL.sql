use marvel;

TRUNCATE marvel_sales;

DROP TABLE marvel_sales;

LOAD DATA local infile 'C:/Users/turkd/OneDrive/Desktop/Projects/MARVEL/marvel_clean.csv' into table marvel_sales
fields terminated by ','
enclosed by '"'
lines terminated by '\n'
ignore 1 rows;


SHOW GLOBAL VARIABLES
WHERE variable LIKE 'infile';

show processlist;

CALL mysql.rds_kill(51);

show global variables like 'local_infile';

set global local_infile=true;


SELECT * FROM Marvel_Sales;

SELECT * FROM Marvel_Reviews;

SELECT title, releasedateus as Date, budget, MAX(openingweekendnorthamerica)/1000000 as TOP_Selling_Release_Millions, NorthAmerica, Otherterritories
FROM Marvel_sales; 

/* Top Opening Weekends */ 
SELECT title, releasedateus as Date, budget, MAX(openingweekendnorthamerica)/1000000 as TOP_Selling_Release_Millions, NorthAmerica, Otherterritories
FROM Marvel_sales
GROUP BY Title
ORDER BY TOP_Selling_Release_Millions DESC
LIMIT 5; 

/* Top Totals*/ 
SELECT title, releasedateus as Date, budget/1000000 as budget_Millions, SUM(NorthAmerica + Otherterritories)/1000000 as Tot_sales_millions
FROM Marvel_sales
GROUP BY Title
ORDER BY Tot_sales_millions DESC
; 


/* percent profit */ 
WITH CTE_profit as
(
SELECT title, releasedateus as Date, budget/1000000 as budget_Millions, SUM(NorthAmerica + Otherterritories)/1000000 as Tot_sales_millions
FROM Marvel_sales
GROUP BY Title
ORDER BY Tot_sales_millions DESC
)
SELECT title, budget_Millions, Tot_sales_millions, (Tot_sales_millions/budget_Millions) as PERCENT_PROFIT
FROM CTE_profit
ORDER BY PERCENT_PROFIT DESC;

/* join sales to reviews */ 
SELECT title, 
		releasedateus as Date, 
		budget/1000000 as budget_Millions, 
        SUM(NorthAmerica + Otherterritories)/1000000 as Tot_sales_millions, 
        `Rotten Tomatoesin%` as Rotten_Tomatoes, 
        Metacritic, 
        CinemaScore
FROM Marvel_sales
JOIN Marvel_Reviews as reviews
ON Marvel_Sales.Title = Reviews.film
GROUP BY Title
ORDER BY Tot_sales_millions DESC;


/* AVG Budget and metascore */ 
WITH CTE_reviews as
(
SELECT title, budget/1000000 as budget_Millions, SUM(NorthAmerica + Otherterritories)/1000000 as Tot_sales_millions, AVG(metacritic) as AVG_Meta
FROM Marvel_sales
JOIN Marvel_Reviews as reviews
ON Marvel_Sales.Title = Reviews.film
GROUP BY Title
ORDER BY Tot_sales_millions DESC
)
SELECT avg(budget_millions) as AVG_Budget, AVG_Meta
FROM CTE_reviews 
ORDER BY AVG_Meta DESC;