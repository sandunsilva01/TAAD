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
                                            
This application includes two main parts namely a ‘descriptive analysis window’ and a ‘panel of statistical methods’. Figure 2 illustrates the interface of the TAAD application.

![alt text](https://github.com/sandunsilva01/TAAD/blob/master/fig2_Abnormal_activities_detector_interface.png)

Figure 2 The abnormal activities detector interface.The ‘Descriptive analysis window’ includes plots to visualise the step count distributions and trajectories of participants, along with the descriptive statistics of each and every main physical activity (e.g:swimming, cycling etc), up to the current time point. This will provide the customer service attendant with comprehensive background information about the participant’s physical activity. This window also indicates whether this profile belongs to a suspected ‘person of interest’ as identified by the previous ‘person of interest detector’ classifier. Figure number 2 shows a set of screenshots of the ‘Panel of statistical methods’, which allows the customer service attendants to analyse the anomalies/outliers that exist in each participant’s profile using four main statistical methods, each possessing different strengths, as described below. User could also refer the paper, the authors have published in order to find out further about these methods. 

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
