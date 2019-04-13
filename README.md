# GettingandCleaningDataProject

## Course Project Overview

The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected.

The R script called run_analysis.R should be able to do the following:
1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## The R script run_analysis.R

This file provides an explanation on the scrpits used to perform the analysis and come up with a tidy data set.

In the code run_analysis.R, The *UCI HAR Dataset* folder was set as the working directory. Both the **data.table** and **dplyr** package were also called. The **data.table** package was used as it is efficient in handling large data as tables, while the **dply** package was used to aggregate the variables to create the tidy data.
 
    library(data.table)
    library(dplyr)
    setwd("./UCI HAR Dataset")

The train data and test data were called using the **read.table** function and loaded into the variables: xtrain, ytrain, subtrain, xtest, ytest, and subtest.

    xtrain <- read.table("./train/X_train.txt", header = F)
    ytrain <- read.table("./train/y_train.txt", header = F)
    subtrain <- read.table("./train/subject_train.txt", header = F)
    
    xtest <- read.table("./test/X_test.txt", header = F)
    ytest <- read.table("./test/y_test.txt", header = F)
    subtest <- read.table("./test/subject_test.txt", header = F)

Using the **read.table** function, the supporting metadata in this data were also read and assigned to ActLabels and Features.

    ActLabels <- read.table("./activity_labels.txt", header = F)
    Features <- read.table("./features.txt", header = F)

The respective data in the training and test datasets corresponding to subject, activity and features were then combined using the **rbind** function. The results are stored in the dataframes ActivityData, FeaturesData, and SubjectData.

    ActivityData <- rbind(ytest, ytrain)
    FeaturesData <- rbind(xtest, xtrain)
    SubjectData <- rbind(subtest, subtrain)

The columns in the dataframes were assigned new names.

    names(ActivityData) <- "ActivityN"
    names(ActLabels) <- c("ActivityN", "Activity")
    Activity <- left_join(ActivityData, ActLabels, "ActivityN")[, 2]
    names(ActLabels) <- c("ActivityN", "Activity")
    names(SubjectData) <- "Subject"
    names(FeaturesData) <- Features$V2

To create one complete data set, the three dataframes (SubjectData, Activity, and FeaturesData) were combined using the **cbind** function. The data set can be viewed with the **view** function

    DataSet <- cbind(SubjectData, Activity, FeaturesData)
    View(DataSet)
    
A new data set containing only the mean and standard deviation for each measurement is made using subsetting scripts. Only certain columns were called into this function to filter out unnecessary data. Again, this new data set can be viewed with the **view** function

    SubFeatures <- Features$V2[grep("mean\\(\\)|std\\(\\)", Features$V2)]
    DataNames <- c("Subject", "Activity", as.character(SubFeatures))
    DataSet2 <- subset(DataSet, select=DataNames)
    View(DataSet2)
  
The columns of the data set is then given appropriate labels with more descriptive variable names. The **gsub** function is used to replace all matches of a string with a new string name.
 
    names(DataSet2)<-gsub("^t", "time", names(DataSet2))
    names(DataSet2)<-gsub("^f", "frequency", names(DataSet2))
    names(DataSet2)<-gsub("Acc", "Accelerometer", names(DataSet2))
    names(DataSet2)<-gsub("Gyro", "Gyroscope", names(DataSet2))
    names(DataSet2)<-gsub("Mag", "Magnitude", names(DataSet2))
    names(DataSet2)<-gsub("BodyBody", "Body", names(DataSet2))
    
Finally, the **aggregate** function is used to combine all the relevant data entries to create a data set with the average of each variable for each activity and subject. This data set named TidyDataSet is the final output. We can look at the final tidy data set with the **view** function. 

    TidyDataSet<-aggregate(. ~Subject + Activity, DataSet2, mean)
    TidyDataSet<-TidyDataSet[order(TidyDataSet$Subject,TidyDataSet$Activity),]
    View(TidyDataSet)

As instructed, the data set is written as a data file TidyData.txt.

    write.table(TidyDataSet, file = "TidyData.txt",row.name=FALSE)
