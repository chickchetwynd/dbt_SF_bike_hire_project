SELECT
*
FROM {{ ref('agg_per_day') }}
WHERE avg_rain < 0