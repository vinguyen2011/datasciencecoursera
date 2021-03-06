library(shiny)

#Load data to the working environment
dataReligion <- read.csv("5_12_2012-temp.csv")

#Clean all the missing data and save the new data
dataCleaned <- dataReligion[complete.cases(dataReligion), ] 

#Create palette with RColorBrewer
require("RColorBrewer")

#Mean and Std
m<-mean(dataCleaned$religious_self)
std<-sqrt(var(dataCleaned$religious_self))

shinyServer(
  function(input, output) {
    #Data info
    output$dataInfo <- renderText({
      paste("
    Number of records: 654
    Variables: 
            id [id]: numeric
            Gender [Gender]: category
            Education [Education]: category
            Number of studied years [Study_years]: numeric
            Number of hours per week to read news [Daily_news]: numeric
            Level of religiousness of your country [Religious_country]: category
            Level of religiousness of your parents are [Strength_parents]: category
            Number of times per year you visit a place to worship [Worship]: numeric
            Number of hours you practice your religion [Religion_hours]: numeric
            Level of obeying the religious rules [Obey_rules]: category
            Your level of religiousness [religious_self]: category")
    })
    
    #Histogram of the dependent variable
    output$map <- renderPlot({    
      hist(dataCleaned$religious_self, density=20, prob=TRUE, col="thistle", 
           main ="Histogram of religious_self",
           xlab="Level of religiousness (self assessment)")
      curve(dnorm(x, mean=m, sd=std), add=TRUE)
    })
    
    #Scatter plot matrix for all variables
    panel.hist <- function (x, ...)
    {
      usr <- par("usr"); on.exit(par(usr))
      par(usr=c(usr[1:2],0,1.5))
      h<-hist(x,plot=FALSE)
      breaks <-h$breaks;nB<-length(breaks)
      y<-h$counts;y<-y/max(y)
      rect(breaks[-nB],0,breaks[-1],y,...)
    }
    output$scatterPlot <- renderPlot({    
      pairs(dataCleaned[7:12],
            panel=panel.smooth,
            main="Scatterplot Matrix",
            diag.panel=panel.hist,
            pch=16,
            col=brewer.pal(3,"Pastel1")[unclass(dataCleaned$Gender)])
    })
    

    
    #Conduct a regression analysis
    f <- function(x)({

      if(identical(x,"Basic multiple regression"))
      {
        reg <- lm(religious_self ~ Age + Education + Study_years + Daily_news + Strength_parents + Religious_country + Worship + Religion_hours + Obey_rules, 
                  data = dataCleaned)
      }
      else if (identical(x,"Backwards stepwise regression"))
      {
        reg <- lm(religious_self ~ Age + Education + Study_years + Daily_news + Strength_parents + Religious_country + Worship + Religion_hours + Obey_rules, 
                  data = dataCleaned)
        reg <- step(reg, direction = "backward", trace=0)
      }
      else
      {
        reg <- lm(religious_self ~ 1, data = dataCleaned)
        reg <- step(reg, direction ="forward",
                    scope=(~ Age + Education + Study_years + Daily_news + Strength_parents + Religious_country + Worship + Religion_hours + Obey_rules), 
                    data = dataCleaned,
                    trace=0)
      }
      
    })
    
    #Summary
    output$regressionModel <- renderPrint({
      print(input$mode) 
      print(summary(f(as.character(input$mode))))  #Print the summary
      
    })
    
    #Residual plots
    output$residuals<- renderPlot({
      hist(
      residuals(f(as.character(input$mode))), density=20, prob=TRUE, col="thistle", 
      main ="Histogram of residuals")
    })         #Print the residuals histogram
    
    
    #Calculate the religious_self value
    output$calculation <- renderPrint({
    
      #Get the list of independent variables in the formula
      in_var <- names(f(as.character(input$mode))$coefficients)
      coeff <- f(as.character(input$mode))$coefficients
      length <- length(in_var)
      religious <- as.numeric(coeff[1])

      #Vector for the formula
      formula <- c("religious_self = ",as.numeric(coeff[1]), "+")
      
      for(n in 2:length)
      {
        if (in_var[n]=="Age")
        {  
          religious <- religious + (as.numeric(coeff[n])*as.numeric(input$age))
          formula <- c(formula, as.character(as.numeric(coeff[n])), " * ", as.character(as.numeric(input$age)),"+")
        }
        else if (in_var[n]=="Education")
        {  
          if(input$education =="Primary education")
          {
            religious <- religious + (as.numeric(coeff[n])*1)
            formula <- c(formula, as.character(as.numeric(coeff[n])), " * ", "1","+")
            
          }
          else if(input$education =="Secondary education")
          {
            religious <- religious + (as.numeric(coeff[n])*2)
            formula <- c(formula, as.character(as.numeric(coeff[n])), " * ", "2","+")
            
          }
          else if(input$education =="College")
          {
            religious <- religious + (as.numeric(coeff[n])*3)
            formula <- c(formula, as.character(as.numeric(coeff[n])), " * ", "3","+")
            
          }
          else if(input$education =="Bachelor or equivalent")
          {
            religious <- religious + (as.numeric(coeff[n])*4)
            formula <- c(formula, as.character(as.numeric(coeff[n])), " * ", "4","+")
            
          }
          else if(input$education =="Master or equivalent")
          {
            religious <- religious + (as.numeric(coeff[n])*5)
            formula <- c(formula, as.character(as.numeric(coeff[n])), " * ", "5","+")
            
          }
          else
          {
            religious <- religious + (as.numeric(coeff[n])*6)
            formula <- c(formula, as.character(as.numeric(coeff[n])), " * ", "6","+")
            
          }
        }
        else if (in_var[n]=="Daily_news")
        {  
          religious <- religious + (as.numeric(coeff[n])*as.numeric(input$daily_news))
          formula <- c(formula, as.character(as.numeric(coeff[n])), " * ", as.character(as.numeric(input$daily_news)),"+")
          
        }
        else if (in_var[n]=="Strength_parents")
        {  
          religious <- religious + (as.numeric(coeff[n])*as.numeric(input$strength_parents))
          formula <- c(formula, as.character(as.numeric(coeff[n])), " * ", as.character(as.numeric(input$strength_parents)),"+")
          
        }
        else if (in_var[n]=="Religious_country")
        {  
          religious <- religious + (as.numeric(coeff[n])*as.numeric(input$religious_country))
          formula <- c(formula, as.character(as.numeric(coeff[n])), " * ", as.character(as.numeric(input$religious_country)),"+")
          
        }
        else if (in_var[n]=="Worship")
        {  
          religious <- religious + (as.numeric(coeff[n])*as.numeric(input$worship))
          formula <- c(formula, as.character(as.numeric(coeff[n])), " * ", as.character(as.numeric(input$worship)),"+")
          
        }
        else if (in_var[n]=="Religious_hours")
        {  
          religious <- religious + (as.numeric(coeff[n])*as.numeric(input$religious_hours))
          formula <- c(formula, as.character(as.numeric(coeff[n])), " * ", as.character(as.numeric(input$religious_hours)),"+")
          
        }
        else if (in_var[n]=="Obey_rules")
        {  
          religious <- religious + (as.numeric(coeff[n])*as.numeric(input$obey_rules))
          formula <- c(formula, as.character(as.numeric(coeff[n])), " * ", as.character(as.numeric(input$obey_rules)))
          
        }
      }
      
      print(paste(input$mode," View details in Tab 'Model'", sep =" - "))
      print(paste(formula, sep ="",collapse = ""))
      print(paste("Your level of religiousness (0 - very low; 10 - very high) is: ", as.character(religious)))
    })
    
    #Tutorials
    output$tutorial <- renderText({
      paste("
This tool will run a regression analysis on a pre-defined dataset of 654 records. Thus, the model will define the formula which is used to 
calculate your level of religiousness (0 - very low, 10 - very high)

To run this application, we need your inputs. 
Step 1: Please select a mode for the regression model. There are three modes: Basic multiple regression, Backwards stepwise regression and Forwards stepwise regression.
Step 2: Please answer some questions which will give us the inputs of several dependent variables for the calculation. 
Finally, please press the button 'Calculate'.

The final result will be shown in the Tab 'Your calculation'.
If you want to check the model, please select the Tab 'Model'. 
- The sub-tab 'Summary of the model' will give you a summary of the regression analysis. 
- The sub-tab 'Residuals' shows the histogram of the residuals from the regression analysis

If you want to check the dataset, please select the Tab 'Dataset Information'
- The sub-tab 'Variables and records' shows the description of all variables in the dataset
- The sub-tab 'Level of religiousness' depicts the histogram of the dependent variable (religious_self)
- The sub-tab 'Scatterplots' presents the scatter plots and the histogram of all variables in the dataset

Final remark is that the dataset is made up for the purpose of demonstration.  
Enjoy!
      ")
    })
  }
)
