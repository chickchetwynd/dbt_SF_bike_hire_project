--Selecting the last ride of each unique bike_id
  WITH last_ride AS
 ( 
SELECT 
    bike_id,
    ride_id,
    current_station_name,
    current_station_id,
    current_station_latitude,
    current_station_longitude
FROM 
  (
  SELECT 
    row_number() OVER (PARTITION BY bike_id ORDER BY end_time DESC) AS row_num,
    bike_id,
    ride_id,
    end_station_name as current_station_name,
    end_station_id as current_station_id,
    end_station_latitude as current_station_latitude,
    end_station_longitude as current_station_longitude
  FROM {{ ref('sf_bike_hire_and_weather') }}
  )
WHERE row_num = 1
ORDER BY bike_id
 )

--Selecting all info from the CTE and adding a status category (based off total ride time)
 SELECT

    last_ride.bike_id,
    last_ride.current_station_id,
    last_ride.current_station_name,
    last_ride.current_station_latitude,
    last_ride.current_station_longitude,

    CASE
        WHEN
            total_ride_time >= 15000 THEN "Urgent maintenance needed"
        WHEN
            total_ride_time >= 10000 AND total_ride_time < 15000 THEN "Maintenance needed"
        WHEN
            total_ride_time >= 7000 AND total_ride_time <10000 THEN "Maintenance soon"
        ELSE
            "Riding sweet!" END as status


FROM last_ride INNER JOIN {{ ref('bike_total_ride_duration') }} USING (bike_id)

ORDER BY bike_id ASC