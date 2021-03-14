USE country_vaccinations;

SELECT * FROM country_vaccinations;

UPDATE country_vaccinations
SET daily_vaccinations_raw = NULL
WHERE daily_vaccinations_raw = '';

UPDATE country_vaccinations
SET daily_vaccinations = NULL
WHERE daily_vaccinations = '';

UPDATE country_vaccinations
SET total_vaccinations = NULL
WHERE total_vaccinations = '';

ALTER TABLE country_vaccinations MODIFY daily_vaccinations_raw INTEGER;
ALTER TABLE country_vaccinations MODIFY daily_vaccinations INTEGER;
ALTER TABLE country_vaccinations MODIFY total_vaccinations INTEGER;

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

SELECT * FROM daily_vacc;

SELECT
	DISTINCT country,
    MAX(total_vaccinations) as max,
    SUM(daily_vaccinations) as daily_sum,
    ABS((SUM(daily_vaccinations)-MAX(total_vaccinations))/MAX(total_vaccinations)) as percent_difference
FROM daily_vacc
GROUP BY country
ORDER BY country;