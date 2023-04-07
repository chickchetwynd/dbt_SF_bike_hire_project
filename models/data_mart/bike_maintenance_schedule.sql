--Selecting the last ride of each unique bike_id
  WITH last_ride AS
 ( 
  SELECT 
  bike_id,
  ride_id,
  end_station_name as current_station_name,
  end_station_id as current_station_id


FROM {{ ref('sf_bike_hire_and_weather') }} AS bhw

WHERE end_time =
    (
    SELECT MAX(end_time)
    FROM {{ ref('sf_bike_hire_and_weather') }} AS bhw2
    WHERE bhw2.bike_id = bhw.bike_id
    )
    
ORDER BY bike_id ASC
 )

--Selecting all info from the CTE and adding a status category (based off total ride time)
 SELECT

    last_ride.bike_id,
    last_ride.current_station_id,
    last_ride.current_station_name,

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