WITH CTE AS
(
SELECT 
  DATE as date,
  ROUND(AVG(PRCP), 2) AS avg_rain,
  ROUND(AVG(TAVG), 2) AS avg_temp,
  ROUND(AVG(TMAX),2) AS max_temp,
  ROUND(AVG(TMIN), 2) AS min_temp,

 FROM {{ source('sf_bike_hire', 'sf_weather') }}
 GROUP BY DATE
 ORDER BY DATE
)

SELECT

  DATE,
  avg_rain,
  avg_temp,
  max_temp,
  min_temp,

  CASE
    WHEN avg_rain < 2.5 THEN "low rainfall"
    WHEN avg_rain >= 2.5 AND avg_rain < 10 THEN "moderate rainfall"
    WHEN avg_rain >= 10 THEN "high rainfall"
    END AS rainfall_category

  FROM CTE