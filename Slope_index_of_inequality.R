
# slope index of inequaliy - theoretical midpoint
# 15-03-2024
#

# Load required packages
library(tidyverse)
library(glm2) 
library(broom)
library(msm)
library(xlsx)

# Load aggregate data


# sset age as character
rank <- data %>%
  mutate(age=as.character(age))

# Function to calculate sii per year, country, sex and diabetes status
calc_sii <- function(data){
  
  tryCatch({
    
    fit <- glm2(d~py:age+I(py*ses_rrank):age-1, data=data, family=quasipoisson(link="identity"))
    
    df.r <- fit$df.residual
    disp<-sum((fit$weights * fit$residuals^2)[fit$weights > 0])/df.r
    
    if(disp<1) fit <- glm2(d~py:age+I(py*ses_rrank):age-1, data=data,  family=poisson(link="identity"))
    
    cvm <- vcov(fit)[6:10,6:10]
    siibyage <- summary(fit)$coefficients[6:10,1]
    
    sesii <- deltamethod(~0.457*x1+0.152*x2+0.141*x3+0.13*x4+0.12*x5,siibyage,cvm)
    
    ageRef <- std_wt %>% pull(std_wt)
    
    ResultsIncidAge <- c(cntry=unique(data$cntry),
                         year=unique(data$year),
                         sex=unique(data$sex),
                         diabstatus=unique(data$diabstatus),
                         SII=sum(ageRef*siibyage),
                         SE=sesii,
                         lower95=sum(ageRef*siibyage)-1.96*sesii,
                         upper95=sum(ageRef*siibyage)+1.96*sesii)
    
  }, error = function(e) {
    
    ResultsIncidAge <- c(cntry=unique(data$cntry),
                         year=unique(data$year),
                         sex=unique(data$sex),
                         diabstatus=unique(data$diabstatus),
                         SII="error",
                         SE="error",
                         lower95="error",
                         upper95="error")
    
  })
  
  return(ResultsIncidAge)
  
}


sii <- rank %>%
  group_by(cntry, year, diabstatus, sex) %>%
  group_split() 

sii_results <- data.frame()

for (i in seq_along(sii)) {
  dataset <- sii[[i]]
  ResultsIncidAge <- calc_sii(dataset)
  sii_results <- bind_rows(sii_results, ResultsIncidAge)
}

# save 

