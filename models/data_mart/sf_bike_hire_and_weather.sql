SELECT *

FROM {{ ref('stg_sf_bike_hire') }} INNER JOIN {{ ref('stg_sf_weather') }}
USING (date)