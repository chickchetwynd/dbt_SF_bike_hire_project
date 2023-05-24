SELECT

  rainfall_category,
  user_type,
  COUNT(ride_id) AS number_of_rides

FROM {{ ref("sf_bike_hire_and_weather") }}

GROUP BY rainfall_category, user_type