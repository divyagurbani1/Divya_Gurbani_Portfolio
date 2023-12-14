install.packages("tidyverse")
install.packages("readr")
install.packages("dplyr")
install.packages("skimr")
install.packages("janitor")
install.packages("lubridate")
install.packages("ggplot2")

library(tidyverse)
library(readr)
library(dplyr)
library(skimr)
library(janitor)
library(lubridate)
library(ggplot2)

##Loading data from (https://www.kaggle.com/arashnic/fitbit)
##Creating readable dataframes

activities<-daily_activity
View(activities)

intensities <- hourly_intensities
calories <- daily_calories
sleep <- sleep_day
steps <- daily_Steps
weight <- weight_logInfo

View(intensities)
View(sleep)
View(steps)
View(weight)
View(activities)

#Understanding datasets

str(activities)
str(sleep)
str(steps)
str(weight)
str(intensities)
str(calories)

#We can see that data type of date columns is character in all the datasets. We need to change it to date and time. 
#To do this, we will us POSIXct()
activities$ActivityDate = as.POSIXct(activities$ActivityDate, format = "%m/%d/%Y", tz=Sys.timezone())
activities$date <- format(activities$ActivityDate,format = "%m/%d/%Y")

#sleep
sleep$SleepDay = as.POSIXct(sleep$SleepDay, format = "%m/%d/%Y %H:%M:%S", tz=Sys.timezone())
sleep$date <- format(sleep$SleepDay, format="%m/%d/%Y")

#intensities
intensities$ActivityHour = as.POSIXct(intensities$ActivityHour, format="%m/%d/%Y %H:%M:%S %p", tz=Sys.timezone())
intensities$time <- format(intensities$ActivityHour, format = "%H:%M:%S")
intensities$date <- format(intensities$ActivityHour, format = "%m/%d/%y")

#The data is cleaned, manipulated and ready for analysis.
install.packages("dplyr")

#we will start with understanding the overall summary of the data

activities %>% 
  select(TotalDistance, VeryActiveMinutes, LightlyActiveMinutes, FairlyActiveMinutes, SedentaryMinutes) %>% 
  summary()
#Mahority of the participants were lightly active for an average of 3.2 hrs per day.
weight %>% 
  group_by(Id) %>% 
  summarise(min(WeightKg), max(WeightKg), mean(WeightKg))

intensities %>% 
  select(TotalIntensity, AverageIntensity) %>% 
  summary()

calories %>%
  select(Calories) %>%
  summary()

#The mean calory intake is 2304

sleep %>%
  select(TotalSleepRecords, TotalMinutesAsleep, TotalTimeInBed) %>%
  summary()
# It is evident that average sleeping time is ~7 hrs. 
weight %>%
  select(WeightKg, BMI) %>%
  summary()

#It can be seen that there is no significant difference in weights of partcipants. 

#To understand the relationships between activity and calories burnt we will plot a graph.

ggplot(data=activities, aes(x=TotalSteps, y=Calories)) + geom_point() + geom_smooth() + 
  labs(title = "Steps V/s Calories burned", color="red") 

# There seems a positive correlation between steps taken and calories burned.

#We will merge the dataframes activities and sleep to understand the impact of workout on sleep.

merged_data_1 <- merge(activities, sleep, by = c("Id", "date"))
head(merged_data_1)

ggplot(data = merged_data_1, aes(x=TotalDistance, y=TotalMinutesAsleep)) + geom_point()+
  labs(title="Total Distance walked  V/s Sleep Duration") + geom_smooth()

#we cannot identify any relationship with this plot. Now we will create a plot between sedentary minutes and sleep duration


ggplot(data = merged_data_1, aes(x=SedentaryMinutes, y=TotalMinutesAsleep)) + geom_point()+
  labs(title="Sedentary Minutes V/s Sleep Duration") + geom_smooth()
#From the graph it is clear that there is a negative relationship.

cor(merged_data_1$SedentaryMinutes, merged_data_1$TotalMinutesAsleep)
#the correlation is -0.599394

#to check whether day of the week affects activity levels and sleep quality we will create a plot

#to have day of weeks from dates
merged_data_1 <- mutate(merged_data_1, day = wday(SleepDay, label = TRUE))

activities_sleep <- merged_data_1 %>% 
  group_by(day) %>% 
  summarise(AvgDailySteps = mean(TotalSteps),
            AvgAsleepMinutes = mean(TotalMinutesAsleep),
            AvgAwakeTimeInBed = mean(TotalTimeInBed), 
            AvgSedentaryMinutes = mean(SedentaryMinutes),
            AvgLightlyActiveMinutes = mean(LightlyActiveMinutes),
            AvgFairlyActiveMinutes = mean(FairlyActiveMinutes),
            AvgVeryActiveMinutes = mean(VeryActiveMinutes), 
            AvgCalories = mean(Calories))
head(activities_sleep)

ggplot(data=activities_sleep, mapping=aes(x=day, fill=day)) + geom_bar() 

ggplot(data=activities_sleep, mapping = aes(x = day, y = AvgDailySteps, fill = day)) +
  geom_col() + labs(title = "Daily Step Count") + labs(title = "Activity levels in the week", color = "red",fontface = "bold")+
  guides(fill = guide_legend(title = "Days"))

#The graph shows that participants are most active on saturdays and least on sundays. 


  