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

