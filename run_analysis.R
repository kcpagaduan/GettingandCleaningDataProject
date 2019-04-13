library(data.table)
library(dplyr)

setwd("./UCI HAR Dataset")

xtest <- read.table("./test/X_test.txt", header = F)
ytest <- read.table("./test/y_test.txt", header = F)
subtest <- read.table("./test/subject_test.txt", header = F)

xtrain <- read.table("./train/X_train.txt", header = F)
ytrain <- read.table("./train/y_train.txt", header = F)
subtrain <- read.table("./train/subject_train.txt", header = F)

ActLabels <- read.table("./activity_labels.txt", header = F)
Features <- read.table("./features.txt", header = F)

ActivityData <- rbind(ytest, ytrain)
FeaturesData <- rbind(xtest, xtrain)
SubjectData <- rbind(subtest, subtrain)

names(ActivityData) <- "ActivityN"
names(ActLabels) <- c("ActivityN", "Activity")
Activity <- left_join(ActivityData, ActLabels, "ActivityN")[, 2]
names(ActLabels) <- c("ActivityN", "Activity")
names(SubjectData) <- "Subject"
names(FeaturesData) <- Features$V2

DataSet <- cbind(SubjectData, Activity, FeaturesData)
View(DataSet)

SubFeatures <- Features$V2[grep("mean\\(\\)|std\\(\\)", Features$V2)]
DataNames <- c("Subject", "Activity", as.character(SubFeatures))
DataSet2 <- subset(DataSet, select=DataNames)
View(DataSet2)

names(DataSet2)<-gsub("^t", "time", names(DataSet2))
names(DataSet2)<-gsub("^f", "frequency", names(DataSet2))
names(DataSet2)<-gsub("Acc", "Accelerometer", names(DataSet2))
names(DataSet2)<-gsub("Gyro", "Gyroscope", names(DataSet2))
names(DataSet2)<-gsub("Mag", "Magnitude", names(DataSet2))
names(DataSet2)<-gsub("BodyBody", "Body", names(DataSet2))
View(DataSet2)

TidyDataSet<-aggregate(. ~Subject + Activity, DataSet2, mean)
TidyDataSet<-TidyDataSet[order(TidyDataSet$Subject,TidyDataSet$Activity),]
View(TidyDataSet)

write.table(TidyDataSet, file = "TidyData.txt",row.name=FALSE)