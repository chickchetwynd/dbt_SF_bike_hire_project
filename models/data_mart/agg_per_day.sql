SELECT

    date,
    start_station_id,
    start_station_name,
    avg_rain,
    avg_temp,
    max_temp,
    min_temp,
    ROUND(AVG(duration_mins), 1) as avg_duration

FROM {{ ref('sf_bike_hire_and_weather') }}

GROUP BY date,
    start_station_id,
    start_station_name,
    avg_rain,
    avg_temp,
    max_temp,
    min_temp

ORDER BY DATE ASC