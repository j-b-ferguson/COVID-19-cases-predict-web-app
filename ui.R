# Define UI for prediction model
library(shiny)
library(shinydashboard)

ui <- shinyUI(dashboardPage(
  
  dashboardHeader(title = "Case Predictor", titleWidth = "230px"),
  
  dashboardSidebar(
      
    sidebarMenu(
      
      # Sidebar menu header
      menuItem("Predict COVID-19 Cases!", tabName = "model", icon = icon("bar-chart-o"), startExpanded = TRUE,
        
        # Sidebar menu inputs       
        numericInput(inputId = "input1", 
                     label = "7 Day COVID-19 Case Moving Average", 
                     value = 20, 
                     min = 0, 
                     max = 500),
        
        numericInput(inputId = "input2", 
                     label = "14 Day COVID-19 Case Moving Average", 
                     value = 20, 
                     min = 0, 
                     max = 500),
        
        numericInput(inputId = "input3", 
                     label = "7 Day COVID-19 Test Moving Average", 
                     value = 20, 
                     min = 0, 
                     max = 10000),
        
        numericInput(inputId = "input4", 
                     label = "Cases Today", 
                     value = 20, 
                     min = 0, 
                     max = 500),
        
        # Predict action button
        div(style="display: inline-block; vertical-align:top; width: 100px;",
          actionButton("Run_model", "Predict!")),
        
        # Author details and social links
        div(style="display: block; vertical-align:top; width:0px; margin-left: -10px;",
          fluidRow(
            column(width = 1,
              box('A Shiny web application by Justin', br(), 'Ferguson', br(), br(),
                  tags$a(href="https://www.justinferguson.me/", icon("globe", "fa-3x")),
                  tags$a(href="https://www.linkedin.com/in/j-b-ferguson/", icon("linkedin", "fa-3x")),
                  tags$a(href="https://github.com/j-b-ferguson/", icon("github", "fa-3x"))))))
        ))),
  
  dashboardBody(
    
        # Custom styles CSS3 and HTML5
        tags$head(tags$style(
          "@import url('https://fonts.googleapis.com/css2?family=Source+Sans+Pro:wght@300&display=swap');
          * {font-family: 'Source Sans Pro', 'sans-serif';
             font-weight: 300;}
          h1 {font-family: 'Source Sans Pro', 'sans-serif';
              font-weight: 200;}"
        )),
        
        tags$head(tags$style(
            type="text/css",
            "#image1 img {height: auto; 
                          width: 200px; 
                          margin-left: auto; 
                          margin-right: auto;}"
        )),
        
        tags$head(tags$style("@import url('https://fonts.googleapis.com/css2?family=Caveat&display=swap');
                              .box-body {color: black;
                                         font-size: 16px;
                                         font-weight: 600;
                                         font-family: 'Caveat', 'sans-serif';
                                         color: white;}"
        )),
        
        tags$head(tags$style(
            type="text/css",
            ".fa-globe {padding-right: 30px; 
                        padding-top: -50px; 
                        font-size: 40px;}
             .fab {padding-right: 30px; 
                   font-size: 40px;}"
        )),
        
        tags$head(tags$style("#text1{color: black;
                                     font-size: 32px;
                                     font-family: Source Sans Pro;}"
        )),
        
        tags$head(tags$style(
          type="text/css",
            ".box-header h3 {font-weight: bold;}"
        )),
    
        tags$style(HTML(
          ".info-box {background:#00000000;}"
        )),
    
    # Set main border
    div(style="box-shadow: 2px 2px 5px grey; 
               margin-top: 29px;",
        
        # Set prediction output
        div(style="display: flex; 
                   margin-left: 85px; 
                   margin-bottom: 20px; 
                   padding-top: 43px;",
            
          h2("The predicted COVID-19 cases tomorrow is:",HTML('&nbsp;')),
          h2(textOutput("text1"))
        ),
        
        # Image and floating text
        fluidRow(
          
          div(style="display: flex; 
                     margin-left: 100px; 
                     margin-bottom: 73px; 
                     float: left;",
              
            imageOutput(outputId = "image1"),
          ),
          
          column(width = 3,
            
            div(style="display: flex; 
                       position: fixed; 
                       margin-left: 20px; 
                       margin-right: 100px; 
                       margin-top: -10px; 
                       padding-top: 0px; 
                       float: left;",
                
              h3(textOutput("text2"))
            ))),
      
      # Inline info boxes    
      div(style = "display: inline-block; 
                   position: fixed; 
                   margin-left: 80px; 
                   margin-top: -200px;",   
          
          infoBox(
            "What", "is this model for?", icon = icon("line-chart"),
            subtitle = 'This model has been fitted from Victorian (Australia) COVID-19 data in order to predict tomorrow\'s cases.',
            width = 3,
            href = 'https://www.justinferguson.me/pages/COVID-19_Aus_cleaned.html'
          ),
          
          infoBox(
            "How", "do I use this model?", icon = icon("question"),
            subtitle = 'Use 7 and 14 day COVID-19 case and test averages to make a prediction. The prediction is then compared with today\'s cases.',
            width = 3,
            href = 'https://www.covid19data.com.au/'
          ),
          
          infoBox(
            "Where", "can I find out more?", icon = icon("book-open"),
            subtitle = 'See how the model was fitted and tested at this link. For active COVID-19 data, please visit covid19data.com.au or the WHO\'s website.',
            width = 3,
            href = 'https://www.justinferguson.me/pages/covid-19-regression-analysis.html'
          ),
          
          infoBox(
            "Who", "is this model for?", icon = icon("user-friends"),
            subtitle = 'Everyone! Please use this app and share with other people. If you have any questions or suggestions, please get in touch.',
            width = 3,
            href = 'mailto:justin.benjamin.ferguson@gmail.com?subject=COVID-19%20Model%20Enquiry'
          ))
      )
    )
  )
)
