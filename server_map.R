library(leaflet)

# Create the map
map_ <- leaflet() %>%
        addProviderTiles(provider = providers$Esri.WorldStreetMap, group = 'Map (Default)') %>% 
        addProviderTiles(provider = providers$Esri.WorldImagery, group = 'Satellite') %>%
        setView(lng = -93.85, lat = 37.45, zoom = 4) %>%
        # Layers control
        addLayersControl(
          baseGroups = c("Map (Default)", "Satellite'"),
          # overlayGroups = c("Quakes", "Outline"),
          options = layersControlOptions(collapsed = FALSE))
  


server <- function(input, output, session) {
  ## Interactive Map ###########################################
  # put map in the output.
  output$map <- renderLeaflet({
    map_})
}

# leaflet() %>%
#   addTiles(
#     urlTemplate = "//{s}.tiles.mapbox.com/v3/jcheng.map-5ebohr46/{z}/{x}/{y}.png",
#     attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>'
#   ) %>%
#   setView(lng = -93.85, lat = 37.45, zoom = 4)
