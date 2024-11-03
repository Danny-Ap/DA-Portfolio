-- Data Cleaning

SELECT * FROM layoffs;
SELECT * FROM layoffs WHERE country LIKE '%Is%';
SELECT * FROM layoffs WHERE country = 'Israel';

-- 1. Remove Duplicates
-- 2. Standardize the Data (spelling issues, ...)
-- 3. NULL/Blank values 
-- 4. Remove unnesecary columns


CREATE TABLE layoffs_staging
LIKE layoffs;
INSERT layoffs_staging SELECT * FROM layoffs; -- Insert everything from layoffs to _staging
SELECT * FROM layoffs_staging; -- NEVER WORK ON RAW DATA

-- 1. Remove duplicates

SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, industry, total_laid_off, percentage_laid_off, `date`) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1; -- Gives us duplicates in company, industry, total_laid_off, ...


-- Individual checking duplicate companies where ALL columns are the same, because some duplicates look alike but can be from different countries like Oda
SELECT *
FROM layoffs_staging
WHERE company = 'Casper';

DELETE 
FROM duplicate_cte
WHERE row_num > 1; -- CANNOT use 'DELETE' from a CTE



CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` bigint DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` bigint DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM layoffs_staging2;

INSERT INTO layoffs_staging2 -- Where adding the row_num
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
FROM layoffs_staging
;

DELETE FROM layoffs_staging2 WHERE row_num > 1;
SELECT * FROM layoffs_staging2 WHERE row_num > 1; -- after we deleted it, this should be empty



-- 2. Standardizing data

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company); -- Trim removes the white spaces


SELECT DISTINCT industry, TRIM(industry)
FROM layoffs_staging2
ORDER BY 1; -- We see NULL, empty & 3 times Crypto currency written differently

SELECT * FROM layoffs_staging2 
WHERE industry LIKE 'Crypto%'; -- Update CryptoCurrency / Crypto Currency --> Crypto


UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%'; -- Changing everything that has Crypto% to --> Crypto

SELECT DISTINCT industry FROM layoffs_staging2;


SELECT DISTINCT country FROM layoffs_staging2
ORDER BY 1; -- We found United States & United States.

SELECT * FROM layoffs_staging2 WHERE country LIKE 'United States.';
UPDATE layoffs_staging2 SET country = 'United States' WHERE country LIKE 'United States.'; -- Changed 'states.' to 'States'

SELECT `date`,
STR_TO_DATE(`date`, '%d/%m/%Y') -- Doesnt work well because the string is in mm/dd/yyyy
FROM layoffs_staging2;

SELECT `date`,
DATE_FORMAT(STR_TO_DATE(`date`, '%m/%d/%Y'),'%d/%m/%Y') as new_date -- First converts the string mm/dd/yyyy to a date format m/d/Y, then FORMATS the m/d/Y to dd/mm/YYYY
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = DATE_FORMAT(STR_TO_DATE(`date`, '%m/%d/%Y'),'%d/%m/%Y');

SELECT `date`, 
STR_TO_DATE(`date`, '%d/%m/%Y') as new_date
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`, '%d/%m/%Y');

SELECT * FROM layoffs_staging2; -- date column is now date type, date is still 'text' in columns but its in date format

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE; -- Changed type from string to date



-- 3. Looking at NULLs/blanks

SELECT * FROM layoffs_staging2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

SELECT * FROM layoffs_staging2
WHERE industry IS NULL OR industry = '';


SELECT * FROM layoffs_staging2
WHERE company = 'Airbnb';

SELECT * FROM layoffs_staging2 as t1
JOIN layoffs_staging2 as t2
	ON t1.company = t2.company
    AND t1.location = t2.location
WHERE(t1.industry IS NULL OR t1.industry = '')
AND t2.industry IS NOT NULL;


ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT * FROM layoffs_staging2
WHERE (total_laid_off IS NULL OR total_laid_off = '')
AND (percentage_laid_off IS NULL OR percentage_laid_off = '');

-- We will delete those as we cannot use them
DELETE FROM layoffs_staging2
WHERE (total_laid_off IS NULL OR total_laid_off = '')
AND (percentage_laid_off IS NULL OR percentage_laid_off = '');

SELECT DISTINCT (count(company)), count(company) FROM layoffs_staging2;
SELECT DISTINCT (count(location)), count(location) FROM layoffs_staging2;
