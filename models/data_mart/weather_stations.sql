SELECT DISTINCT station, name
 FROM {{source('sf_bike_hire', 'sf_weather') }}