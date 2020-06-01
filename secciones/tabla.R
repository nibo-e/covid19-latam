# Tabla de datos

library(formattable)
library(scales)

data_tabla <- data_latest_latinos %>%
  select(`Country/Region`, confirmed, recovered, deceased, population) %>%
  mutate(confirmed_norm = round(confirmed/population * 100000, 0)) %>%
  mutate(deceased_norm = round(deceased/population * 100000, 0)) %>%
  rename(País = `Country/Region`, Recuperados = recovered,
         Fallecidos = deceased, Contagiados = confirmed,
         `Contagiados por cada 100 mil hab.` = confirmed_norm,
         `Fallecidos por cada 100 mil hab.` = deceased_norm) %>%
  select(-population, -`Contagiados por cada 100 mil hab.`, -`Fallecidos por cada 100 mil hab.`) %>%
  arrange(-Contagiados)


tabla <- formattable(data_tabla, align = c("l", rep("c", NCOL(data_tabla) - 1)),
                     list(
  Contagiados = color_tile("white", "#F16B6F"),
  #`Contagiados por cada 100 mil hab.` = color_tile("white", "#F16B6F"),
  Fallecidos  = color_tile("white", "#F16B6F"),
  #`Fallecidos por cada 100 mil hab.` = color_tile("white", "#F16B6F"),
  Recuperados = color_tile("white", "#77AAAD")
  
  
))


output$tabla <- renderFormattable(tabla)