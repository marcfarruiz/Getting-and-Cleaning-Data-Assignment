library(dplyr)
library(data.table)

#read test data

subject_test <- read.table("./UCI HAR Dataset/test/subject_test.txt")
x_test <- read.table("./UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./UCI HAR Dataset/test/Y_test.txt")

#read train data

subject_train <- read.table("./UCI HAR Dataset/train/subject_train.txt")
x_train <- read.table("./UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("./UCI HAR Dataset/train/Y_train.txt")

#read features data

features <- read.table("./UCI HAR Dataset/features.txt")

activity_labels <- read.table("./UCI HAR Dataset/activity_labels.txt") 


#merging test and training data

x <- rbind(x_test,x_train)
y <- rbind(y_test, y_train)
subject <- rbind(subject_test,subject_train)

merged_data <- cbind(subject,y,x)


#we rename the columns to avoid having 3 variables named v1
names(merged_data) <- c("subject", "V1", features$V2)
colNames <- colnames(merged_data)

#we extract the columns that contain measurements on mean and std. We add the \\(\\)
#to ignore the columns like meanFreq and search "mean()"
mean_std_cols <- grep(".*mean\\(\\).*|.*std\\(\\).*", colNames, ignore.case=TRUE)

#we extract the table with only the desired columns (subject, activity, mean and std)
mean_std <- merged_data[c(1,2,mean_std_cols)]

#Changing the code into the descriptive activity name
data_with_activities <- select(merge(activity_labels, mean_std, by = "V1"), -V1)

#We change the name of the 'activity' variable to have all variables with descriptive names
names(data_with_activities)[1] <- "activity"

# turn activities & subjects into factors 
data_with_activities$activity <- as.factor(data_with_activities$activity) 
data_with_activities$subject  <- as.factor(data_with_activities$subject) 

#we group data by activity and subject to make the mean
data <- data.table(data_with_activities)
tidyData <- data %>% group_by(activity,subject) %>% summarize_all(mean)

#creation of the tidy data table
write.table(tidyData, "tidyData.txt", row.name=FALSE)
