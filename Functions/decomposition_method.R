#####################Decomposition Function################################

Decomposition.method<-function(x,DecomposeMethod,seasonalwindow,trendwindow,anmethod){
  
  x$ProgramDate<-strptime(x$ProgramDate,format = "%d/%m/%Y") #adjust the format according to the data provided
  x$ProgramDate<-as.Date.character(x$ProgramDate)
  x<- as_tbl_time(x, ProgramDate)
  x<-x[order(x$ProgramDate),]
  
  data_anomaly<- x%>%
    time_decompose(TotalSteps, 
                   method    = as.character(DecomposeMethod),
                   frequency = paste(as.character(seasonalwindow),"days"),
                   trend     = paste(as.character(trendwindow),"weeks")) %>%
    anomalize(remainder,method=as.character(anmethod))
  
}