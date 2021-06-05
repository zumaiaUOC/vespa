
# Limpiamos el workspace, por si hubiera algun dataset o informacion cargada
#rm(list = ls())

# Limpiamos la consola
#cat("\014")

# Librerias

#packages <- c("readr","shiny", "tidyverse", "shinydashboard", "magrittr", "DT",
#              "leaflet", "countrycode", "plotly","forcats", "r2d3")
#new <- packages[!(packages %in% installed.packages()[,"Package"])]
#if(length(new)) install.packages(new)
#a=lapply(packages, require, character.only=TRUE)


library(readr)
library(shiny)
library(tidyverse)
library(shinydashboard)
library(DT)
library(magrittr)
library(leaflet)
library(countrycode)
library(plotly)
library(forcats)
library(r2d3)

# Leemos los ficheros
nido <- read_csv("data/data_nido.csv", 
                 col_types = cols(X1 = col_skip(),
                                  id = col_skip(),
                                  x = col_skip(), 
                                  y = col_skip()))


weather <- read_csv("data/weather.csv", 
                    col_types = cols(X1 = col_skip()))%>%
  select(-codigo, -año, -mes, -latitude, -longitude)


# distinguimos variables "a nivel de intervalo" ("continuas" para ggplot)
nums <- sapply(weather, is.numeric)
continuas <- names(weather)[nums]

# y variables "categóricas" ("discretas" para ggplot)
cats <- sapply(weather, is.character)
categoricas <- names(weather)[cats]

# D3 code inside an R character variable
r2d3_script <- "
// !preview r2d3 data= data.frame(y = 0.1, ylabel = '1%', fill = '#E69F00', mouseover = 'green', label = 'one', id = 1)
function svg_height() {return parseInt(svg.style('height'))}
function svg_width()  {return parseInt(svg.style('width'))}
function col_top()  {return svg_height() * 0.05; }
function col_left() {return svg_width()  * 0.20; }
function actual_max() {return d3.max(data, function (d) {return d.y; }); }
function col_width()  {return (svg_width() / actual_max()) * 0.55; }
function col_heigth() {return svg_height() / data.length * 0.95; }

var bars = svg.selectAll('rect').data(data);
bars.enter().append('rect')
    .attr('x',      col_left())
    .attr('y',      function(d, i) { return i * col_heigth() + col_top(); })
    .attr('width',  function(d) { return d.y * col_width(); })
    .attr('height', col_heigth() * 0.9)
    .attr('fill',   function(d) {return d.fill; })
    .attr('id',     function(d) {return (d.label); })
    .on('click', function(){
      Shiny.setInputValue('bar_clicked', d3.select(this).attr('id'), {priority: 'event'});
    })
    .on('mouseover', function(){
      d3.select(this).attr('fill', function(d) {return d.mouseover; });
    })
    .on('mouseout', function(){
      d3.select(this).attr('fill', function(d) {return d.fill; });
    });
bars.transition()
  .duration(500)
    .attr('x',      col_left())
    .attr('y',      function(d, i) { return i * col_heigth() + col_top(); })
    .attr('width',  function(d) { return d.y * col_width(); })
    .attr('height', col_heigth() * 0.9)
    .attr('fill',   function(d) {return d.fill; })
    .attr('id',     function(d) {return d.label; });
bars.exit().remove();

// Identity labels
var txt = svg.selectAll('text').data(data);
txt.enter().append('text')
    .attr('x', width * 0.01)
    .attr('y', function(d, i) { return i * col_heigth() + (col_heigth() / 2) + col_top(); })
    .text(function(d) {return d.label; })
    .style('font-family', 'sans-serif');
txt.transition()
    .duration(1000)
    .attr('x', width * 0.01)
    .attr('y', function(d, i) { return i * col_heigth() + (col_heigth() / 2) + col_top(); })
    .text(function(d) {return d.label; });
txt.exit().remove();

// Numeric labels
var totals = svg.selectAll().data(data);
totals.enter().append('text')
    .attr('x', function(d) { return ((d.y * col_width()) + col_left()) * 1.01; })
    .attr('y', function(d, i) { return i * col_heigth() + (col_heigth() / 2) + col_top(); })
    .style('font-family', 'sans-serif')
    .text(function(d) {return d.ylabel; });
totals.transition()
    .duration(1000)
    .attr('x', function(d) { return ((d.y * col_width()) + col_left()) * 1.01; })
    .attr('y', function(d, i) { return i * col_heigth() + (col_heigth() / 2) + col_top(); })
    .attr('d', function(d) { return d.x; })
    .text(function(d) {return d.ylabel; });
totals.exit().remove();
"

r2d3_file <- tempfile()
writeLines(r2d3_script, r2d3_file)


ui = dashboardPage(
  dashboardHeader(title="Vespa Vetulina", tags$li(class = "dropdown",
                                                  tags$p("Oscar Rojo Martín")
  )),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Inicio", tabName = "inicio"),
      menuItem("Mapa Avispas", tabName = "map", icon=icon("map")),
      menuItem("Barplot + table", tabName = "data", icon=icon("dashboard"))
    )
  ),
  dashboardBody(
    
    tabItems(
      
      tabItem(tabName = "inicio",
              fluidPage(
                div(h3(tags$i("La Avispa Asiatica en Bizkaia    2018-2019")), style="vertical-align: middle; text-align:center;"),
                HTML('<center><img src="banner_vespas.jpg" width="700"></center>'),
                tags$br(),
                div(tags$b("Bienvenidos"), style="text-align:center "),
                tags$br(),
                
                tags$hr(),
                div(h5(tags$i("Creado con",
                              tags$img(src = "https://www.rstudio.com/wp-content/uploads/2016/09/RStudio-Logo-Blue-Gray-250.png", 
                                       width = "100px")),tags$i("    _      _       _                     Origen de datos", 
                                                                tags$img(src = "https://kopuru.com/wp-content/uploads/2017/07/kopuru-black.png", 
                                                                         href="https://kopuru.com/desafio/vespa-velutina/", 
                                                                         width = "100px"))), 
                    style="vertical-align: middle; text-align:center;")
              )
      ),
      
      
      tabItem(tabName = "data",
              fluidPage(
                
                # Application title
                titlePanel("Panel control avispas"),
                
                selectInput("var", "Variable",
                            list("año", "mes" , "municipio", "especie", "usuario", "estado", "agente"),
                            selected = "año"),
                d3Output("d3"),
                DT::dataTableOutput("table"),
                textInput("val", "Value", "2019")
              )
              
      ),
      

      
      tabItem(tabName = "map",
              fluidPage(
                titlePanel("Mapa de nidos de Avispas Asiaticas"),
                sidebarPanel(
                  selectInput("año", "Selecciona el año", nido$año, multiple = TRUE),
                  selectInput("mes", "Selecciona el mes", nido$mes, multiple = TRUE),
                  selectInput("agente", "Selecciona el agente", nido$agente, multiple = TRUE),
                  tags$hr()
                ),
                mainPanel(leafletOutput("mymap",height = 500),
                          DT::dataTableOutput("table1"),
                )
              )
      )
    ),
    
    tags$head(
      tags$img(src='Vespa_velutina.jpg',height='70',width='140'),
      tags$style(HTML('
        /* logo */
        .skin-blue .main-header .logo {
                              background-color: #ff7033;
                              color: #4c4c4c;
                              
                              }

        /* logo when hovered */
        .skin-blue .main-header .logo:hover {
                              background-color: #ff7033;
                              }

        /* navbar (rest of the header) */
        .skin-blue .main-header .navbar {
                              background-color: #ff7033;
                              }        

        /* main sidebar */
        .skin-blue .main-sidebar {
                              background-color: #ff7033;
                              }

        /* active selected tab in the sidebarmenu */
        .skin-blue .main-sidebar .sidebar .sidebar-menu .active a{
                              background-color: #ff7033;
                              }

        /* other links in the sidebarmenu */
        .skin-blue .main-sidebar .sidebar .sidebar-menu a{
                              background-color: #ff7033;
                              color: #4c4c4c;
                              }

        /* other links in the sidebarmenu when hovered */
         .skin-blue .main-sidebar .sidebar .sidebar-menu a:hover{
                              background-color: #ff4e33;
                              }
        /* toggle button when hovered  */                    
         .skin-blue .main-header .navbar .sidebar-toggle:hover{
                              background-color: #ff4e33;
                              }
                    '))
    )
    
    
  ))


server = function(input, output, session) {
  
  
  
  
  filtered_data <- reactive({
    nido %>%
      filter(año %in% input$año)%>%
      filter(mes %in% input$mes)%>%
      filter(agente %in% input$agente)
  })
  
  output$mymap <- renderLeaflet({
    leaflet() %>% 
      addTiles() %>% 
      addMarkers(lng=-2.9334110, lat=43.2603479, popup="Bilbao")%>%
      addAwesomeMarkers(data = filtered_data(),
                        lat = ~ latitude,
                        lng = ~ longitude)%>% 
      setView(-2.9334110, 43.2603479, zoom = 10)%>%
      addProviderTiles("Esri.WorldImagery")
  }) 
  
  output$d3 <- renderD3({
    nido %>%
      mutate(label = !!sym(input$var)) %>%
      group_by(label) %>%
      tally() %>%
      arrange(desc(n)) %>%
      mutate(
        y = n,
        ylabel = prettyNum(n, big.mark = ","),
        fill = ifelse(label != input$val, "#E69F00", "red"),
        mouseover = "#0072B2"
      ) %>%
      r2d3(r2d3_file)
  })
  observeEvent(input$bar_clicked, {
    updateTextInput(session, "val", value = input$bar_clicked)
  })
  output$table1 <- renderDataTable({
    nido %>%
      filter(año %in% input$año)%>%
      filter(mes %in% input$mes)%>%
      filter(agente %in% input$agente) %>%
      datatable()
  })
  
  
  output$table <- renderDataTable({
    nido %>%
      filter(!!sym(input$var) == input$val) %>%
      datatable()
  })
  
  


  
  
  
}
shinyApp(ui, server)