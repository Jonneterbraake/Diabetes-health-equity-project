
# Relative index of inequaliy - theoretical midpoint
# 15-03-2024
#

# Load required packages
library(tidyverse)
library(glm2) 
library(broom)
library(msm)
library(writexl)

# Load aggregated data file

# Add the cumulative ses rank
rank <- data %>%
  group_by(cntry, year, sex, diabstatus, age) %>%
  arrange(ses) %>%
  mutate(age=as.character(age)) 

# Function to calculate sii per year, country, sex and diabetes status
calc_rii <- function(data){
  
  tryCatch({
    
    fit <- glm(d~offset(log(py))+ses_rrank+age, data=data, family=quasipoisson(link="log"))

    df.r <- fit$df.residual
    disp<-sum((fit$weights * fit$residuals^2)[fit$weights > 0])/df.r
    
    if(disp<1) fit <- glm2(d~offset(log(py))+ses_rrank+age, data=data,  family=poisson(link="log"))
    
    logRII <- summary(fit)$coefficients["ses_rrank",1]
    
    selogrii <- summary(fit)$coefficients["ses_rrank",2]
    
    serii <- deltamethod(~exp(x1),logRII,selogrii^2)
    
    
    ResultsIncid <- c(cntry=unique(data$cntry),
                      year=unique(data$year),
                      sex=unique(data$sex),
                      diabstatus=unique(data$diabstatus),
                      RII=exp(logRII),
                      SE=serii,
                      lower95=exp(logRII-1.96*selogrii),
                      upper95=exp(logRII+1.96*selogrii))
    
  }, error = function(e) {
    
    ResultsIncid <- c(cntry=unique(data$cntry),
                      year=unique(data$year),
                      sex=unique(data$sex),
                      diabstatus=unique(data$diabstatus),
                      RII="error",
                      SE="error",
                      lower95="error",
                      upper95="error")
    
  })
  
  return(ResultsIncid)
  
}


rii <- rank %>%
  group_by(cntry, year, diabstatus, sex) %>%
  group_split() 

rii_results <- data.frame()

for (i in seq_along(rii)) {
  dataset <- rii[[i]]
  ResultsIncidAge <- calc_rii(dataset)
  rii_results <- bind_rows(rii_results, ResultsIncidAge)
}

# save 
