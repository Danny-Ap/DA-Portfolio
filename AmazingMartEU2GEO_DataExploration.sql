-- INTRODUCTION:
-- Questions that came to mind after looking at this dataset:
-- 1. Clean the data, drop unnecessary columns, change important columns
-- 2. Insight to shareholders: What category give the most revenue? What gives the least? (or loses money altogether?) What categories give the most profit percentage wise compared to their sales? What gives the least?
-- 3. Same as 2, but for countries. What countries give the most revenue + percentage wise from sales? What countries give the least, or loses money?
-- 4. Which products gains the most profit? Which products loses us money?
-- 5. Which country has the most orders? Which country has the least? country with not enough orders needs more advertising.




-- 1. Cleaning, reorganising & adding % column
SELECT * FROM amazingmarteu2geo_orderbreakdown;
SELECT * FROM amazingmarteu2geo_listoforders;

-- on accident changed column in raw data, NEVER DO THIS
ALTER TABLE amazingmarteu2geo_orderbreakdown RENAME COLUMN `Sub-Category` TO SubCategory;

-- Make new tables, NEVER WORK ON RAW DATA
CREATE TABLE ListOfOrders
LIKE amazingmarteu2geo_listoforders;
INSERT ListOforders SELECT * FROM amazingmarteu2geo_listoforders;

CREATE TABLE OrderBreakDown
LIKE amazingmarteu2geo_orderbreakdown;
ALTER TABLE listoforders RENAME COLUMN `Sub-Category` TO SubCategory;
INSERT orderbreakdown SELECT * FROM amazingmarteu2geo_orderbreakdown;


SELECT * FROM listoforders;
SELECT * FROM orderbreakdown;

-- Dropping unimportant columns
ALTER TABLE listoforders DROP COLUMN lon;
ALTER TABLE listoforders DROP COLUMN lat;
ALTER TABLE listoforders DROP COLUMN Region;
ALTER TABLE listoforders DROP COLUMN State;

SELECT REPLACE(Sales, '$', '') as Sales, REPLACE(Profit, '$', '') as Profit FROM orderbreakdown;
SELECT REPLACE(Sales, ',00', '') as Sales FROM orderbreakdown;
SELECT LEFT(Sales, LENGTH(Sales) -3) FROM orderbreakdown;
SELECT LEFT(Profit, LENGTH(Profit) -3) FROM orderbreakdown;

ALTER TABLE orderbreakdown
ADD COLUMN Sales_temp text;
ALTER TABLE orderbreakdown
ADD COLUMN Profit_temp text;

UPDATE orderbreakdown
SET Sales_temp = Sales,
Profit_temp = Profit;

SELECT * FROM orderbreakdown;

SELECT Sales_temp, REPLACE(Sales_temp, '.','') FROM orderbreakdown;

UPDATE orderbreakdown SET Sales_temp = REPLACE(Sales_temp, '$', '');
UPDATE orderbreakdown SET Sales_temp = LEFT(Sales_temp, LENGTH(Sales_temp) -3);
UPDATE orderbreakdown SET Profit_temp = REPLACE(Profit_temp, '$', '');
UPDATE orderbreakdown SET Profit_temp = LEFT(Profit_temp, LENGTH(Profit_temp) -3);
UPDATE orderbreakdown SET Sales_temp = REPLACE(Sales_temp, '.','');
UPDATE orderbreakdown SET Profit_temp = REPLACE(Profit_temp,'.','');

ALTER TABLE orderbreakdown
ADD COLUMN Sales_temp2 int;
ALTER TABLE orderbreakdown
ADD COLUMN Profit_temp2 int;

UPDATE orderbreakdown
SET Sales_temp2 = Sales_temp;
UPDATE orderbreakdown
SET Profit_temp2 = Profit_temp;

ALTER TABLE orderbreakdown
DROP COLUMN Sales_temp;
ALTER TABLE orderbreakdown
DROP COLUMN Profit_temp;

ALTER TABLE orderbreakdown
ADD COLUMN ProfitPercentageSales float;

SELECT Sales, Profit, Sales_temp2, Profit_temp2, ((Profit_temp2/Sales_temp2)*100) as perc
FROM orderbreakdown;

UPDATE orderbreakdown
SET ProfitPercentageSales = ((Profit_temp2/Sales_temp2)*100);


-- 2. What category gives the most revenue

SELECT DISTINCT(Category), SUM(Profit_temp2), SUM(Sales_temp2), AVG(ProfitPercentageSales) FROM orderbreakdown
GROUP BY Category;

-- 3. Same for country

SELECT 
DISTINCT(l.Country),
SUM(o.Sales_temp2) as Sales,
SUM(o.Profit_temp2) as Profit,
AVG(o.ProfitPercentageSales) as perc
FROM orderbreakdown AS o
JOIN listoforders AS l ON o.`Order ID` = l.`Order ID`
GROUP BY l.country
ORDER BY Profit DESC;

-- 4. What months has the most sales? What months the least? (is it better to show the sum of all the sales, or the average of sales, per month?)

SELECT DISTINCT(CAST(SUBSTRING(`Order Date`, 4, 2) AS UNSIGNED)) AS Mont, 
SUM(o.Sales_temp2) as Sales,
SUM(o.Profit_temp2) as Profit,
AVG(o.ProfitPercentageSales) as perc
FROM listoforders as l
JOIN orderbreakdown AS o ON o.`Order ID` = l.`Order ID`
GROUP BY mont
ORDER BY Sales DESC;


-- 5. Which countries have the most orders? Or the largest quantities?

SELECT DISTINCT(l.country),
SUM(o.Quantity) as Quantity
from listoforders AS l
JOIN orderbreakdown AS o ON o.`Order ID` = l.`Order ID`
GROUP BY l.country
ORDER BY Quantity DESC;



ALTER TABLE `project2`.`orderbreakdown` 
DROP COLUMN `Profit`,
DROP COLUMN `Sales`,
CHANGE COLUMN `Sales_temp2` `Sales` INT NULL DEFAULT NULL AFTER `Discount`,
CHANGE COLUMN `Profit_temp2` `Profit` INT NULL DEFAULT NULL AFTER `Sales`;

SELECT ProfitPercentageSales, FORMAT(ProfitPercentageSales, 2) FROM orderbreakdown;

UPDATE orderbreakdown
SET ProfitPercentageSales = FORMAT(ProfitPercentageSales, 2);

ALTER TABLE orderbreakdown
MODIFY COLUMN ProfitPercentageSales DECIMAL(5,2);

