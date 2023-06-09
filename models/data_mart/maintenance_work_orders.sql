select

    row_number() over () as work_order_number,
    current_station_id,
    current_station_name,
    bike_id,
    status,
    current_station_latitude,
    current_station_longitude

from {{ ref("bike_maintenance_schedule") }}

where status like '%Urgent maintenance needed%'
    OR status LIKE '%Maintenance needed%'
order by current_station_id asc
