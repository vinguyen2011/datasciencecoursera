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
            Level of religious of your country [Religious_country]: category
            Level of religious of your parents are [Strength_parents]: category
            Number of times per year you visit a place to worship [Worship]: numeric
            Number of hours you practice your religion [Religion_hours]: numeric
            Level of obeying the religious rules [Obey_rules]: category
            Your level of religious [religious_self]: category")
    })
    
    #Histogram of the dependent variable
    output$map <- renderPlot({    
      hist(dataCleaned$religious_self, density=20, prob=TRUE, col="thistle", 
           main ="Histogram of religious_self",
           xlab="Level of religious (self assessment)")
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
      #print(religious)
      
      for(n in 2:length)
      {
        #print(as.numeric(coeff[n]))
        #print(as.character(in_var[n]))
        if (in_var[n]=="Age")
        {  
          religious <- religious + (as.numeric(coeff[n])*as.numeric(input$age))
        }
        else if (in_var[n]=="Education")
        {  
          if(input$education =="Primary education")
          {
            religious <- religious + (as.numeric(coeff[n])*1)
          }
          else if(input$education =="Secondary education")
          {
            religious <- religious + (as.numeric(coeff[n])*2)
          }
          else if(input$education =="College")
          {
            religious <- religious + (as.numeric(coeff[n])*3)
          }
          else if(input$education =="Bachelor or equivalent")
          {
            religious <- religious + (as.numeric(coeff[n])*4)
          }
          else if(input$education =="Master or equivalent")
          {
            religious <- religious + (as.numeric(coeff[n])*5)
          }
          else
          {
            religious <- religious + (as.numeric(coeff[n])*6)
          }
        }
        else if (in_var[n]=="Daily_news")
        {  
          religious <- religious + (as.numeric(coeff[n])*as.numeric(input$daily_news))
        }
        else if (in_var[n]=="Strength_parents")
        {  
          religious <- religious + (as.numeric(coeff[n])*as.numeric(input$strength_parents))
        }
        else if (in_var[n]=="Religious_country")
        {  
          religious <- religious + (as.numeric(coeff[n])*as.numeric(input$religious_country))
        }
        else if (in_var[n]=="Worship")
        {  
          religious <- religious + (as.numeric(coeff[n])*as.numeric(input$worship))
        }
        else if (in_var[n]=="Religious_hours")
        {  
          religious <- religious + (as.numeric(coeff[n])*as.numeric(input$religious_hours))
        }
        else if (in_var[n]=="Obey_rules")
        {  
          religious <- religious + (as.numeric(coeff[n])*as.numeric(input$obey_rules))
        }
      }
      print(paste(input$mode," View details in Tab 'Model'", sep =" - "))
      print(paste("Your level of religious (0 - very high; 10 - very low) is: ", as.character(religious)))
      #print(religious)
    })
    
  }
)
