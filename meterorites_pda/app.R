#Loading the neccessary apps

library(tidyverse)
library(shiny)
library(ggplot2)
library(shinythemes)

#Reading in the cleaned data
meteorite_data <- read_csv("meteorite_project.csv")

#Creating user interface
ui <- fluidPage(
    #applying a shiny theme
    theme = shinytheme("cerulean"),
    titlePanel("Meteorites"),
    #using fluidRow to make the radio button fit aesthetically on the page
    fluidRow(
        #creating a radio button to allow user to show meteorite data based on those found or fallen
        column(2,
               radioButtons("fall",
                           "Select Fall",
                           choices = unique(meteorite_data$fall))
               ),
        #creating a drop down menu to allow user to filter data by year
        column(2,
               selectInput("year",
                           "Select Year",
                           choices = unique(meteorite_data$year)))
    ),

#adding an action button to update the table only once the button has been pressed
fluidRow(
    column(2,
           actionButton("update", "Show Meteorites")),
column(6,
       tableOutput("meteorites_table")
       )
)
)
server <- function(input, output){
    
    meteorites_filtered <- eventReactive(input$update, {
        
        meteorite_data %>% 
            filter(year == input$year) %>% 
            filter(fall == input$fall) 
    })
    output$meteorites_table <- renderTable({
        meteorites_filtered()
    })
}

shinyApp(ui = ui, server = server)
