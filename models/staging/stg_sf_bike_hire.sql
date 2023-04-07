WITH bike_hire AS
(
SELECT

  ROUND((duration_sec / 60), 2) as duration_mins,
  TIMESTAMP_TRUNC(start_time, SECOND) as start_time,
  TIMESTAMP_TRUNC(end_time, SECOND) as end_time,
  start_station_id,
  start_station_name,
  end_station_id,
  end_station_name,
  bike_id,
  user_type
  
FROM {{ source('sf_bike_hire', 'sf_bike_hire_agg') }}
)

SELECT

    DATE(start_time, "PST8PDT") AS date,
    duration_mins,
    DATETIME(start_time, "America/Los_Angeles") as start_time,
    DATETIME(end_time, "America/Los_Angeles") as end_time,
    start_station_id,
    start_station_name,
    end_station_id,
    end_station_name,
    bike_id,
    user_type

FROM bike_hire