# use schema called country_vaccinations
USE country_vaccinations;

# check dataset
SELECT * FROM country_vaccinations;

/* 
When importing the datset, the missing values
were interpreted as an empty string. Below, I set certain columns
so that the empty strings get converted into NULL values. Doing so
will allow the proper use of aggregate functions.
*/

UPDATE country_vaccinations
SET daily_vaccinations_raw = NULL
WHERE daily_vaccinations_raw = '';

UPDATE country_vaccinations
SET daily_vaccinations = NULL
WHERE daily_vaccinations = '';

UPDATE country_vaccinations
SET total_vaccinations = NULL
WHERE total_vaccinations = '';

/*
All columns were imported as text variables,
so below are where certain columns get converted
from text into integer.
*/

ALTER TABLE country_vaccinations MODIFY daily_vaccinations_raw INTEGER;
ALTER TABLE country_vaccinations MODIFY daily_vaccinations INTEGER;
ALTER TABLE country_vaccinations MODIFY total_vaccinations INTEGER;

# create a temporary table in the database server and clean the daily_vaccinations column
CREATE TEMPORARY TABLE daily_vacc
SELECT 
	country,
    iso_code,
    date,
    COALESCE(daily_vaccinations_raw, daily_vaccinations, total_vaccinations) as daily_vaccinations,
    total_vaccinations,
    vaccines
FROM country_vaccinations
ORDER BY country, date;

# check dataset in the temp table
SELECT * FROM daily_vacc;

# calculating percentage differences by country
SELECT
	DISTINCT country,
    MAX(total_vaccinations) as max,
    SUM(daily_vaccinations) as daily_sum,
    ABS((SUM(daily_vaccinations)-MAX(total_vaccinations))/MAX(total_vaccinations)) as percent_difference
FROM daily_vacc
GROUP BY country
ORDER BY country;

# checking first day by each country
SELECT
	DISTINCT country,
    min(date),
    daily_vaccinations,
    total_vaccinations
FROM daily_vacc
GROUP BY country
ORDER BY country;

SELECT * FROM daily_vacc;

# temporary table for non-adjusted day numbers
# day 1 includes dates where there are no daily_vaccinations
CREATE TEMPORARY TABLE day_num_temp
SELECT
	country,
    iso_code,
    date,
    daily_vaccinations,
    total_vaccinations,
    vaccines,
    DENSE_RANK() OVER (PARTITION BY country ORDER BY country, date) as day
FROM daily_vacc;

SELECT * FROM day_num_temp;

# delete day 1s where there were no daily_vaccinations
DELETE FROM day_num_temp
WHERE daily_vaccinations IS NULL AND day = 1;

# create temp table for adjusted day numbers
# the day numbers are correct in this table
CREATE TEMPORARY TABLE day_num
SELECT
	country,
    iso_code,
    date,
    daily_vaccinations,
    total_vaccinations,
    vaccines,
    DENSE_RANK() OVER (PARTITION BY country ORDER BY country, date) as day
FROM day_num_temp;

SELECT * FROM day_num;

# create new column with cumulative vaccinations
# export this table into a csv file
SELECT
	country,
    iso_code,
    date,
    daily_vaccinations,
    SUM(daily_vaccinations) OVER (PARTITION BY country ORDER BY country, date) AS cumulative_vaccinations,
    vaccines,
    day
FROM day_num;

-- After importing country_vaccinations_clean.csv and world_data.csv

SELECT 
    *
FROM
    country_vaccinations_clean;

SELECT 
    *
FROM
    world_data;
    
SELECT 
    *
FROM
    country_vaccinations_clean c
	LEFT JOIN
    world_data w ON c.country = w.Entity;