library(leaflet)
source('~/Desktop/workdir/Vessel_Tracking/load_ais.R')

poi <- get_poi()

server <- function(input, output, session) {

  
  ## Interactive Map ###########################################
  # put map in the output.
  output$map <- renderLeaflet({
    
    # Create the map
    base_map <- leaflet() %>%
      # base group
      addProviderTiles(provider = providers$Esri.WorldStreetMap, group = 'Map (Default)') %>% 
      addProviderTiles(provider = providers$Esri.WorldImagery, group = 'Satellite') %>%
      # overlay group
      addCircleMarkers(lat = ~ lat,
                       lng = ~ lon,
                       popup = ~ poi_label,
                       data = poi[poi_type != 'Bulk', ],
                       group='Liquid',
                       clusterOptions = TRUE,,
                       stroke = FALSE,
                       fill = TRUE,
                       fillColor = 'blue',
                       fillOpacity = 1,
                       radius = 6) %>%
      addCircleMarkers(lat = ~ lat,
                       lng = ~ lon,
                       popup = ~ poi_label,
                       data = poi[poi_type == 'Bulk'],
                       group='Bulk',
                       clusterOptions = TRUE,,
                       stroke = FALSE,
                       fill = TRUE,
                       fillColor = 'orange',
                       fillOpacity = 1,
                       radius = 6) %>%
      # Layers control
      addLayersControl(
        baseGroups = c("Map (Default)", "Satellite"),
        overlayGroups = c("Liquid", "Bulk"),
        options = layersControlOptions(collapsed = FALSE)) %>%
      hideGroup(c("Liquid", "Bulk")) # hide two overlay layers first
    
    # vessel icon setting
    
    icon_url_list <- list("google" = "https://emojipedia-us.s3.amazonaws.com/thumbs/240/google/119/whale_1f40b.png",
                          "samsung" = "https://emojipedia-us.s3.amazonaws.com/thumbs/120/samsung/128/whale_1f40b.png")
    
    vessel_icon <- makeIcon(
      iconUrl=icon_url_list$samsung,
      iconWidth = 40, iconHeight = 40
    )
    
    # Return the requested dataset -- get vessel AIS signal.
    # By declaring datasetInput as a reactive expression we ensure
    # that:
    #
    # 1. It is only called when the inputs it depends on changes
    # 2. The computation and result are shared by all the callers,
    #    i.e. it only executes a single time
    datasetInput <- reactive({
      # get input from InputBox.
      vessel <- input$vessel
      # start_date <- as.character(input$start_date)
      # end_date <- as.character(input$end_date)
      start_date <- as.character(input$dates[1])
      end_date <- as.character(input$dates[2])
      
      get_vessel_ais(vessel, start_date, end_date)
    })
    
    data_ <- datasetInput()
    vessel_movement <- data_$vessel_movement_
    view_center <- data_$view_center_
    
    # plot vessel movements.
    vessel_movement_line <- base_map %>%
      addPolylines(lat = vessel_movement$lat, 
                   lng = vessel_movement$lon, 
                   color = 'red') %>%
      setView(lat = view_center$center_lat, 
              lng = view_center$center_lon, 
              zoom = 4) %>%
      addMarkers(lat = vessel_movement$lat, 
                 lng = vessel_movement$lon, 
                 icon = vessel_icon,
                 label = vessel_movement$map_label)
    
    vessel_movement_line
    })
}