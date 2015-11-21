# Check to see if the directory exists; If it doesn't, create the directory
if(!file.exists("./data")){dir.create("./data")}

# Download the data from the URL and unzip the file into master directory
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url,destfile="./data/Dataset.zip",method="curl")
unzip(zipfile="./data/Dataset.zip",exdir="./data")
path_rf <- file.path("./data" , "UCI HAR Dataset")
files <- list.files(path_rf, recursive=TRUE)
files

# 1. Merge the training and test datasets to create one dataset

# Read training datasets
x_train <- read.table(file.path(path_rf, "train", "x_train.txt"), header=FALSE)
y_train <- read.table(file.path(path_rf, "train", "y_train.txt"), header=FALSE)
subject_train <- read.table(file.path(path_rf, "train", "subject_train.txt"), header=FALSE)

# Read test datasets
x_test <- read.table(file.path(path_rf, "test", "x_test.txt"), header=FALSE)
y_test <- read.table(file.path(path_rf, "test", "y_test.txt"), header=FALSE)
subject_test <- read.table(file.path(path_rf, "test", "subject_test.txt"), header=FALSE)

# Concatenate (Row Bind) the Features datasets
x_data_features <- rbind(x_train, x_test)

# Concatenate (Row Bind) the Activities datasets
y_data_activity <- rbind(y_train, y_test)

# Concatenate (Row Bind) the Subject datasets
subject_data <- rbind(subject_train, subject_test)

# 2. Extract only the measurements on MEAN and STANDARD DEVIATION for each measurement
features<-read.table(file.path(path_rf,"features.txt"), header=FALSE)
extr_mean_std_features <- grep("mean\\(\\)|std\\(\\)", features[,2])
x_data_features <- x_data_features[, extr_mean_std_features]
names(x_data_features)<-features[extr_mean_std_features, 2]

# 3. Use descriptive activity names to name the activities in the data set
activities<-read.table(file.path(path_rf,"activity_labels.txt"), header=FALSE)
y_data_activity[, 1]<- activities[y_data_activity[, 1], 2]
names(y_data_activity)<- "activity"
names(subject_data)<- "subject"

# Column Bind the 3 main files together to create Master File
combined_data<-cbind(subject_data,y_data_activity,x_data_features)

# 4. Appropriately label the dataset with descriptive variable names
names(combined_data)<-gsub("^(t)","time", names(combined_data))
names(combined_data)<-gsub("^(f)","freq", names(combined_data))
names(combined_data)<-gsub("\\()","", names(combined_data))
names(combined_data)<-gsub("mean","Mean", names(combined_data))
names(combined_data)<-gsub("-mean","Mean", names(combined_data))
names(combined_data)<-gsub("-std","StdDev", names(combined_data))
names(combined_data)<-gsub("BodyBody","Body", names(combined_data))
names(combined_data)<-gsub("Mag","Magnitude", names(combined_data))
names(combined_data)<-gsub("Gyro","Gyroscope", names(combined_data))
names(combined_data)<-gsub("Acc","Acceler", names(combined_data))

# 5. Create a second, independent tidy dataset with the average of each variable for each
# activity and each subject
library(plyr)
tidy_ds<-aggregate(. ~subject + activity, combined_data, mean)
tidy_ds<-tidy_ds[order(tidy_ds$subject,tidy_ds$activity),]
write.table(tidy_ds, file="tidydata.txt", row.names=FALSE)
files
