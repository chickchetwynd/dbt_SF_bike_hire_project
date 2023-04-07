SELECT

  bike_id,
  ROUND(SUM(duration_mins), 0) as total_ride_time

FROM {{ ref('stg_sf_bike_hire') }}

GROUP BY bike_id

ORDER BY total_ride_time DESC