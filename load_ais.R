### Loading required packages.
library(rJava)
library(RJDBC)
library(data.table)
library(pipeR)
library( htmltools )

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

# ------------------------------- #


get_vessel_ais <- function(vessel, start_date, end_date) {
    vessel_movement_sql = sprintf("
    with t0 as (
      select vessel, 
      max(date) max_date,
      round(avg(speed), 2) avg_speed,
      round(avg(course), 2) avg_course
      from asvt_position
    --  where vessel = 332
    --  and date between '2017-09-28'::date - interval '5 weeks' and '2017-09-28'::date
       where vessel = %s
       and date between '%s'::date and '%s'::date
      group by vessel, date::date
      )
      
      select a.date, 
             a.lat,
             a.lon,
             a.draught,
             a.destination,
             a.dec_area,
             '<p>Date: '||a.date||'<p></p> Draught: '||a.draught||'<p></p> Dest: '||a.destination||'</p>' map_label
      from asvt_position a
      join t0 b on a.vessel = b.vessel and a.date = b.max_date
      order by a.date
      ", vessel, start_date, end_date)
    
    vessel_movement <- dbGetQuery(conn = prod_base, statement = vessel_movement_sql) %>% as.data.table()
    vessel_movement[, map_label := lapply(map_label, HTML)]
    
    view_center <- vessel_movement[, .('center_lat' = mean(lat), 'center_lon' = mean(lon))]
    
    res_list <- list("vessel_movement_" = vessel_movement,
                     "view_center_" = view_center)
    return(res_list)
    
}

# ais <- get_vessel_ais(332, '2017-08-24', '2017-09-26')

get_poi <- function() {
  poi_sql <- "
        select distinct
               poi,
               coalesce(lat, cd_lat) lat,
               coalesce(lon, cd_lon) lon,
               cd_name,
               cmdty,
               lo_country_code,
               lo_city_code,
               (case 
                   when cmdty ~ '(?i)C|D|F|G|H' then 'Liquid'
                   when cmdty ~ '(?i)R|Q' then 'Bulk'
                   else 'Lintering Zone'
               end) poi_type,
               '<p>'||cd_name||
               '<p></p> POI: '||poi||'    CMDTY: '||cmdty||
               '<p></p>country: '||lo_country_code||'    city: '||lo_city_code||'</p>' poi_label
        from as_poi
        where ((cmdty ~ '(?i)C|D|F|G|H|R|Q') or 
               (type = 'Lightering Zone'))
          and ((lat is not null) or 
               (lon is not null))
  "
  poi <- dbGetQuery(conn = prod_base, statement = poi_sql) %>% as.data.table()
  
  poi[, poi_label := lapply(poi_label, HTML)]
  return(poi)
}


# ---------------------------------------__#
#  base map layer. 
# 
# base_map <- leaflet() %>%
#   addProviderTiles(provider = providers$Esri.WorldStreetMap, group = 'Map (Default)') %>% 
#   addProviderTiles(provider = providers$Esri.WorldImagery, group = 'Satellite') %>%
#   # Layers control
#   addLayersControl(
#     baseGroups = c("Map (Default)", "Satellite"),
#     # overlayGroups = c("Quakes", "Outline"),
#     options = layersControlOptions(collapsed = FALSE))


