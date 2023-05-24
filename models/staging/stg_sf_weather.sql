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
    WHEN avg_rain < 2.5 THEN "Low Rainfall"
    WHEN avg_rain >= 2.5 AND avg_rain < 10 THEN "Moderate Rainfall"
    WHEN avg_rain >= 10 THEN "High Rainfall"
    END AS rainfall_category,

  CASE
    WHEN avg_temp < 15 THEN "Cold"
    WHEN avg_temp >= 15 AND avg_temp < 20 THEN "Warm"
    WHEN avg_temp >= 20 THEN "Hot"
    END AS temperature_category

  FROM CTE