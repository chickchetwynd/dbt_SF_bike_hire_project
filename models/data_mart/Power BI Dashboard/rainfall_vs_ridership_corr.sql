SELECT

  ROUND(corr(num_of_rides, avg_rain), 2) as corr_rain_ridership,
  ROUND(corr(num_of_rides, avg_temp), 2) as corr_temp_ridership

FROM {{ ref("rainfall_vs_ridership") }}