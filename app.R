library(shiny)

setwd('~/Desktop/test_proj/map/')
source('ui_map.R')
source('server_map.R')

## ---------------------------------- ##

shinyApp(ui, server)
