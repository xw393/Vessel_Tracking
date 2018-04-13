### Loading required packages.
library(rJava)
library(RJDBC)
library(data.table)
library(pipeR)

options(stringsAsFactors = FALSE)
# setwd('/home/CL_US_Crude_Prod/us_crude_prod')
setwd('/home/infinitecycle/Desktop/GoogleDrive/Programming/loading_forecast/')

source("getDBInfo.R")
## Set the driver of the PostgreSQL, the driver file (postgresql-9.4.1207.jar) must be downloaded first.
pgsql <- JDBC("org.postgresql.Driver", "postgresql-9.4.1207.jar", "`")

## Establish the connection with Database Prod!

Prod_DB <- getDBInfo('read_write')
prod_base <- dbConnect(pgsql, url = Prod_DB$PROD_URL,
                       user = Prod_DB$PROD_USERNAME,
                       password = Prod_DB$PROD_PASSWORD)

vessel_movement_sql = """
with t0 as (
select vessel, 
       max(date) max_date,
       round(avg(speed), 2) avg_speed,
       round(avg(course), 2) avg_course
from asvt_position
where vessel = 332
  and date between '2017-09-28'::date - interval '5 weeks' and '2017-09-28'::date
group by vessel, date::date
)

select a.vessel,
       a.date,
       a.lat,
       a.lon,
       a.course,
       b.avg_course,
       b.avg_speed,
       a.dec_area,
       a.destination
from asvt_position a
join t0 b on a.vessel = b.vessel and a.date = b.max_date
order by a.date
"""