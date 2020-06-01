title <- tags$p(tags$a("Situación COVID-19 - América Latina", style = "text-align: center; padding-left: 5px",))


ui <- fluidPage(

  # paste0("Datos actualizados al ", fecha),
  
  # br(), br(), br(),
  
  dashboardPage(skin = "green",
                
    
    dashboardHeader(title = "Situación COVID-19 | América Latina", titleWidth = 600,
                    tags$li("", class = "dropdown",
                            tags$a("", href = "https://niboe.info", tags$img(src = "logo2.png", height = "17", width = "56"))),
                    tags$li(class = "dropdown", tags$a(href="https://twitter.com/nibo_e",
                            icon("twitter"), "", target = "_blank")),
                    tags$li(class = "dropdown", tags$a(href="https://fb.com/niboe.info",
                            icon("facebook"), "", target = "_blank")),
                    tags$li(class = "dropdown", tags$a(href="https://instagram.com/niboe.info",
                            icon("instagram"), "", target = "_blank")),
                    tags$li(class = "dropdown", tags$a(href="https://t.me/niboe",
                            icon("send", lib="glyphicon"), "", target = "_blank"))
    ),
    
    
    dashboardSidebar(
      # width = 350,
      collapsed = TRUE,
      sidebarMenu(
        menuItem("Situación COVID-19", tabName = "dashboard", icon = icon("dashboard")),
        menuItem("nibö sobre COVID-19", icon = icon("youtube"), 
                 href = "https://www.youtube.com/watch?v=E5y7uNM6lJk&list=PLk5uEC-KU-l3GD61svvAS67-vftaT_bH9"),
        menuItem("Sobre estos datos", icon = icon("file-alt"), 
                 href = "https://niboe.info/blog/datos-reporte-covid-19/")
        
        
      )



    ),
    
    dashboardBody(
      tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")),
      
        frow1 <- box(
          fluidRow(
            valueBoxOutput("value1")
            ,valueBoxOutput("value2")
            ,valueBoxOutput("value3"),
            width = 12
          ),
      div("Última actualización: ", strftime(changed_date, format = "%d/%m/%Y - %R %Z", tz = "CMT")),
      width = 12
        ),
      
      # leafletOutput("overview_map", height = 1000), # Nuevo mapa
      
      fluidRow(
        class = "details",
        column(
          box(
            # status = "success",
            width = 12,
            solidHeader = FALSE,
            leafletOutput("overview_map", height = 672)
          ),
          class = "map",
          width = 8,
          style = 'padding:0px;'
        ),
        column(
          box(
            # status = "success",
            # background = "maroon",
            width = 12,
            formattableOutput("tabla")
            ),
          class = "summary",
          width = 4,
          style = 'padding:0px;'
          
        )
      ),
      
      fluidRow(
        class = "details",
          box(
            title = "Contagiados y fallecidos por cada 100.000 habitantes",
            # status = "warning",
            width = 4,
            solidHeader = FALSE,
            fluidRow(
              column(
                uiOutput("seleccionar_var"),
                width = 6,
              )),
            plotlyOutput("grafico1")
            
          ),
          box(
            title = "Evolución de casos",
            width = 4,
            solidHeader = FALSE,
            # plotlyOutput("grafico2")
            plotOutput("grafico2")
          ),
        box(
          title = "Contagios por cada 100.000 hab. en la última semana",
          width = 4,
          solidHeader = FALSE,
          footer = "Línea punteada indica 50 casos por cada 100.000 habitantes en los últimos 7 días. Valor considerado en muchos países como criterio para aplicar medidas de confinamiento.",
          plotlyOutput("grafico3")
        )
      )
    
    ))
    
  
  
)



