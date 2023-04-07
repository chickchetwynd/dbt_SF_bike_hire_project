SELECT 

    row_number() OVER () as ride_id,
    date,
    duration_mins,
    start_time,
    end_time,
    start_station_id,
    start_station_name,
    end_station_id,
    end_station_name,
    bike_id,
    user_type,
    avg_rain,
    avg_temp,
    max_temp,
    min_temp,
    rainfall_category
    
FROM {{ ref('stg_sf_bike_hire') }} INNER JOIN {{ ref('stg_sf_weather') }}
USING (date)