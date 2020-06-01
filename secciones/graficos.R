# Gráficos

library(tidyverse)
library(hrbrthemes)
library(ggrepel)
library(plotly)
library(ggflags)
library(reshape2)
library(directlabels)
library(packcircles)

# Data transformation
data_latest_latinos_melt <- data_latest_latinos %>%
  mutate(`Confirmados (por 100.000 hab.)` = confirmed/population * 100000,
         `Fallecidos (por 100.000 hab.)` = deceased/population * 100000) %>%
  select(país = `Country/Region`, `Confirmados (por 100.000 hab.)`, `Fallecidos (por 100.000 hab.)`) %>%
  melt(id.vars ="país")
  

# Gráfico 1 - barras normalizadas por 100.000 hab. ####
output$seleccionar_var <- renderUI({
  selectizeInput(
    "seleccionar_var",
    label    = "Seleccionar variable",
    choices  = list("Contagiados" = "confirmed", "Fallecidos" = "deceased"),
    multiple = FALSE,
    selected = "confirmed"
  )
})


graf1_barras_conf <- ggplot(data_latest_latinos_melt[data_latest_latinos_melt$variable == "Confirmados (por 100.000 hab.)",],
                            aes(x = reorder(país, value), y = value,
                                                     text = paste0(país,
                                                                  '<br>', round(value, 0)
                                                                  ))) +
  coord_flip() +
  theme_ipsum_rc(subtitle_family = "Roboto Condensed") +
  theme(
    panel.grid.minor = element_blank(),
    # panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    plot.margin = margin(3,4,3,3,"mm"),
    legend.position = "none"
  ) +
  geom_bar(stat = "identity", colour = "#FFFFFF00", fill = "#8F2D56")

graf1_barras_fall <- ggplot(data_latest_latinos_melt[data_latest_latinos_melt$variable == "Fallecidos (por 100.000 hab.)",],
                            aes(x = reorder(país, value), y = value,
                                                          text = paste0(país,
                                                                        '<br>', round(value, 0)
                                                          ))) +
  coord_flip() +
  theme_ipsum_rc(subtitle_family = "Roboto Condensed") +
  theme(
    panel.grid.minor = element_blank(),
    # panel.grid.major.x = element_blank(),
    panel.grid.major.y = element_blank(),
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    plot.margin = margin(3,4,3,3,"mm"),
    legend.position = "none"
  ) +
  geom_bar(stat = "identity", colour = "#FFFFFF00", fill = "#D81159")


output$grafico1 <- renderPlotly({
  req(input$seleccionar_var)
  
  if (input$seleccionar_var == "confirmed") {
    graf1 <- graf1_barras_conf %>%
    ggplotly(tooltip = "text", dynamicTicks = F) %>% config(displayModeBar = F)
    
  } else {
    graf1 <- graf1_barras_fall %>%
    ggplotly(tooltip = "text", dynamicTicks = F) %>% config(displayModeBar = F)
    
    
  }
  
  graf1
  
  })


# Gráfico 2 - evoluución de casos confirmados ####

breaks=c(100, 1000, 10000, 1e5, 5e5, 1000000, 2000000, 5000000)
minor_breaks <- rep(1:9, 21)*(10^rep(-10:10, each=9))

data_confirmed_sub_latinos_hoy <- data_confirmed_sub_latinos[data_confirmed_sub_latinos$fecha == current_date,]

graf2_evocasos <- ggplot(data_confirmed_sub_latinos, aes(days_since_100, confirmed, 
                                                         color = `Country/Region`,
                                                         text = confirmed)) +
  geom_line(size = 1) +
  # geom_point(data = dd_today, pch = 21, aes(size = cum_dead)) +
  # stat_function(fun=dup2dias, geom="line", linetype=3, colour = "grey80") + # Duplica cada dos días
  # stat_function(fun=dup3dias, geom="line", linetype=3, colour = "grey80") + # Duplica cada tres días
  # stat_function(fun=dup7dias, geom="line", linetype=3, colour = "grey80") + # Duplica cada tres días
  # scale_size(name = "Total \nfallecidos") +
  coord_trans(y = 'log10') +
  scale_y_continuous(breaks = breaks, 
                     labels = comma_format(breaks, big.mark = ".", decimal.mark = ","),
                     minor_breaks = minor_breaks) +
  # scale_x_continuous(expand = expansion(add = c(0,1))) +
  # coord_trans(y = 'log10') +#, ylim= c(100, dd_max_confirm)) +
  # scale_y_continuous(breaks = breaks, 
  #                    labels = comma_format(breaks, big.mark = ".", decimal.mark = ","),
  #                    minor_breaks = minor_breaks) +
  theme_ipsum_rc(subtitle_family = "Roboto Condensed") +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.position = "bottom",
    plot.margin = margin(3,4,3,3,"mm"),
    panel.grid.minor.y = element_line(color="grey80"),
    axis.title.x = element_text(size=16),
    axis.title.y = element_text(size=16)
  ) +
  guides(colour=FALSE) +
  # geom_dl(aes(label = `Country/Region`), method="last.points") +
  geom_text_repel(data = data_confirmed_sub_latinos_hoy, aes(label = `Country/Region`), size = 5,
                  family = "Roboto Condensed", force = 2, bg.color = "#FFFFFF",
                  segment.color = "grey80") +
  # geom_point(data = etiquetas_curvas, aes(x = x, y = y), colour = "#FFFFFF00") +
  # geom_text_repel(data = etiquetas_curvas, aes(x = x, y = y, label = etiq),
  #                 colour = "grey80", size = 3, point.padding = 0, force = 1,
  #                 family = "Roboto Condensed", bg.color = "#252a32") +
  labs(x = "Número de días desde el caso 100", y = "Casos confirmados (Escala logarítmica)")

# output$grafico2 <- renderPlotly({graf2_evocasos %>%
#   ggplotly(tooltip = "text", legend = list(orientation = 'h')) %>% config(displayModeBar = F)
# })

output$grafico2 <- renderPlot({graf2_evocasos})

# Grafico 3 - Casos en la última semana ####

breaks_2 <- c(0, 25, 50, 75, 100, 125, 150, 175, 200)

graf3_semana <- ggplot(data_nuevos_cont, aes(infectados_semana, 
                                             reorder(país, infectados_semana),
                                             text = paste0(país,
                                                           '<br>', round(infectados_semana, 0)))) +
  theme_ipsum_rc(subtitle_family = "Roboto Condensed") +
  theme(
    panel.grid.minor = element_blank(),
    panel.grid.major.x = element_blank(),
    legend.position = "bottom",
    axis.title.y = element_blank(),
    plot.margin = margin(3,4,3,3,"mm"),
    panel.grid.minor.y = element_line(color="grey30")
  ) +
  scale_x_continuous(breaks = breaks_2, labels = breaks_2) +
  xlab("No. de infectados por 100.000 hab. en los últimos 7 días") +
  guides(colour=FALSE) +
  geom_vline(aes(xintercept = 50), linetype = "dashed") +
  geom_bar(stat = "identity", colour = "#FFFFFF00", fill = "#8F2D56", width = 0.2) +
  geom_point(size = 4, color = "#8F2D56")

output$grafico3 <- renderPlotly({graf3_semana %>%
    ggplotly(tooltip = "text") %>% config(displayModeBar = F)
})