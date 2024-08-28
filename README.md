#  Danish, Australia, Netherlands, Scotland Diabetes Health Equity Project 

# Introduction
This repository contains the data and code used in the study published at <insert link>, where we compared all-cause mortality trends by SES among adults with and without diabetes for 2004-2021 among four high income countries.
Further information regarding data sources and methodology can be found in the paper. 

# Data
The aggregated data file contain counts of deaths and person-years (Danish and Dutch population and Australian and Scottisch diabetes populations) or population sizes (at 30 June of the given year, for Australian and Scottish general population) of follow-up in 5-year age groups, by sex, socioeconomic status, diabetes status, and calendar year.

The standard weight file contains the percentage of the population of each age group of the 2013 European population, used as the reference population to calculate the age-standardised mortality rates. 

# Data dictionary
	
| Variable   | Description                                                                                  |
|------------|----------------------------------------------------------------------------------------------|
| age        | Age group (35-49, 50-54,…,65-69)                                                             |
| ses        | Socioeconomic status is in quintiles, where 1 is the most disadvantaged quintile and 5 is the least |
| diabstatus | Diabetes status (0=no diabetes, 1=diabetes)                                                  |
| d          | Nr. of deaths                                                                                |
| py         | Nr. of person years of mid-year population                                                   |
| year       | Calendar year                                                                                |
| cntry      | Country (AUS=Australia, DK=Denmark, NL=Netherlands, SCT=Scotland)                            |
| ses_rrank  | Mid-point of the reversed socioeconomic rank                                                 |
