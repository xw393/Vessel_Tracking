library(shiny)
library(rjson)

work_dir_config = fromJSON(file = "~/Desktop/workdir/Vessel_Tracking/configuration.json")

setwd(work_dir_config$thinkpad_p51$work_dir)

source('ui_map.R')
source('server_map.R')

## ---------------------------------- ##

shinyApp(ui, server)
