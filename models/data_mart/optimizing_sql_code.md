## Optimizing some SQL code:

Below is the old code. In the CTE named __last_ride__, it uses a correlated sub_query to filter the results for the __MAX(end_time)__. This is a costly
and slow way of writting the code. Below this query, I will re-write it and use a window function to achieve the same result. 

```SQL

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

```

### The new query:

This query instead uses a sub_query in the FROM clause. The sub_query adds a row number to each bike_id, ranking with the most recent __end_time__
in first position and the oldest end_time in last. The window function __PARTIONS BY__ bike_id and __ORDERs BY__ end_time __DESC__. Using row_number here is applicable instead of RANK or
 DENSE_RANK as there is no chance of duplicate end_times (The same bike can't be checked in more than once per ride); but DBT runs tests checking for
  duplicates as a redundancy. The main query then filters the results to only include rows with a row number of 1, ensuring that we only extract rows with
  the maximum end_time (the latest ride per bike). This query yeilds the exact same result as the first query but is optimized for performance.

```SQL

--Selecting the last ride of each unique bike_id
  WITH last_ride AS
 ( 
SELECT 
    bike_id,
    ride_id,
    current_station_name,
    current_station_id
FROM 
  (
  SELECT 
    row_number() OVER (PARTITION BY bike_id ORDER BY end_time DESC) AS row_num,
    bike_id,
    ride_id,
    end_station_name as current_station_name,
    end_station_id as current_station_id
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

```