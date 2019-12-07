# TAAD
## The Abnormal Activities Detector

Detecting possible persons of interest in a physical activity program using step entries: including a web based application for outlier detection and decision making

S.S.M.Silva (sssilva@swin.edu.au)1, Denny Meyer (dmeyer@swin.edu.au)1, and Madawa Jayawardana (madawa.jayawardana@petermac.org)1,2,3

1. Department of Statistics, Data Science and Epidemiology, Swinburne University of Technology, Hawthorn
3122 Victoria, Australia
2. Peter MacCallum Cancer Centre, Melbourne 3000 Victoria, Australia
3. Sir Peter MacCallum Department of Oncology, The University of Melbourne, Parkville 3010 Victoria,
Australia

The TAAD detects the outliers and anomalies that exist in the step counts of participants. When a step entry has been detected as an outlier/anomaly, the participants are asked to provide a valid reason for that specific step entry. Customer service attendants of these physical activity programs check and, if necessary, they remove these data points manually. However, this process is very subjective and highly time consuming. To alleviate this problem, we have developed an automated tool known as ‘the abnormal activities detector’ (TAAD) using the R Shiny (Chang et al., 2018) environment to detect multiple outliers in step entries, while allowing the customer representatives to investigate the detected outliers more effectively and efficiently. 

To install and explore the application in your R, you could type the following on your r console. 

                                            runGitHub( "TAAD", "sandunsilva01") 
                                            
This application includes two main parts namely a ‘descriptive analysis window’ and a ‘panel of statistical methods’. Figure 1 illustrates the interface of the TAAD application.

![alt text](https://github.com/sandunsilva01/TAAD/blob/master/fig2_Abnormal_activities_detector_interface.png)

Figure 1 The abnormal activities detector interface.

The user can use the "NewDataToCheckTheApp.csv" file to test the application. In this file there are 13 columns with following column headings. 

1. "MemberID" - Identifier to participant 
2. "EventDay" - Event Day of the program
3. "CreatedDate" - Date that the specific step entry created
4. "BikeSteps" - Step counts conversion of the bike ride 
5. "WalkSteps" - Step counts collected by walking
6. "SwimSteps" - Step counts conversion of swimming 
7. "OtherSteps" - Step count conversion of other physical activities done
8. "TotalSteps" - Total step counts
9. "SpeedCheck" - Decision of the speedchek process 
10. "Channel" - Channel which sync the step counts
11. "DeviceType" - Device type the step counts collected
12. "CheaterProb" - Cheating probability computed by the "person of interest detector" model
13. "ProgramDate" - Actual Date of the event

First the user needs to upload the csv file in to the application and then select a time range for the step count to analyse. 
The ‘Descriptive analysis window’ includes plots to visualise the step count distributions and trajectories of participants, along with the descriptive statistics of each and every main physical activity (e.g:swimming, cycling etc), up to the current time point. This will provide the customer service attendant with comprehensive background information about the participant’s physical activity. This window also indicates whether this profile belongs to a suspected ‘person of interest’ as identified by the previous ‘person of interest detector’ classifier. Figure number 2 shows a set of screenshots of the ‘Panel of statistical methods’, which allows the customer service attendants to analyse the anomalies/outliers that exist in each participant’s profile using four main statistical methods, each possessing different strengths, as described below. User could also refer the paper, the authors have published in order to find out further about these methods. 

![alt text](https://github.com/sandunsilva01/TAAD/blob/master/fig3_Screen_shots_of_all_the_tabs_in_statistical_panel_for_detecting_outliers.jpg)

1. A Median Absolute Deviation Method
2. Grubb’s test
3. Local Outlier Factor
4. Timeseries Decomposition

## Median absolute deviation (MAD) method

A common practice in outlier detection is to use an interval spanning over the mean plus or minus three standard deviations. This method has high sensitivity to outliers (Leys et al., 2013). Median Absolute Deviation is a more robust method. On the "MAD-based method", user could select the required cut-off value and run the test to the selected client and the time period.

## Grubb’s test

Grubb’s test which is also known as extreme studentized deviate test (Grubbs, 1969), is a procedure for determining whether the highest observation, the lowest observation, the highest and the lowest observations, the two highest observations, the two lowest observations or more of the observations are possible outliers in a sample. In Grubb’s test the hypotheses will depend on the above testing objectives. For example, for a two sided test the hypothesis might be.

H0 : There are no outliers in the dataset

H1 :There is exactly one outlier in the data set

Grubb’s test is capable of detecting the most outlying observations in a univariate series. Therefore, this window can be used to detect the most outlying step entries one by one. In this application this test has been coded so that the most outlying entry detected will be flagged and removed before the next cycle for finding the most outlying entry begins. However the flagged outliers are not removed from the visualisation plot, allowing the customer service attendants to view the entire step entry history for each participant. The application enables the user to define a user specific significance level to detect the outliers.

## Local outlier factor (LOF)

The LOF method provides a local outlier factor, which estimates the likelihood of an outlier for each observation in the data set (Breunig et al., 2000). This factor depends on how isolated a specific observation is with respect to its neighbourhood. In other words this method evaluates each observation’s uniqueness depending on the distance from the k nearest neighbours (Breunig et al., 2000). This method is capable of detecting outliers regardless of the distribution of the data. This method is a density based outlier detection method which relies on a nearest neighbour search. In this application the LOF method will compute a LOF value for each and every step entry of a user’s profile, indicating the degree to which each point is an outlier. In the current context this score is computed
using daily fluctuating variables from each participant’s profile, namely ‘total step count’ and with selected variables from the check boxes. To enhance the user-friendliness of this application, these scores have been visualised using a plot. The application allows the user to select a cut off value for the LOF scores in order to identify outliers. In the application, the user can also define the number of nearest observations (k) used in finding the local neighborhood for the LOF score calculations. According to Breunig et al. (2000) the standard deviation of the LOF only tends to stabilize when the local neighborhood size is at least 10 for Gaussian distributions.

## Seasonal Decomposition Method

Time series decomposition is a technique used to decompose a time series into latent subseries such as a trend component, cyclic component, seasonal component and irregular component. This is a popular technique in time series analysis. This technique can be used to detect the outliers in a time series by using the residual series once the trend and seasonality have been removed. In the current study this has been tested using two decomposition methods, a Seasonal Trend decomposition using Loess smoothing (STL) (Cleveland et al., 1990) and a twitter method which decomposes the trend component using a piecewise median approach (Vallis et al., 2014). In the STL method, seasonality is initially extracted after smoothing the original series using LOESS (Cleveland, 1979). Then the estimated seasonal component is subtracted from the original series and the remaining series is smoothed by LOESS in order to extract the trend component. This procedure is repeated until convergence occurs. In the ‘twitter’ method, seasonality extraction is similar to the STL method, whereas the piecewise median will be used with non overlapping windows to extract the long term trend in the original time
series (Vallis et al., 2014). Once the decomposition is completed and the residual series computed, anomaly detection is carried
out using the inter quartile range (IQR) or generalized extreme studentized deviate test (GESD) (Rosner, 1975, 1983). In the Shiny application the user can select either the Twitter or STL seasonal decomposition methods. Once the decomposition is complete the user can select either one of the IQR and GSED ‘anomalize’ methods to detect the anomalies in the residual series of the step counts. Moreover, the user can select the required number of days for seasonal adjustement and number of weeks for trend component. 

## Customizing the Application

This process and framework have been structured mainly for physical activity programs which allow the participants to enter their physical activities during the Global Challenge. However, this method could also be used for other fraud detection activities such as monitoring of financial transactions, which requires close human monitoring and intervention to identify anomalies and then to decide which of these transactions would be approved or rejected. Users can customize TAAD for their own project by renaming the variables (column headings) in the "OutlierApplicationInterface.R" file and the csv file.  

### Acknowledgements 
The authors gratefully acknowledge the Virgin Pulse-Global Challenge for providing the data to test the proposed system. Moreover, the authors gratefully acknowledge funding received from the Virgin Pulse-Global Challenge to cover the publication costs of this paper.

## Session Information

> sessionInfo()

R version 3.5.1 (2018-07-02)
Platform: x86_64-w64-mingw32/x64 (64-bit)
Running under: Windows >= 8 x64 (build 9200)

Matrix products: default

locale:
[1] LC_COLLATE=English_United Kingdom.1252  LC_CTYPE=English_United Kingdom.1252    LC_MONETARY=English_United Kingdom.1252 LC_NUMERIC=C                            LC_TIME=English_United Kingdom.1252    

attached base packages:
[1] grid      stats     graphics  grDevices utils     datasets  methods   base     

other attached packages:
 [1] outliers_0.14     janitor_1.1.1     Hmisc_4.1-1       Formula_1.2-3     survival_2.42-3   DT_0.4            crayon_1.3.4      forcats_0.3.0     stringr_1.3.1     purrr_0.2.5       readr_1.1.1       tidyr_1.0.0       tibble_2.1.3     
[14] tidyverse_1.2.1   anomalize_0.1.1   tibbletime_0.1.1  plotly_4.8.0      data.table_1.11.8 DMwR_0.4.1        lattice_0.20-35   shinythemes_1.1.1 ggplot2_3.1.0     shiny_1.2.0       dplyr_0.8.3      

loaded via a namespace (and not attached):
  [1] colorspace_1.3-2    timetk_0.1.1.1      ellipsis_0.3.0      class_7.3-14        rsconnect_0.8.8     htmlTable_1.12      base64enc_0.1-3     rstudioapi_0.8      prodlim_2018.04.18  lubridate_1.7.4     xml2_1.2.0          codetools_0.2-15   
 [13] splines_3.5.1       knitr_1.20          zeallot_0.1.0       jsonlite_1.5        Cairo_1.5-9         caret_6.0-80        broom_0.5.0         cluster_2.0.7-1     compiler_3.5.1      httr_1.3.1          backports_1.1.2     assertthat_0.2.0   
 [25] Matrix_1.2-14       lazyeval_0.2.1      cli_1.0.1           later_0.7.5         acepack_1.4.1       htmltools_0.3.6     tools_3.5.1         gtable_0.2.0        glue_1.3.1          reshape2_1.4.3      Rcpp_1.0.2          fracdiff_1.4-2     
 [37] cellranger_1.1.0    vctrs_0.2.0         urca_1.3-0          gdata_2.18.0        nlme_3.1-137        iterators_1.0.10    crosstalk_1.0.0     lmtest_0.9-36       timeDate_3043.102   gower_0.1.2         rvest_0.3.2         mime_0.6           
 [49] lifecycle_0.1.0     gtools_3.8.1        MASS_7.3-50         zoo_1.8-4           scales_1.0.0        ipred_0.9-8         hms_0.4.2           promises_1.0.1      parallel_3.5.1      RColorBrewer_1.1-2  yaml_2.2.0          quantmod_0.4-13    
 [61] curl_3.2            gridExtra_2.3       uroot_2.0-9         rpart_4.1-13        latticeExtra_0.6-28 stringi_1.2.4       tseries_0.10-45     foreach_1.4.4       checkmate_1.8.5     TTR_0.23-4          caTools_1.17.1.1    lava_1.6.3         
 [73] rlang_0.4.0         pkgconfig_2.0.2     bitops_1.0-6        ROCR_1.0-7          labeling_0.3        recipes_0.1.7       htmlwidgets_1.3     sweep_0.2.1.1       tidyselect_0.2.5    plyr_1.8.4          magrittr_1.5        R6_2.3.0           
 [85] gplots_3.0.1        generics_0.0.2      pillar_1.4.2        haven_1.1.2         foreign_0.8-70      withr_2.1.2         xts_0.11-2          abind_1.4-5         nnet_7.3-12         modelr_0.1.2        KernSmooth_2.23-15  readxl_1.1.0       
 [97] ModelMetrics_1.2.2  forecast_8.4        digest_0.6.18       xtable_1.8-3        httpuv_1.4.5        stats4_3.5.1        munsell_0.5.0       glmnet_2.0-16       viridisLite_0.3.0   quadprog_1.5-5  
