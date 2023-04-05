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