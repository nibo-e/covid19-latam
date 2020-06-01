library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    # From chschoenenberger ####
    sourceDirectory("secciones", recursive = TRUE)
    
    # Trigger once an hour
    dataLoadingTrigger <- reactiveTimer(3600000)
    
    observeEvent(dataLoadingTrigger, {
        updateData()
    })
    
    observe({
        data <- data_atDate(input$timeSlider)
    })
    
    
    
    # Viejo ####
    
    #creating the valueBoxOutput content
    output$value1 <- renderValueBox({
        valueBox(
            formatC(sum(na.omit(data_latest$confirmed)), format="d", big.mark='.', decimal.mark = ",")
            ,paste('Casos confirmados en el mundo')
            ,icon = icon("globe-americas")
            ,color = "purple")
        
        
    })
    
    
    
    output$value2 <- renderValueBox({
        
        valueBox(
            formatC(sum(na.omit(data_latest_latinos$confirmed)), format="d", big.mark='.', decimal.mark = ",")
            ,'Casos confirmados en América Latina'
            ,icon = icon("map-marked")
            ,color = "purple")
        
    })
    
    
    
    output$value3 <- renderValueBox({
        
        valueBox(
            formatC(sum(na.omit(data_latest_latinos$deceased)), format="d", big.mark='.', decimal.mark = ",")
            ,paste('Fallecimientos en América Latina')
            ,icon = icon("heartbeat")
            ,color = "red")
        
    })
    
    data <- reactive({
        x <- casos
    }) 
 
    



})
