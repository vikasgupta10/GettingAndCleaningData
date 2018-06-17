library(dplyr)
library(data.table)
# This script,run_analysis.R, does the following.
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with 
#    the average of each variable for each activity and each subject.


if(!file.exists("./data")){dir.create("./data")}
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url,destfile="./data/Dataset.zip",method="curl")

path_rf <- file.path(getwd() , "UCI HAR Dataset")
path_rf
files<-list.files(path_rf, recursive=TRUE)
files

#Read the Activity files

dataActivityTest  <- read.table(file.path(path_rf, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(path_rf, "train", "Y_train.txt"),header = FALSE)

head(dataActivityTest)
head(dataActivityTrain)

str(dataActivityTest)
str(dataActivityTrain)


#Read the Subject files

dataSubjectTrain <- read.table(file.path(path_rf, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(path_rf, "test" , "subject_test.txt"),header = FALSE)

head(dataSubjectTrain)
head(dataSubjectTest)

str(dataSubjectTrain)
str(dataSubjectTest)


#Read Fearures files

dataFeaturesTest  <- read.table(file.path(path_rf, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(path_rf, "train", "X_train.txt"),header = FALSE)

head(dataFeaturesTest,1)
head(dataFeaturesTrain,1)

str(dataSubjectTest)
str(dataFeaturesTrain)

#question 1 -Merges the training and the test sets to create one data set.

#1.Concatenate the data tables by rows


dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)

#2.set names to variables


names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(path_rf, "features.txt"),head=FALSE)
str(dataFeaturesNames)
names(dataFeatures)<- dataFeaturesNames$V2

#3.Merge columns to get the data frame Data for all data

dataCombine <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, dataCombine)
str(Data)
head(Data,2)

#question 2. Extracts only the measurements on the mean and standard deviation for each measurement.


subdataFeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]

selectedNames<-c(as.character(subdataFeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)

str(Data)

#question 3 : subActFeatures_both with descriptive activies names


activityLabels <- read.table(file.path(path_rf, "activity_labels.txt"),header = FALSE)
activityLabels 
activityLabels <- as.character(activityLabels[,2])
Data$activity <- activityLabels[Data$activity]

names(Data)
head(Data,2)
head(Data$activity,30)


#question 4 :data set with descriptive variable names.

names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))

names(Data)


#question 5 :tidy data set with the average of each variable for each activity and each subject

library(plyr);
Data2<-aggregate(. ~subject + activity, Data, mean)
Data2<-Data2[order(Data2$subject,Data2$activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)


