library(shiny)
library(rjson)

# work_dir_config = fromJSON(file = "~/Desktop/workdir/Vessel_Tracking/configuration.json")

work_dir = "~/Desktop/test_proj/map/Vessel_Tracking/" 
setwd(work_dir)

source('ui_map.R')
source('server_map.R')

## ---------------------------------- ##

shinyApp(ui, server)
