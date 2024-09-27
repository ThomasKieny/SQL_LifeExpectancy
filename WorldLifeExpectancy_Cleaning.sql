-- PART I : CLEANING DATA 

-- Identify duplicated rows
SELECT *
FROM ( 
	SELECT 
	Row_ID,
    ROW_NUMBER () OVER (PARTITION BY CONCAT(Country, Year)) as Row_Num
	FROM world_life_expectancy
    ) AS Row_Table
WHERE Row_Num > 1
;

-- Delete duplicated rows 
DELETE FROM world_life_expectancy
WHERE Row_ID IN (
	SELECT Row_ID
	FROM ( 
		SELECT 
		Row_ID,
		ROW_NUMBER () OVER (PARTITION BY CONCAT(Country, Year)) as Row_Num
		FROM world_life_expectancy
		) AS Row_Table
	WHERE Row_Num > 1
)
;

-- Handle blanks in the 'status' column
-- Populate 'status' blanks for developing countries
SELECT * 
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developing';


UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
SET t1.Status = 'Developing'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developing';

-- Populate 'status' blanks for developed countries
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
SET t1.Status = 'Developed'
WHERE t1.Status = ''
AND t2.Status <> ''
AND t2.Status = 'Developed';


-- Populate 'Life expectancy' when blank 
-- Identify blanks in 'Life expectancy'
SELECT Country,
	Year, 
    `Life expectancy`
FROM world_life_expectancy
WHERE `Life expectancy` = '';

-- Calculate the average between year N+1 and year N-1 when we have missing values in 'Life expectancy'. 
-- The column 'Avg' are the values we will need to integrate in our database.
SELECT 
	t1.Country, t1.Year, t1.`Life expectancy`,
	ROUND((t2.`Life expectancy`+ t3.`Life expectancy`)/2 , 1) AS Avg 
FROM world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
	AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
	AND t1.Year = t3.Year + 1
WHERE t1.`Life expectancy` = ''
;

-- Update the database with the calculated average for 'Life expectancy'
UPDATE world_life_expectancy t1
JOIN world_life_expectancy t2
	ON t1.Country = t2.Country
	AND t1.Year = t2.Year - 1
JOIN world_life_expectancy t3
	ON t1.Country = t3.Country
	AND t1.Year = t3.Year + 1
SET t1.`Life expectancy` = ROUND((t2.`Life expectancy`+ t3.`Life expectancy`)/2 , 1)
WHERE t1.`Life expectancy` = ''
;

SELECT Country, ROUND(AVG(`Life expectancy`),1) as avg_life_exp
FROM world_life_expectancy
GROUP BY Country
ORDER BY avg_life_exp
;

-- Handle the '0' in 'Life expectancy' 
-- Additional information found on the Data World Bank. Add the table 'Life expectancy at birth' in our database. 
SELECT * FROM world_life_expectancy.additional_life_expectancy;

ALTER TABLE additional_life_expectancy RENAME COLUMN `ï»¿Country Name` TO `Country Name`;
DELETE FROM additional_life_expectancy WHERE `Country Name` = 'ï»¿Country Name';


-- Replace 'Life expectancy' for countries with 0, when data is available.  

SELECT *
FROM additional_life_expectancy
WHERE `Country Name` IN ('Cook Islands','Dominica','Marshall Islands','Monaco','Nauru','Niue','Palau','Saint Kitts and Nevis','San Marino','Tuvalu')
;
-- We only have information for Dominica, St. Kitts and Nevis, Marshall Islands, Nauru and Tuvalu.

-- We notice that 'St. Kitts and Nevis' is not called the same way in both table. We need to align. 
UPDATE additional_life_expectancy  
SET `Country Name` = 'Saint Kitts and Nevis'
WHERE `Country Name` = 'St. Kitts and Nevis'
; 

-- We can do the same for Cote d'Ivoire which is mispelled
UPDATE world_life_expectancy  
SET `Country` = "Cote d'Ivoire"
WHERE `Country` = "CÃ´te d'Ivoire"
; 

-- Reformat the additional_life_expectancy table to have something similar to our original table
-- For this, we create a new table named normalized_life_expectancy
CREATE TABLE normalized_life_expectancy (
	`Country Name` VARCHAR(100),
    `Country Code` VARCHAR(10),
    `Year` INT,
    `Life Expectancy` DECIMAL(5, 1)
);

-- We need to format the values in our additional_life_expectancy table and round them with 1 decimal
UPDATE additional_life_expectancy 
SET `2007` = ROUND(`2007`, 1), 
    `2008` = ROUND(`2008`, 1),
    `2009` = ROUND(`2009`, 1),
    `2010` = ROUND(`2010`, 1),
    `2011` = ROUND(`2011`, 1),
    `2012` = ROUND(`2012`, 1),
    `2013` = ROUND(`2013`, 1),
    `2014` = ROUND(`2014`, 1),
    `2015` = ROUND(`2015`, 1),
    `2016` = ROUND(`2016`, 1),
    `2017` = ROUND(`2017`, 1),
    `2018` = ROUND(`2018`, 1),
    `2019` = ROUND(`2019`, 1),
    `2020` = ROUND(`2020`, 1),
    `2021` = ROUND(`2021`, 1),
    `2022` = ROUND(`2022`, 1);
    

-- Insert values from the additional_life_expectancy into our normalized table
INSERT INTO normalized_life_expectancy (`Country Name`, `Country Code`, `Year`, `Life Expectancy`)
SELECT `Country Name`, `Country Code`, 2007 AS Year, `2007` AS `Life Expectancy` FROM additional_life_expectancy
UNION ALL
SELECT `Country Name`, `Country Code`, 2008 AS Year, `2008` AS `Life Expectancy` FROM additional_life_expectancy
UNION ALL
SELECT `Country Name`, `Country Code`, 2009 AS Year, `2009` AS `Life Expectancy` FROM additional_life_expectancy
UNION ALL
SELECT `Country Name`, `Country Code`, 2010 AS Year, `2010` AS `Life Expectancy` FROM additional_life_expectancy
UNION ALL
SELECT `Country Name`, `Country Code`, 2011 AS Year, `2011` AS `Life Expectancy` FROM additional_life_expectancy
UNION ALL
SELECT `Country Name`, `Country Code`, 2012 AS Year, `2012` AS `Life Expectancy` FROM additional_life_expectancy
UNION ALL
SELECT `Country Name`, `Country Code`, 2013 AS Year, `2013` AS `Life Expectancy` FROM additional_life_expectancy
UNION ALL
SELECT `Country Name`, `Country Code`, 2014 AS Year, `2014` AS `Life Expectancy` FROM additional_life_expectancy
UNION ALL
SELECT `Country Name`, `Country Code`, 2015 AS Year, `2015` AS `Life Expectancy` FROM additional_life_expectancy
UNION ALL
SELECT `Country Name`, `Country Code`, 2016 AS Year, `2016` AS `Life Expectancy` FROM additional_life_expectancy
UNION ALL
SELECT `Country Name`, `Country Code`, 2017 AS Year, `2017` AS `Life Expectancy` FROM additional_life_expectancy
UNION ALL
SELECT `Country Name`, `Country Code`, 2018 AS Year, `2018` AS `Life Expectancy` FROM additional_life_expectancy
UNION ALL
SELECT `Country Name`, `Country Code`, 2019 AS Year, `2019` AS `Life Expectancy` FROM additional_life_expectancy
UNION ALL
SELECT `Country Name`, `Country Code`, 2020 AS Year, `2020` AS `Life Expectancy` FROM additional_life_expectancy
UNION ALL
SELECT `Country Name`, `Country Code`, 2021 AS Year, `2021` AS `Life Expectancy` FROM additional_life_expectancy
UNION ALL
SELECT `Country Name`, `Country Code`, 2022 AS Year, `2022` AS `Life Expectancy` FROM additional_life_expectancy
;

SELECT *
FROM normalized_life_expectancy
WHERE `Country Name` IN ('Cook Islands','Dominica','Marshall Islands','Monaco','Nauru','Niue','Palau','Saint Kitts and Nevis','San Marino','Tuvalu');

SELECT *
FROM world_life_expectancy;

-- Verify number of rows for each country
SELECT Country, COUNT(*) as row_count
FROM world_life_expectancy
GROUP BY Country
ORDER BY row_count;
-- We notice that all countries have 16 rows of data except the ones where life expectancy is 0, where we only have 1 row of values (for year 2020). 
-- For exercise purposes, we will still add the 2020 values in our table even if we won't use them afterwards as we are missing all values for almost all years for these countries

SELECT *
FROM world_life_expectancy w
JOIN normalized_life_expectancy n
	ON w.Country = n.`Country Name`
	AND w.Year = n.Year
WHERE w.Country IN ('Cook Islands','Dominica','Marshall Islands','Monaco','Nauru','Niue','Palau','Saint Kitts and Nevis','San Marino','Tuvalu')
;

UPDATE world_life_expectancy w
JOIN normalized_life_expectancy n
	ON w.Country = n.`Country Name`
	AND w.Year = n.Year
SET w.`Life expectancy` = n.`Life Expectancy`
WHERE w.Country IN ('Cook Islands','Dominica','Marshall Islands','Monaco','Nauru','Niue','Palau','Saint Kitts and Nevis','San Marino','Tuvalu')
;

-- Verify the update worked
SELECT Country, `Life expectancy`
FROM world_life_expectancy
WHERE Country IN ('Cook Islands','Dominica','Marshall Islands','Monaco','Nauru','Niue','Palau','Saint Kitts and Nevis','San Marino','Tuvalu')
;






















































