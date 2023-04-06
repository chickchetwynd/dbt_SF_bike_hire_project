{% docs units %}

| Column        | Units                                       |
|---------------|---------------------------------------------|
| Duration_mins | minutes (decimal does not indicate seconds) |
| avg_rain      | mm                                          |
| avg_temp      | mm                                          |
| max_temp      | mm                                          |
| min_temp      | mm                                          |

{% enddocs %}

{% docs rainfall %}

| Rainfall Category | Avd Daily Rainfall (in mm) |
|-------------------|----------------------------|
| Low               | < 2.5                      |
| Moderate          | >= 2.5 AND < 10            |
| High              | > 10                       |

{% enddocs %}


{% docs maintenance_schedule %}

| Category                  | Total ride time (mins) |
|---------------------------|------------------------|
| Urgent maintenance needed | >= 15000               |
| Maintenance needed        | >= 10000               |
| Maintenance soon          | >= 7000                |
| Riding sweet              | < 7000                 |

{% enddocs %}