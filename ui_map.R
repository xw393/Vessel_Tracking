library(leaflet)

# absolute panel: vessel input
vessel_input <- numericInput("vessel", label = "Vessel Id", value = 332)
# absolute panel: date input
date_input <- dateRangeInput("dates", label = "Date Range", start = '2017-08-23', end = '2017-09-28')
# start_date_input <- dateInput(inputId = 'start_date', label = 'Start Date', value = '2017-08-23')
# end_date_input <- dateInput(inputId = 'end_date', label = 'End Date', value = '2017-09-28')

# absolute panel: other input: display dec_area, poi
other_layer <- checkboxGroupInput("check_group", 
                                  label = "Other Layers", 
                                  choices = list("poi" = 1, "dec_area" = 2))

ui <- navbarPage("Superzip", id="nav",

  tabPanel("Interactive map",
    div(class="outer",

      tags$head(
        # Include our custom CSS
        includeCSS("styles.css"),
        includeScript("gomap.js")
      ),

      # If not using custom CSS, set height of leafletOutput to a number instead of percent
      leafletOutput("map", width="100%", height="100%"),

      # Shiny versions prior to 0.11 should use class = "modal" instead.
      absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
        draggable = TRUE, top = 100, left = 50, right = "auto", bottom = "auto",
        width = 330, height = 500,
        # panel title.
        h2("Vessel Movement"),
        vessel_input,
        date_input,
        # start_date_input,
        # end_date_input,
        submitButton("Submit"),
        other_layer
        # add plots within the panel.
        # plotOutput("histCentile", height = 200),
        # plotOutput("scatterCollegeIncome", height = 250)
      ),

      tags$div(id="cite",
        'Data compiled for ', tags$em('Coming Apart: The State of White America, 1960–2010'), ' by Charles Murray (Crown Forum, 2012).'
      )
    )
  ),

  conditionalPanel("false", icon("crosshair"))
)
