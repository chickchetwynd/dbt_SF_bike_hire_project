--Selecting the last ride of each unique bike_id
  WITH last_ride AS
 ( 
  SELECT
        bike_id,
        max(end_time) as end_time

    FROM {{ ref('sf_bike_hire_and_weather') }}
  
    GROUP BY bike_id
    ORDER BY bike_id ASC
 ),

--Selecting the location (end station name and id) of each unique bike_id
current_location AS
(
 SELECT
    last_ride.bike_id as bike_id,
    end_station_id as current_station_id,
    end_station_name as current_station_name

 FROM last_ride INNER JOIN {{ ref('sf_bike_hire_and_weather') }}
                USING (end_time)

 ORDER BY bike_id ASC
)

SELECT

    current_location.bike_id,
    current_location.current_station_id,
    current_location.current_station_name,

    CASE
        WHEN
            total_ride_time >= 15000 THEN "Urgent maintenance needed"
        WHEN
            total_ride_time >= 10000 AND total_ride_time < 15000 THEN "Maintenance needed"
        WHEN
            total_ride_time >= 7000 AND total_ride_time <10000 THEN "Maintenance soon"
        ELSE
            "Riding sweet!" END as status


FROM current_location INNER JOIN {{ ref('bike_total_ride_duration') }} USING (bike_id)

ORDER BY bike_id ASC