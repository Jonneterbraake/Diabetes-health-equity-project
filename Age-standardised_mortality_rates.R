
# Calculation of Age-standardised mortality rates
# 27-02-2024
#

# Load packages
library(tidyverse)

# load aggregated data  and standard weight files. 

# Merge
data <- merge(Aggregated_data, Standard_weight, by="age")

# make copy of dataset for overall mortality by sex per country
data2 <- data

# Add var mortality rate* weights and variance
data$asrtmp <- data$d/data$py*data$std_wt
data$varasrtmp <- data$d*(data$std_wt/data$py)^2

# calculate age standardised mort rates
ASR <- data %>%
  group_by(year, sex, ses, diabstatus, cntry) %>%
  summarise(ASR=sum(asrtmp, na.rm=TRUE),
            varASR=sum(varasrtmp, na.rm=TRUE),
            nev=sum(d, na.rm=TRUE))

# Calculate CIs
z_value <- qnorm(0.975)

ASR$lcl_ASR = ASR$ASR - z_value*sqrt(ASR$varASR)
ASR$ucl_ASR = ASR$ASR + z_value*sqrt(ASR$varASR)

ASR <- ASR %>%
  select(year, cntry, sex, ses, diabstatus, ASR, lcl_ASR, ucl_ASR, nev, varASR)

# overall mortality by country
data2 <- data2 %>%
  group_by(age, sex, year, cntry, std_wt) %>%
  summarise(d=sum(d),
            py=sum(py))

# Add var mortality rate* weights and variance
data2$asrtmp <- data2$d/data2$py*data2$std_wt
data2$varasrtmp <- data2$d*(data2$std_wt/data2$py)^2

# calculate age standardised mort rates
ASR2 <- data2 %>%
  group_by(year, sex, cntry) %>%
  summarise(ASR=sum(asrtmp, na.rm=TRUE),
            varASR=sum(varasrtmp, na.rm=TRUE),
            nev=sum(d, na.rm=TRUE))

# Calculate CIs
z_value <- qnorm(0.975)

ASR2$lcl_ASR = ASR2$ASR - z_value*sqrt(ASR2$varASR)
ASR2$ucl_ASR = ASR2$ASR + z_value*sqrt(ASR2$varASR)

# save

