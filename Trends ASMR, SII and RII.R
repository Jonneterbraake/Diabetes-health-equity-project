# Gain insights in the trends
# 28-03-2024

# load packages
library(tidyverse)
library(glm2) 
library(broom)
library(msm)
library(jtools)
library(writexl)

# Load aggregated data file

dat$yr <- dat$year - 2006


# Change in mortality adjusted for age (proxy for trends in ASMR)

trend <- function(data){
  
  tryCatch({
    
    fit <- glm2(d~offset(log(py))+age+yr, data=data, family=poisson(link="log"))
    
    df.r <- fit$df.residual
    disp<-sum((fit$weights * fit$residuals^2)[fit$weights > 0])/df.r

    yrest <- summary(fit)$coefficients["yr",1]
    yrp <- summary(fit)$coefficients["yr",4]
    
    results <- c(cntry=unique(data$cntry),
                         ses=unique(data$ses),
                         sex=unique(data$sex),
                         diabstatus=unique(data$diabstatus),
                         year_est=yrest,
                         p_value=yrp)
    
  }, error = function(e) {
    
    results <- c(cntry=unique(data$cntry),
                         year=unique(data$year),
                         sex=unique(data$sex),
                         diabstatus=unique(data$diabstatus),
                         year_est="error",
                         p_value="error")
    
  })
  
  return(results)
  
}


sets <- dat %>%
  group_by(cntry, diabstatus, sex, ses) %>%
  group_split() 

trend_results <- data.frame()

for (i in seq_along(sets)) {
  dataset <- sets[[i]]
  results <- trend(dataset)
  trend_results <- bind_rows(trend_results, results)
}

# save



# time trends of the SII

trend_sii <- function(data){
  
  tryCatch({
    
    fit <- glm2(d~py+I(py*ses_rrank)+I(py*age)+I(yr*py)+I(py*yr*ses_rrank)-1, data=data, family=poisson(link="log"))

    df.r <- fit$df.residual
    disp<-sum((fit$weights * fit$residuals^2)[fit$weights > 0])/df.r

    yrest <- summary(fit)$coefficients["I(py * yr * ses_rrank)",1]
    yrp <- summary(fit)$coefficients["I(py * yr * ses_rrank)",4]
    
    lower95 <- summ(fit, confint=TRUE)[["coeftable"]]["I(py * yr * ses_rrank)",2]
    upper95 <- summ(fit, confint=TRUE)[["coeftable"]]["I(py * yr * ses_rrank)",3]
    
    results <- c(cntry=unique(data$cntry),
                 sex=unique(data$sex),
                 diabstatus=unique(data$diabstatus),
                 year_est=exp(yrest),
                 p_value=yrp,
                 lower95=exp(lower95),
                 upper95=exp(upper95))

    
  }, error = function(e) {
    
    results <- c(cntry=unique(data$cntry),
                 sex=unique(data$sex),
                 diabstatus=unique(data$diabstatus),
                 year_est="error",
                 p_value="error")
    
  })
  
  return(results)
  
}


sets <- dat %>%
  group_by(cntry, diabstatus, sex) %>%
  group_split() 


trend_results <- data.frame()

for (i in seq_along(sets)) {
  dataset <- sets[[i]]
  results <- trend_sii(dataset)
  trend_results <- bind_rows(trend_results, results)
}


# save



# time trends of the RII

trend_rii <- function(data){
  
  tryCatch({
    
    fit <- glm(d~offset(log(py))+ses_rrank+age+yr+I(ses_rrank*yr), data=data, family=quasipoisson(link="log"))

    yrest <- summary(fit)$coefficients["I(ses_rrank * yr)",1]
    yrp <- summary(fit)$coefficients["I(ses_rrank * yr)",4]
    lower95 <- summ(fit, confint=TRUE)[["coeftable"]]["I(ses_rrank * yr)",2]
    upper95 <- summ(fit, confint=TRUE)[["coeftable"]]["I(ses_rrank * yr)",3]
    
    
    results <- c(cntry=unique(data$cntry),
                 sex=unique(data$sex),
                 diabstatus=unique(data$diabstatus),
                 year=exp(yrest),
                 p_value=yrp,
                 lower95=exp(lower95),
                 upper95=exp(upper95))
    
  }, error = function(e) {
    
    results <- c(cntry=unique(data$cntry),
                 sex=unique(data$sex),
                 diabstatus=unique(data$diabstatus),
                 year_est="error",
                 p_value="error")
    
  })
  
  return(results)
  
}


sets <- dat %>%
  group_by(cntry, diabstatus, sex) %>%
  group_split() 


trend_results <- data.frame()

for (i in seq_along(sets)) {
  dataset <- sets[[i]]
  results <- trend_rii(dataset)
  trend_results <- bind_rows(trend_results, results)
}

# save

