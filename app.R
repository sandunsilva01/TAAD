##TAAD 

library(shiny)
library(ggplot2)
library(shinythemes)
library(DMwR)
library(outliers)
library(data.table)
library(Rcpp)
library(plotly)
library(tibbletime)
library(anomalize)
library(tidyverse)
library(rlang)
library(lubridate)  #manipulation of dates
library(magrittr)
library(shinyBS)
library(graphics)
library(crayon)
library(DT)
library(Hmisc)
library(janitor)

options(width=250)


source(paste(getwd(),"","/Functions/grubbs_method.R",sep=""))
source(paste(getwd(),"/Functions/decomposition_method.R",sep=""))

##Shiny User Interface

ui<-fluidPage(
  tags$head(
    tags$style(paste0(
      "body:before { ",
      "  content: ''; ",
      "  height: 100%; width: 100%; ",
      "  position: fixed; ",
      "  z-index: -1; ",
      "  background: url() no-repeat center center fixed; ",
      "  background-size: cover; ",
      "  filter: grayscale(100%); ",
      "  -webkit-filter: grayscale(100%); }"),
      HTML("
           .shiny-output-error-validation {
           color: blue;
           }
           "))),
  theme = shinytheme("spacelab"),div(style = "height:100%;background-color:#DCDCDC;",
                                     tagList(
                                       titlePanel(strong("Abnormal Activities Detector",style ="background-color:#B0C4DE;")),
                                       fluidRow(column(2,div(style = "height:400px;background-color:#B0C4DE;",
                                                             
                                                             tags$hr(),
                                                             tags$h5("Upload the User Profile"),
                                                             fileInput('file1', hr('Choose the CSV File'),
                                                                       accept=c('text/csv', 
                                                                                'text/comma-separated-values,text/plain', 
                                                                                '.csv'),width='100%'),
                                                             tags$hr(),
                                                             
                                                             uiOutput("ClientID"),
                                                             uiOutput("TimeSelect")),
                                                       
                                                       tags$hr(),
                                                       
                                                       textOutput("Cheater1"),
                                                       
                                                       tags$head(tags$style("#Cheater{color: red;
                                                                            font-size: 20px;
                                                                            font-style: bold;
                                                                            }"))
          ,
          plotOutput("bplot",height = "250px")
                                                       ),
          
          column(10,
                 
                 fluidRow(column(9,
                                 div(style='height:400px; overflow: scroll',
                                     verbatimTextOutput("summary")), 
                                 br(),
                                 fluidRow(
                                   DTOutput(outputId ='contents',height ="50%"))),
                          fluidRow(column(3,plotlyOutput("histogram",
                                                         height = "250px"),
                                          
                                          plotlyOutput("timeseries",height = "250px"),
                                          br(),
                                          plotlyOutput("timeseriesperc",height = "250px"),offset = 0))
                 ))
                                                       ),
          
          div(style = "height:100%;background-color: 	#C0C0C0;",
              tabsetPanel(
                tabPanel(tags$b("MAD-based Method"),
                         sidebarLayout(
                           sidebarPanel(
                             sliderInput(inputId = "MADcutoff", label="Select the cut-off value", min=2, max=10, value=3.5, round = FALSE, step = 0.5),   
                             actionButton(inputId = "runMAD", label ="Calculate")),
                           mainPanel(   
                             column(10,plotlyOutput(outputId ="MADPlot",width = "100%"),offset = 1)
                           ))),
                
                tabPanel(tags$b("Grubb's Test"),
                         sidebarLayout(
                           sidebarPanel(
                             selectInput(inputId = "siglevel", label="Select the significance level", choices = c(0.01, 0.05, 0.1, 0.2), selected = 0.05),   
                             actionButton(inputId = "runGrubbs", label ="Calculate")),
                           mainPanel(
                             column(10,plotlyOutput(outputId ="GrubbsPlot"),offset = 1)
                           ))),
                
                tabPanel(tags$b("Local Outlier Factor (LOF)"),
                         
                         sidebarLayout(
                           sidebarPanel(
                             checkboxGroupInput(inputId="LOFVar", label="Select the Variables", choices = c("EventDay","CreatedDate","BikeSteps","SwimSteps","WalkSteps"),
                                                selected = c("EventDay","CreatedDate")),
                             sliderInput(inputId = "LOFsize", label="Select the LOF size", min=10, max=80, value=20, round = FALSE, step = 5),  
                             sliderInput(inputId = "LOFcutoff", label="Select the cut-off value", min=1, max=10, value=2, round = FALSE, step = 0.2),   
                             actionButton(inputId = "runLOF", label ="Calculate")),
                           mainPanel( 
                             column(10,plotlyOutput(outputId ="LOFPlot"),offset = 1)
                             
                           ))),
                tabPanel(tags$b("Time series Decompostion"),
                         
                         fluidRow(style = "height:100%;background-color:#DCDCDC;",
                                  
                                  column(2,selectInput(inputId = "DeMethod",label="Decomposition Method",
                                                       choices=c("stl","twitter"),selected="Twitter"),
                                         actionButton(inputId = "runDecompostion", label ="Run Decomposition")),
                                  column(4,sliderInput(inputId = "swindow", label="Seasonal Adjustment (Removal of Seasonality-in days)", min=1, max=7, value=7, round = FALSE, step = 1)),
                                  column(3,sliderInput(inputId = "trend", label="Trend Component (in weeks)", min=1, max=7, value=7, round = FALSE, step = 1)),
                                  column(3,selectInput(inputId = "AnomalizeMethod",label="Anomalize Method",
                                                       choices=c("gesd","iqr"),selected="gesd"))),
                         fluidRow(       
                           column(10,plotlyOutput(outputId ="DecompositionPlot"),offset = 1)
                           
                         ))
                
              )
          )
                                       )
                                     ))

options(shiny.maxRequestSize=100*1024^2) 

`%then%` <- shiny:::`%OR%`
##Shiny Server

server<-function(input,output){
  
  
  #Read the CSV file
  
  filedata <- reactive({
    inFile <- input$file1
    if (is.null(inFile)){
      return(NULL)}
    x<- read.csv(inFile$datapath, row.names = NULL,colClasses = c("MemberID"="integer","EventDay"="integer"))
    x$CreatedDate<-excel_numeric_to_date(x$CreatedDate)
    x$weekday<-weekdays(x$CreatedDate)
    x<-x %>% setorder(MemberID,EventDay,CreatedDate) 
    x
  })
  
  #input MemberId
  
  output$ClientID <- renderUI({
    df <- filedata()
    if (is.null(df)) return(NULL)
    items = df[,"MemberID"]
    selectInput("ClientID","Select the ClientID",items)
  })
  
  #Time Select Input
  
  output$TimeSelect <- renderUI({
    df <- filedata()
    if (is.null(df)) return(NULL)
    time_item = df[,"EventDay"]
    sliderInput("TimeSelect","Select the Time Period of the Program",min=min(filedata()$EventDay),max=max(filedata()$EventDay),time_item,step=1,value=1,animate = TRUE)
  })
  
  
  
  #subset the data frame for the selected Memeber ID
  
  
  new_data <- eventReactive(
    {clientid<-input$ClientID 
    timerangemin<-input$TimeSelect
    
    },
    {
      data_subset <- filedata() 
      if(is.null(data_subset)) return(NULL)
      x<-filter(data_subset,MemberID == input$ClientID ,EventDay <= input$TimeSelect) 
      filter(x,duplicated(x$EventDay)==FALSE)
    })
  
  
  #Table output show for the respective Memebr Id
  
  output$contents <- renderDT(
    
    new_data()[,c("EventDay","TotalSteps","SpeedCheck")],options=list(pageLength=5),filter="top",
    selection="none",rownames=FALSE
  )
  
  #Histogram
  
  output$histogram<-renderPlotly({
    if (nrow(new_data()) == 0) return(NULL)
    hisplot<-ggplotly(ggplot(data=new_data(), aes(TotalSteps,fill=DeviceType)) +
                        geom_histogram() +theme(title = element_text(size = rel(0.8))))
    hisplot%>% config(displayModeBar = F)
  })
  
  
  #Timeseries of Different activities percentage
  
  
  output$timeseriesperc<-renderPlotly({
    
    WalkStep_Percentage<-round((new_data()$WalkSteps/new_data()$TotalSteps*100),2)
    SWimStep_Percentage<-round((new_data()$SwimSteps/new_data()$TotalSteps*100),2)
    BikeStep_Percentage<-round((new_data()$BikeSteps/new_data()$TotalSteps*100),2)
    OtherStep_Percentage<-round((new_data()$OtherSteps/new_data()$TotalSteps*100),2)
    
    if (nrow(new_data()) == 0) return(NULL)
    
    timeplot<-ggplotly(ggplot(data=new_data(), aes(x=EventDay)) + geom_line(aes(y=WalkStep_Percentage),color=2)
                       +geom_line(aes(y=SWimStep_Percentage),color=4)
                       +geom_line(aes(y=BikeStep_Percentage),color=3)
                       +geom_line(aes(y=OtherStep_Percentage),color=5)+ylim(0,100)
                       + theme(title = element_text(size = rel(0.8)))
                       +xlab("Event Day") + ylab("Step Count Percentage"))
    timeplot%>% config(displayModeBar=F)                     
  })
  
  #Timeseries2 Total Steps
  
  
  output$timeseries<-renderPlotly({
    
    if (nrow(new_data()) == 0) return(NULL)
    
    timeplot<- ggplotly(ggplot(data=new_data()[order(new_data()$EventDay),], aes(EventDay,TotalSteps)) + geom_line(color=9)
                        +geom_hline(yintercept = 30000,color="red")
                        + theme(title = element_text(size = rel(0.8)))+
                          xlab("Event Day") + ylab("Daily Step Count"))
    timeplot%>% config(displayModeBar=F)                     
  })
  
  
  
  #Summary Table
  
  output$summary<-renderPrint({
    describe(new_data()[c("WalkSteps","SwimSteps","BikeSteps","OtherSteps","TotalSteps","Channel","DeviceType")],
             descript ="Descriptive Analysis",scroll=TRUE)
  }, width=getOption("width")
  )
  
  #Cheater prob output
  
  output$Cheater1<-renderText({
    paste(round(mean(tail(sort(new_data()$CheaterProb),5))),"% Suspected Cheater according to the average of five top most cheating probabilities")
    
  }
  )
  
  
  #Cheater_bar plot
  
  output$bplot<-renderPlot({
    
    goodval<-as.numeric(filter(new_data()["CheaterProb"],new_data()["EventDay"]==max(new_data()["EventDay"])))
    if (nrow(new_data()) == 0) return(NULL)
    x<-barplot(c(Cheater=goodval,Genuine=(100-goodval)), main=paste("Cheating Probability on day",max(new_data()["EventDay"])), 
               xlab="Classification",ylim=c(0,100),ylab="Probability",col="grey",cex.main=1)
    text(x, 10, paste(round(c(Cheater=goodval,Genuine=(100-goodval)), 1),"%")) 
  })
  
  #MAD Method
  
  MADscore <- eventReactive(input$runMAD, {
    
    abs (new_data()[,"TotalSteps"] - median(new_data()[,"TotalSteps"]))/ mad(new_data()[,"TotalSteps"])
    
  })
  
  #MAD Plot
  
  output$MADPlot<- renderPlotly({ 
    validate(
      need(input$ClientID!='', 'Select a Member ID') %then%
        need(input$TimeSelect!=1,"Please select a Time Period")
    ) 
    data_extracted <- new_data()
    
    if(length(data_extracted[which(MADscore() > input$MADcutoff), ][[2]]) < 1) {
      
      gplt <- ggplotly(ggplot(data=data_extracted, aes(EventDay, TotalSteps)) + geom_point(colour= I("gray")) + xlab("Event Day") + ylab("Total Step Count") +
                         ggtitle(paste("MAD Method: member ID =", data_extracted[1, "MemberID"])) + theme(title = element_text(size = rel(0.8)))
      )
      gplt %>% config(displayModeBar = F)
      
    } else {
      
      data.score <- data_extracted[row.names(data_extracted[which(MADscore() > input$MADcutoff), ]), ]  
      
      gplt <-  ggplotly(ggplot(data=data_extracted, aes(EventDay, TotalSteps)) + geom_point(colour= I("grey")) + xlab("Event Day") + ylab("Total Step Count") + 
                          geom_point(data=data.score, colour="red3") + ggtitle(paste("MAD Method: member ID =", data_extracted[1,"MemberID"])) + theme(title = element_text(size = rel(0.8)))
      )
    }
    gplt %>% config(displayModeBar = F)
    
  })
  
  #Grubb's Test
  
  grubbsTest <- eventReactive(input$runGrubbs, {
    grubbs.method(new_data()[,"TotalSteps"], Grubbs.sig = as.numeric(input$siglevel))
    
  })
  
  output$GrubbsPlot<- renderPlotly({
    validate(
      need(input$ClientID!='', 'Select a Member ID') %then%
        need(input$TimeSelect!=1,"Please select a Time Period")
    ) 
    grubbsTest <- grubbsTest()
    data_extracted <- new_data()
    
    if( is.null(grubbsTest$outlier)==TRUE ){
      
      grbplt <- ggplotly(ggplot(data=data_extracted, aes(EventDay, TotalSteps)) + geom_point(colour= I("gray")) + xlab("Event Day") + ylab("Total Step Count") +
                           ggtitle(paste("Grubb's Test: member ID =", data_extracted[1,"MemberID"])) + theme(title = element_text(size = rel(0.8)))
      )
      grbplt %>% config(displayModeBar = F)
      
    } else if (length(grubbsTest$Outlier.loci) != length(grubbsTest$outlier)) {
      grbplt <- ggplotly(ggplot(data=data_extracted, aes(EventDay, TotalSteps)) + geom_point(colour= I("gray")) + xlab("Event Day") + ylab("Total Step Count") +
                           ggtitle(paste("Grubb's Test: member ID =", data_extracted[1,"MemberID"])) + theme(title = element_text(size = rel(0.8)))
      )
      grbplt %>% config(displayModeBar = F)
      
    } else {
      data.score.grubbs <- data_extracted[ c(grubbsTest$Outlier.loci), ]
      
      grbplt <- ggplotly(ggplot(data=data_extracted, aes(EventDay, TotalSteps)) + geom_point(colour= I("gray")) + xlab("Event Day") + ylab("Total Step Count") +
                           geom_point(data=data.score.grubbs, colour="red3") + ggtitle(paste("Grubb's Test: member ID =", data_extracted[1,"MemberID"])) + theme(title = element_text(size = rel(0.8)))
      )
      grbplt %>% config(displayModeBar = F)
    }
    
  })
  
  #LOF Method
  
  LOF.Val <- eventReactive(input$runLOF, {
    
    data_extracted <- new_data()
    data_extracted$CreatedDate<-as.numeric(data_extracted$CreatedDate)
    LOF.scores <- lofactor((data_extracted[,c("TotalSteps",input$LOFVar)]), input$LOFsize)
    summary.LOF<- data.frame(data_extracted[, c("EventDay", "TotalSteps")], LOF.scores, LOF.scores > input$LOFcutoff)
    
    return(summary.LOF)
  })
  
  output$LOFPlot<- renderPlotly({
    
    data_extracted <- new_data()
    summary.LOF <- LOF.Val()
    
    validate(
      need(input$ClientID!='', 'Select a Member ID') %then%
        need(input$TimeSelect!=1,"Please select a Time Period"),
      need(nrow(data_extracted) == nrow(summary.LOF),"Please Rerun the test to update the plot")
    ) 
    
    
    
    
    data_extracted$LOF.scores<-summary.LOF$LOF.scores 
    
    outliers.LOF <- which(summary.LOF[,4]==TRUE)
    
    
    if (length(outliers.LOF) < 1) {
      p <- ggplotly(ggplot(data=data_extracted, aes(EventDay, TotalSteps)) +geom_point(color=I("gray"))  +xlab("Event Day") + ylab("Total Step Count") +
                      ggtitle(paste("LOF: member ID =", data_extracted[1,"MemberID"])) + theme(title = element_text(size = rel(0.8)))
      )
      p %>% config(displayModeBar = F)
      
    } 
    
    else {
      p <- ggplotly(ggplot(data=data_extracted, aes(EventDay, TotalSteps)) +geom_point(aes(size=LOF.scores),color=I("gray"))+ xlab("Event Day") + ylab("Total Step Count") +
                      geom_point(data= data_extracted[ outliers.LOF, ], aes(size=LOF.scores),color="red") + ggtitle(paste("LOF: member ID =", data_extracted[1,"MemberID"])) + theme(title = element_text(size = rel(0.8)))
      )
      p %>% config(displayModeBar = F)
      
    }
    
  })  
  
  
  #Seasonal Decomposition Method
  
  SeasonalDecomposition <- eventReactive(input$runDecompostion, {
    Decomposition.method(new_data()[1:ncol(new_data())],DecomposeMethod=as.character(input$DeMethod),
                         seasonalwindow=as.character(input$swindow),trendwindow=as.character(input$trend),
                         anmethod=as.character(input$AnomalizeMethod))
  })
  
  
  output$DecompositionPlot<- renderPlotly({ 
    validate(
      need(input$ClientID!='', 'Select a Member ID') %then%
        need(input$TimeSelect!=1,"Please select a Time Period")
    )
    
    SeasonalDecomposition<-SeasonalDecomposition()
    
    gplt <-  ggplotly(plot_anomaly_decomposition(SeasonalDecomposition,ncol=2) +geom_line()
    )
    gplt %>% config(displayModeBar = F)
    
    
  })
  
  
  
  
  
}

shinyApp(ui=ui,server=server)
