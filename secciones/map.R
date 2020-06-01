library("htmltools")

addLabel <- function(data) {
  data$label <- paste0(
    '<b>', ifelse(is.na(data$`Province/State`), data$`Country/Region`, data$`Province/State`), '</b><br>
    <table style="width:120px;">
    <tr><td>Confirmados:</td><td align="right">', data$confirmed, '</td></tr>
    <tr><td>Fallecidos:</td><td align="right">', data$deceased, '</td></tr>
    <tr><td>Recuperados (estimados):</td><td align="right">', data$recovered, '</td></tr>
    <tr><td>Activos:</td><td align="right">', data$active, '</td></tr>
    </table>'
  )
  data$label <- lapply(data$label, HTML)
  
  return(data)
}

map <- leaflet(addLabel(data_latest),
               options = leafletOptions(minZoom = 3, maxZoom = 8)) %>%
  setMaxBounds(-180, -90, 180, 90) %>%
  setView(-75, -15, zoom = 3) %>%
  addTiles() %>%
  addProviderTiles(providers$CartoDB.Positron, group = "Ligero") %>%
  addProviderTiles(providers$HERE.satelliteDay, group = "Satelital") %>%
  addLayersControl(
    baseGroups    = c("Ligero", "Satelital"),
    overlayGroups = c("Confirmados", "Confirmados (per cápita)", "Recuperados (estimados)", 
                      "Fallecidos", "Activos", "Activos (per cápita)")
  ) %>%
  hideGroup("Confirmados (per cápita)") %>%
  hideGroup("Recuperados (estimados)") %>%
  hideGroup("Fallecidos") %>%
  hideGroup("Activos") %>%
  hideGroup("Activos (per cápita)") %>%
  addEasyButton(easyButton(
    icon    = "glyphicon glyphicon-globe", title = "Reiniciar zoom",
    onClick = JS("function(btn, map){ map.setView([20, 0], 2); }"))) %>%
  addEasyButton(easyButton(
    icon    = "glyphicon glyphicon-map-marker", title = "Mi ubicación",
    onClick = JS("function(btn, map){ map.locate({setView: true, maxZoom: 6}); }")))

observe({
  req(input$overview_map_zoom)
  zoomLevel               <- input$overview_map_zoom
  data                    <- data_latest %>% addLabel()
  data$confirmedPerCapita <- data$confirmed / data$population * 100000
  data$activePerCapita    <- data$active / data$population * 100000

  leafletProxy("overview_map", data = data) %>%
    clearMarkers() %>%
    addCircleMarkers(
      lng          = ~Long,
      lat          = ~Lat,
      radius       = ~log(confirmed^(zoomLevel / 2)),
      stroke       = FALSE,
      fillOpacity  = 0.6,
      label        = ~label,
      color        = "#54546c",
      labelOptions = labelOptions(textsize = 15),
      group        = "Confirmados"
    ) %>%
    addCircleMarkers(
      lng          = ~Long,
      lat          = ~Lat,
      radius       = ~log(confirmedPerCapita^(zoomLevel)),
      stroke       = FALSE,
      color        = "#8283a7",
      fillOpacity  = 0.7,
      label        = ~label,
      labelOptions = labelOptions(textsize = 15),
      group        = "Confirmados (per cápita)"
    ) %>%
    addCircleMarkers(
      lng          = ~Long,
      lat          = ~Lat,
      radius       = ~log(recovered^(zoomLevel / 2)),
      stroke       = FALSE,
      color        = "#a5d296",
      fillOpacity  = 0.7,
      label        = ~label,
      labelOptions = labelOptions(textsize = 15),
      group = "Recuperados (estimados)"
    ) %>%
    addCircleMarkers(
      lng          = ~Long,
      lat          = ~Lat,
      radius       = ~log(deceased^(zoomLevel / 2)),
      stroke       = FALSE,
      color        = "#ff7761",
      fillOpacity  = 0.7,
      label        = ~label,
      labelOptions = labelOptions(textsize = 15),
      group        = "Fallecidos"
    ) %>%
    addCircleMarkers(
      lng          = ~Long,
      lat          = ~Lat,
      radius       = ~log(active^(zoomLevel / 2)),
      stroke       = FALSE,
      color        = "#f9a11b",
      fillOpacity  = 0.7,
      label        = ~label,
      labelOptions = labelOptions(textsize = 15),
      group        = "Activos"
    ) %>%
    addCircleMarkers(
      lng          = ~Long,
      lat          = ~Lat,
      radius       = ~log(activePerCapita^(zoomLevel)),
      stroke       = FALSE,
      color        = "#fdc23e",
      fillOpacity  = 0.7,
      label        = ~label,
      labelOptions = labelOptions(textsize = 15),
      group        = "Activos (per cápita)"
    )
})



output$overview_map <- renderLeaflet(map)