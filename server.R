library(shiny) # Shiny web apps
library(shinydashboard)
library(mlr) # For machine learning in R
library(forecast) # For Boxcox and inverse Boxcox transformations
library(readr) # Read csv files
library(magrittr) # For pipe symbols

# Define server logic for prediction model
server <- function(input, output) {
    
    # Read required data sets from file
    df.vic <- read_csv(
      normalizePath(file.path('data/VICTORIA_COVID19.csv')))
    df.vicx.optimal <- read_csv(
      normalizePath(file.path('data/VICTORIA_COVID19x.csv')))
    
    # Create a regression task
    cases.taskx <- makeRegrTask(data = df.vicx.optimal, target = 'NextDayCasesx')
    
    # Create a linear regression learner
    lrn <- makeLearner(cl = 'regr.glm')

    # Subset model training set
    set.seed(1234)
    n <- nrow(df.vicx.optimal)
    train.set <- sample(n, size = 4/5*n)
    
    # Fit the model
    model.optimal <- train(lrn, cases.taskx, train.set)
    
    # Define reactive events --------------------------------------------------
    
    # Take input from user for 7 Day COVID-19 Case Moving Average and transform into the Boxcox equivalent value
    SvnDayCaseAvgx <- eventReactive(input$Run_model, {
      BoxCox(input$input1, lambda = BoxCox.lambda(df.vic$SvnDayCaseAvg, method = 'guerrero'))
    }, ignoreNULL = FALSE)
    
    # Take input from user for 14 Day COVID-19 Case Moving Average and transform into the Boxcox equivalent value
    FrtnDayCaseAvgx <- eventReactive(input$Run_model, {
      BoxCox(input$input2, lambda = BoxCox.lambda(df.vic$FrtnDayCaseAvg, method = 'guerrero'))
    }, ignoreNULL = FALSE)
    
    # Take input from user for 7 Day COVID-19 Test Moving Average and transform into the Boxcox equivalent value
    SvnDayTestAvgx <- eventReactive(input$Run_model, {
      BoxCox(input$input3, lambda = BoxCox.lambda(df.vic$SvnDayTestAvg , method = 'guerrero'))
    }, ignoreNULL = FALSE)
    
    # Create a new data frame from the user inputs to run linear model predictions
    newdata <- eventReactive(input$Run_model, {
      data.frame(SvnDayCaseAvgx = SvnDayCaseAvgx(), 
                 FrtnDayCaseAvgx = FrtnDayCaseAvgx(), 
                 SvnDayTestAvgx = SvnDayTestAvgx())
    }, ignoreNULL = FALSE)
    
    # Run linear model predictions and convert the results with an inverse Boxcox transformation
    pred <- eventReactive(input$Run_model, {
      boxcox.bounds <- predict.lm(
                          lm(NextDayCasesx ~ SvnDayCaseAvgx + FrtnDayCaseAvgx + SvnDayTestAvgx, data = df.vicx.optimal), 
                          newdata = newdata(), 
                          interval = "predict") %>% 
                          as.data.frame()
      
      df.actual.bounds <- data.frame(
        InvBoxCox(boxcox.bounds$lwr, lambda = BoxCox.lambda(df.vic$NextDayCases, method = 'guerrero')) %>% round(0),
        InvBoxCox(boxcox.bounds$fit, lambda = BoxCox.lambda(df.vic$NextDayCases, method = 'guerrero')) %>% round(0),
        InvBoxCox(boxcox.bounds$upr, lambda = BoxCox.lambda(df.vic$NextDayCases, method = 'guerrero')) %>% round(0)
      )
      df.actual.bounds
    }, ignoreNULL = FALSE)
    
    # Emoji visualisation logic
    img.logic <- eventReactive(input$Run_model, {
      if (pred()[[2]] > input$input4) {
        increase <- data.frame('chart-increasing-emoji-clipart-md.png', 
                      paste0('The model predicts an increase in COVID-19 cases compared with today. The lower and upper bounds of the 95% prediction interval are ', pred()[[1]], ' and ', pred()[[3]], '.'))
        
        increase
      } else if (input$input4 > pred()[[2]]) {
        decrease <- data.frame('chart-decreasing-emoji-clipart-md.png', 
                      paste0('The model predicts a decrease in COVID-19 cases compared with today. The lower and upper bounds of the 95% prediction interval are ', pred()[[1]], ' and ', pred()[[3]], '.'))
        
        decrease
      } else if (pred()[[2]] == input$input4) {
        nochange <- data.frame('nochange.jpeg',
                               paste0('The model predicts no change in COVID-19 cases compared with today. The lower and upper bounds of the 95% prediction interval are ', pred()[[1]], ' and ', pred()[[3]], '.'))
        
        nochange
      }
    }, ignoreNULL = FALSE)
    
    # Show text of fitted prediction
    output$text1 <- renderText(pred()[[2]])
    output$text2 <- renderText(img.logic()[[2]])
    output$image1 <- renderImage({
      filename <- normalizePath(file.path('./images',
                                paste(img.logic()[1])))
  
      # Return a list containing the filename
      list(src = filename)
    }, deleteFile = FALSE)
}
