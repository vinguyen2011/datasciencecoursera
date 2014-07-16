library(shiny)
shinyUI(pageWithSidebar(
  headerPanel("Reli - How religious are you?"),
  sidebarPanel(
      p("This simple tool can reveal how religious you are."),
      h6("For tutorials - select the Tab 'Readme!' "),
      h5("1. Select a mode to build the formula - Tab 'Model'"),
      p("We are going to run a regression analysis on this dataset to define the formula for the independent
        variable. Please select a mode."),
      radioButtons("mode","Regression modes:",c("Basic multiple regression","Backwards stepwise regression","Forwards stepwise regression")),
      h5("2. Calculate your level of religiousness (0-10) - Tab 'Your calculation' "),
      p("Please fill in a corresponding value for each of those elements."),
      numericInput("age","Age[Age] (>16):", value = 18, min=16, step = 1),
      radioButtons("education","Highest educational level[Education]:", c("Primary education","Secondary education","College","Bachelor or equivalent","Master or equivalent","Doctoral or higher")),
      numericInput("study_years","How many years have you studied[Study_years] (>0):", value = 15, min=0, step = 0.5),
      numericInput("daily_news","How many hours per week on average do you spend on the daily news?[Daily_news] (>=0):", value = 8, min=0, step = 0.5),
      numericInput("strength_parents","How strongly religious is/was the most religious of your parents or guardians?[Strength_parents] (0-10):", value = 5, min=0, max=10, step = 1),
      numericInput("religious_country","To what extent do you consider people in your country of residence to be religious on average?[Religious_country] (0-10):", value = 5, min=0, max=10, step = 1),
      numericInput("worship","How often (how many times) do you visit a place of worship on average per year?[Worship] (>=0):", value = 10, min=0, step = 1),
      numericInput("religion_hours","How many hours on average per week do you practice your religion?[Religion_hours] (>=0):", value = 5, min=0, step = 1),
      numericInput("obey_rules","How strongly do you believe that rules of religion should be obeyed in everyday life?[Obey_rules] (0-10):", value = 5, min=0, max=10, step = 1),
      submitButton(text = "Calculate")
  ),
  mainPanel(
    tabsetPanel(
      id = "tab",
      tabPanel("Your calculation",verbatimTextOutput("calculation")),
      tabPanel("Model", 
               tabsetPanel(
                 id = "tabModel",
                 tabPanel("Summary of the model",verbatimTextOutput("regressionModel")),
                 tabPanel("Residuals",plotOutput("residuals"))
               )
      ),
      tabPanel("Dataset Information",
               tabsetPanel(
                 id="tabData",
                 tabPanel("Variables and records",  verbatimTextOutput("dataInfo")),
                 tabPanel("Level of religiousness", plotOutput("map")),
                 tabPanel("Scatterplots",plotOutput("scatterPlot"))
               )
      ),
      
      tabPanel("Readme!",
               verbatimTextOutput("tutorial"))
      
    )
  )
))
