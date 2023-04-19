# DBT tutorial- San Francisco Bay Wheels 

<p align="center">
<img width="100" alt="Screenshot 2023-04-19 at 8 41 59 AM" src="https://user-images.githubusercontent.com/121225842/233128684-bbb3f657-aecc-4bc4-ab4e-04cb099cf679.png">  <img width="550" alt="Screenshot 2023-04-19 at 8 45 53 AM" src="https://user-images.githubusercontent.com/121225842/233129736-01a9f83a-14f7-4bb2-9aca-87216effb2d2.png">  <img width="220" alt="Screenshot 2023-04-19 at 8 46 06 AM" src="https://user-images.githubusercontent.com/121225842/233129764-4b16425d-1933-457a-abea-8d57e3210642.png">
</p>

### Project Goal/Setup

The main goal of this project was to learn how to use DBT to model and transform data stored in a cloud data platform. The data that I used was from the bicycle hire company Bay Wheels, who make a lot of their data [publicly available](https://www.lyft.com/bikes/bay-wheels/system-data). I also used adjacent data from the [NOAA](https://www.ncdc.noaa.gov/cdo-web/search) that represented raw data from Bay Area weather stations. I did some basic analysis of this data in a separate [project](https://github.com/chickchetwynd/Holistics-Project), the goal of this project was to develop a DBT workflow and leverage some of the basics tools that it has such as __modular SQL, tests, and documentation__. All of the project files are available in this repo.

I developed the majority of code on DBT Cloud but once finished, I cloned this repo to be able to develop on my local machine using DBT Core in which I used Pycharm as my IDE.


### Schema

<img width="1368" alt="Screenshot 2023-04-19 at 9 07 52 AM" src="https://user-images.githubusercontent.com/121225842/233135349-0cc01ba4-6bcb-447c-9af6-abbec92c20ba.png">

Above is the [DAG](https://en.wikipedia.org/wiki/Directed_acyclic_graph) representing the final modeled data. The graph has a few stages from left to right: Sources, Staging models, and Mart models.


#### Sources

The raw data was stored in a project in the data warehouse Big Query. I created a second project in Big Query (and gave it access to the raw data project) for the clean modeled data to be sent to. This involved creating service accounts as well as .json access keys that allow DBT and the data platform to link together. DBT have some great [resources](https://www.youtube.com/watch?v=ptkcjy4c-0g&t=4s) to help configure this. Once connected, in DBT you use __.yml__ files to configure the data __source__:

```yml
version: 2

sources:
  - name: sf_bike_hire
    database: sf-bike-hire
    schema: sf_bike_hire
    tables:
      - name: sf_bike_hire_agg
      - name: sf_weather
```

__note__: The data in this project is static so some of the functionality of DBT is a little over kill. But the point of this project is to learn these skills in a safe environment!

#### Staging Models

Once sources are configured, you can write modular SQL queries to start to model the data:

```SQL
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
```

In the __FROM__ clause, the query references the source as defined by the [.yml](https://github.com/chickchetwynd/dbt_SF_bike_hire_project/blob/main/models/source/source.yml) file. Now if the source changes, the SQL code doesn't also need to change preventing extra work 'down stream'.

<br>

Staging models are where the data transforms from raw to a basic level of organization. From these staging models we can create __mart__ models that further aggregate the data and start to form useful representations of the data.

#### Mart Models

[Mart Models](https://github.com/chickchetwynd/dbt_SF_bike_hire_project/tree/main/models/data_mart) represent data in a ready to use format that could be loaded into a BI tool, for example. let's look at a SQL query for one of these models:

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

This query creates a hypothetical model which reperesents data showing when each individual bike needs maintenance and the current location of the bike. I created a [further model](https://github.com/chickchetwynd/dbt_SF_bike_hire_project/blob/main/models/data_mart/maintenance_work_orders.sql) which could be used as a database of __workorders__ for whoever maintains Bay Wheels bikes:

<img width="1039" alt="Screenshot 2023-04-19 at 9 53 19 AM" src="https://user-images.githubusercontent.com/121225842/233145938-43811411-3f7f-4752-9b56-ae5f722b1f77.png">

This section of the DAG categorizes bikes based on the total amout of time they have been ridden and organizes individual bikes into maintenance 'status' groups. The bikes that have been ridden the longest get put into work orders first!

#### .yml
