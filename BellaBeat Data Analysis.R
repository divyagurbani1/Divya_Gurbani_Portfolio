install.packages("tidyverse")
install.packages("readr")
install.packages("dplyr")
install.packages("skimr")
install.packages("janitor")
install.packages("lubridate")


library(tidyverse)
library(readr)
library(dplyr)
library(skimr)
library(janitor)
library(lubridate)

##Loading data from (https://www.kaggle.com/arashnic/fitbit)




head(daily_activity)
colnames(daily_activity)

head(sleep_day)
colnames(sleep_day)

##to find out unique participants in each dataset

n_distinct(daily_activity$Id)
n_distinct(sleep_day$Id)

## To find out number of observations in each dataframe
nrow(daily_activity)
nrow(sleep_day)

##to summarize the daily_activity

daily_activity %>% 
  select(TotalSteps, TotalDistance, SedentaryMinutes) %>% 
  summary()
##to summarize sleep days

sleep_day %>% 
  select(TotalSleepRecords, TotalMinutesAsleep, TotalTimeInBed) %>% 
  summarize()

##to plot a relationship between no. of steps and sedentary minutes

ggplot(data = daily_activity, aes(x=TotalSteps, y=SedentaryMinutes)) + geom_point() + geom_smooth()

## relationship between minutes asleep and time in bed

ggplot(data = sleep_day, aes(x=TotalMinutesAsleep, y=TotalTimeInBed)) + geom_point() + geom_smooth()




##Understanding dataset
colnames(daily_activity)
View(daily_activity)
View(daily_calories)                      


#Filtering useful data
activities <- daily_activity
calories <- daily_calories
intensities <- daily_intensities
steps <- daily_Steps
sleep <- sleep_day
weight <- weight_logInfo



## Examining the data
View(activities)
View(calories)
View(intensities)
View(steps)
View(sleep)
View(weight)


# Cleaning data (Changing the character date into date and time)
activities$ActivityDate <- as.POSIXct(activities$ActivityDate, format="%Y/%d/%m-%H:%M", tz=Sys.timezone())
activities$date <- format(activities$ActivityDate, format="%m/%d/%Y")
sleep$SleepDay <- as.POSIXct(sleep$SleepDay, format="%m/%d/%Y %H:%M:%S", tz=Sys.timezone())
sleep$date <- format(sleep$SleepDay, format="%m/%d/%Y")
sleep$time <-format(sleep$SleepDay, format="%H:%M:%S")

#
#to get weekdays in sleep

#Finding number of participants in each category
n_distinct(activities$Id)
n_distinct(calories$Id)
n_distinct(intensities$Id)
n_distinct(steps$Id)
n_distinct(sleep$Id)
n_distinct(weight$Id)

#Checking the mean weight of the participants
weight %>% 
  group_by(Id) %>% 
  summarize(min_weight = min(WeightKg), max_weight = max(WeightKg), mean_weight = mean(WeightKg))
## There is no significant change in weight

## Summarizing the sleep dataset

sleep %>% 
  select(TotalSleepRecords, TotalMinutesAsleep, TotalTimeInBed) %>% 
  summary()



## Summarizing the activities dataset

activities %>% 
  select(TotalSteps, TotalDistance, FairlyActiveMinutes, LightlyActiveMinutes, VeryActiveMinutes, SedentaryMinutes) %>% 
  summary()

steps %>% 
  select(StepTotal) %>% 
  summary()

weight %>% 
  select(WeightKg, BMI) %>% 
  summary()

calories %>% 
  select(Calories) %>% 
  summary()

intensities %>% 
  select(SedentaryMinutes, LightlyActiveMinutes, FairlyActiveMinutes) %>% 
  summary()

## Summarized data shows that:
## Average steps in a day are 7638.
## The participants are very active for atleast 21 minutes of the day. 
## Sedentary minutes are high for the participants suggesting a poorly active lifestyle. Average sedentary time is 16.5 hours.
## Average calorie burned in a day is 2304 which is appropriate for men. The data is insufficient in terms of demographics of the participant.

# We can create a plot to better understand the relationship between calories burnt and no. of steps taken.

merged_data_1 <- merge(steps, calories, by='Id')
head(merged_data_1)
ggplot(data=merged_data_1) + geom_smooth(mapping =  aes(x=Calories, y=StepTotal))

# We can create a plot to understand most active days

ggplot(data=activities) + geom_point(mapping = aes(x=ActivityDate, y=TotalDistance)) + labs(title = "Most Active days", color="purple")  
  
ggplot(data=activities) + geom_bar(mapping = aes(x=ActivityDate))+
  labs(title = "Most Active days")


#To check the relationship between sleep quality and activities, we will merge the two datasets. 

merged_data_2 <- merge(sleep, activities, by = c('Id', 'date'))
head(merged_data_2) 
#Converting dates to weekday to plot a graph

merged_data_2 <- mutate(merged_data_2, day=wday(SleepDay, label = TRUE))
summarized_sleep_activities <- merged_data_2 %>% 
  group_by(day) %>% 
  summarise(AvgDailySteps = mean(TotalSteps),
            AvgAsleepMinutes = mean(TotalMinutesAsleep),
            AvgAwakeTimeInBed = mean(TotalTimeInBed), 
            AvgSedentaryMinutes = mean(SedentaryMinutes),
            AvgLightlyActiveMinutes = mean(LightlyActiveMinutes),
            AvgFairlyActiveMinutes = mean(FairlyActiveMinutes),
            AvgVeryActiveMinutes = mean(VeryActiveMinutes), 
            AvgCalories = mean(Calories))
head(summarized_sleep_activities)

