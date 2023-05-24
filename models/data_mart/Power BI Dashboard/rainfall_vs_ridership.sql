SELECT

    date,
    COUNT(DISTINCT ride_id) AS num_of_rides,
    avg_rain,
    avg_temp


FROM {{ ref("sf_bike_hire_and_weather") }}


GROUP BY date, avg_rain, avg_temp

ORDER BY date ASC