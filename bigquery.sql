-- task  1
SELECT
  date AS FECHA,
  COUNT(*) AS TOTAL
FROM
  `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE
  date = '2020-04-15'
GROUP BY
  FECHA;


-- TASK 2
SELECT
  date AS FECHA,
  COUNT(*) AS total_cases_worldwide
FROM
  `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE
  date = '2020-04-15'
GROUP BY
  FECHA;




-- TASK 3

SELECT
  subregion1_name AS state,
  cumulative_confirmed AS total_confirmed_cases
FROM
  `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE
  country_name = 'United States of America'
  AND date = '2020-04-20'
ORDER BY
  cumulative_confirmed desc

-- task 4

  SELECT
  SUM(cumulative_confirmed) AS total_confirmed_cases,
  SUM(cumulative_deceased) AS total_deaths,
  (SUM(cumulative_deceased) / SUM(cumulative_confirmed)) * 100 AS case_fatality_ratio
FROM
  `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE
  country_name = 'Italy'
  AND date BETWEEN '2020-05-01' AND '2020-05-31'
GROUP BY
  country_name;


-- Task 5. Identificar día específico


SELECT 
    date
FROM 
    `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE 
    country_name = "Italy"
    AND cumulative_deceased >= 8000 
ORDER BY 
    date ASC 
LIMIT 1; 



-- task 6 

WITH india_cases_by_date AS (
    SELECT
        date,
        SUM(cumulative_confirmed) AS cases
    FROM
        `bigquery-public-data.covid19_open_data.covid19_open_data`
    WHERE
        country_name = "India"
        AND date BETWEEN '2020-02-23' AND '2020-03-12' 
    GROUP BY
        date
    ORDER BY
        date ASC
),
india_previous_day_comparison AS (
    SELECT 
        date,
        cases,
        LAG(cases) OVER (ORDER BY date) AS previous_day,
        cases - LAG(cases) OVER (ORDER BY date) AS net_new_cases 
    FROM 
        india_cases_by_date
)
SELECT 
    date,
    cases,
    previous_day,
    net_new_cases
FROM 
    india_previous_day_comparison
WHERE 
    net_new_cases = 0; 


-- Task 7. Tasa de duplicación E

WITH us_cases_by_date AS (
    SELECT
        date,
        SUM(cumulative_confirmed) AS cases
    FROM
        `bigquery-public-data.covid19_open_data.covid19_open_data`
    WHERE
        country_name = "United States"
        AND date BETWEEN '2020-03-22' AND '2020-04-20' 
    GROUP BY
        date
    ORDER BY
        date ASC
),
us_previous_day_comparison AS (
    SELECT 
        date,
        cases,
        LAG(cases) OVER (ORDER BY date) AS previous_day,
        (cases - LAG(cases) OVER (ORDER BY date)) / LAG(cases) OVER (ORDER BY date) * 100 AS percentage_increase
    FROM 
        us_cases_by_date
)
SELECT 
    date,
    cases,
    previous_day,
    percentage_increase
FROM 
    us_previous_day_comparison
WHERE 
    percentage_increase > 20;



-- Task 8. Tasa de recuperación

SELECT 
    country_name AS country,
    SUM(cumulative_recovered) AS recovered_cases,
    SUM(cumulative_confirmed) AS confirmed_cases,
    (SUM(cumulative_recovered) / SUM(cumulative_confirmed)) * 100 AS recovery_rate
FROM 
    `bigquery-public-data.covid19_open_data.covid19_open_data`
WHERE 
    date <= '2020-05-10'  
GROUP BY 
    country_name
HAVING 
    SUM(cumulative_confirmed) > 50000 
ORDER BY 
    recovery_rate DESC 
LIMIT 20;  


-- task 9


WITH france_cases AS (
  SELECT 
    date, 
    SUM(cumulative_confirmed) AS total_cases
  FROM
    `bigquery-public-data.covid19_open_data.covid19_open_data`
  WHERE 
    country_name = "France" 
    AND date IN ('2020-01-24', '2020-05-10') 
  GROUP BY 
    date
  ORDER BY 
    date
), summary AS (
  SELECT 
    MIN(CASE WHEN date = '2020-01-24' THEN total_cases END) AS first_day_cases,
    MAX(CASE WHEN date = '2020-05-10' THEN total_cases END) AS last_day_cases,
    DATE_DIFF('2020-05-10', '2020-01-24', DAY) AS days_diff
  FROM 
    france_cases
)
SELECT 
  first_day_cases, 
  last_day_cases, 
  days_diff,
  POWER((last_day_cases / first_day_cases), (1.0 / days_diff)) - 1 AS cdgr
FROM 
  summary;



