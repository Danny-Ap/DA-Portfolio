-- Exploratory Data Analysis

SELECT * FROM layoffs_staging2;

SELECT MAX(total_laid_off), MIN(total_laid_off)
FROM layoffs_staging2;

SELECT * FROM layoffs_staging2
WHERE percentage_laid_off = 1 -- companies went bankrupt? 100% laidoff
ORDER BY total_laid_off DESC;

SELECT company, SUM(total_laid_off) -- Sum to ignore NULLS & if a company has multiple laidoffs we get the sum
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;


SELECT industry, SUM(total_laid_off) -- same as before but we check industry, Consumer & Retail got hit the most because of covid?
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

SELECT country, SUM(total_laid_off) -- Laidoffs per country
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;


SELECT `date`, SUM(total_laid_off) -- Laidoffs every date
FROM layoffs_staging2
GROUP BY `date`
ORDER BY 2 DESC;

SELECT YEAR(`date`) as Year_laidoffs, SUM(total_laid_off) -- 2022 worst year, most laidoffs. but dataset goes until first quarter of 2023 & already 2023 is so high
FROM layoffs_staging2
GROUP BY Year_laidoffs
ORDER BY 2 DESC;


SELECT company, SUM(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;



SELECT substring(`date`, 1, 7) as Laidoff_month, SUM(total_laid_off) -- Most laidoffs on 2023-01
FROM layoffs_staging2
GROUP BY Laidoff_month
ORDER BY 2 DESC;

SELECT substring(`date`, 1, 7) as Laidoff_month, SUM(total_laid_off) -- Most laidoffs on 2023-01
FROM layoffs_staging2
WHERE substring(`date`, 1, 7) IS NOT NULL
GROUP BY Laidoff_month
ORDER BY 1 ASC;


WITH Rolling_total AS
(
SELECT substring(`date`, 1, 7) as laidoff_month, SUM(total_laid_off) as total_off -- Most laidoffs on 2023-01
FROM layoffs_staging2
WHERE substring(`date`, 1, 7) IS NOT NULL
GROUP BY laidoff_month
ORDER BY 1 ASC
)
SELECT laidoff_month, total_off, SUM(total_off) OVER(ORDER BY laidoff_month) as Rolling_total -- Keeps adding the next month over Rolling_total
FROM Rolling_total;


-- Want to check every companys laidoffs ranking by every year, what year a company had the most laidoffs

SELECT company, YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;



WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
)
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL; -- This gives a ranking of total_laid_off PER YEAR, meaning rank 1 has the most total_laid_offs, etc...



WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS
(
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 10; -- Gives a top 10 most laid offs per year


