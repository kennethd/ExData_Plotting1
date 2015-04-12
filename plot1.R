DATASET_ZIP_URL <- "http://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
LOCAL_ZIP_FILE_NAME <- "exdata-data-household_power_consumption.zip"
LOCAL_TXT_FILE_NAME <- "household_power_consumption.txt"

# just curious about garbage collection as stuff goes out of scope...
memUsage <- function(msg) {
    tryCatch(
        { library(pryr) ; message(paste(msg, mem_used())) },
        error = function(e) { message("could not load pryr for mem_used()") }
    )
}

# download zip file to current dir
downloadZip <- function(zipUrl = DATASET_ZIP_URL, saveAs = LOCAL_ZIP_FILE_NAME) {
    message(paste("downloading", zipUrl, "to", saveAs))
    download.file(zipUrl, saveAs)
}

# extract files from zipFile, download if necessary
extractFiles <- function(zipFile = LOCAL_ZIP_FILE_NAME) {
    if (! file.exists(zipFile)) {
        downloadZip(saveAs = zipFile)
    }
    unzip(zipFile, junkpaths = T)
}

# kenneth@x1:~/git/ExData_Plotting1$ echo "60 * 24" | bc
# 1440                                                         # Number of records we expect per day
# kenneth@x1:~/git/ExData_Plotting1$ grep '^\(1\|2\)/2/2007' household_power_consumption.txt | wc -l
# 2880                                                         # Number of records grep finds for two target days
# kenneth@x1:~/git/ExData_Plotting1$ head -n2 household_power_consumption.txt | tail -n1 | wc -c
# 67                                                           # Size of first record
# kenneth@x1:~/git/ExData_Plotting1$ echo "2075259 * 67 / 1024 / 1024" | bc 
# 132.60112094879150390625                                     # Est. size of full dataset in memory
if (! file.exists(LOCAL_TXT_FILE_NAME)) {
    extractFiles()
}

d <- read.csv(LOCAL_TXT_FILE_NAME, sep = ";", 
              col.names = c("Date", "Time", "Global_active_power", "Global_reactive_power", "Voltage", 
                            "Global_intensity", "Sub_metering_1", "Sub_metering_2", "Sub_metering_3"))

d$Date <- as.Date(d$Date, format = "%d/%m/%Y")
d$Time <- strptime(paste(d$Date, d$Time), format = "%Y-%m-%d %H:%M:%S")
#d$Global_active_power <- as.numeric(d$Global_active_power) 
d <- subset(d, Date >= "2007-02-01" & Date <= "2007-02-02")

# create bar plot of Global Active Power with red bars & labels
png(filename = "plot1.png", height = 480, width = 480)
hist(as.numeric(d$Global_active_power), col = "red", breaks = 16,
     xlab = "Global Active Power (kilowatts)", main = "Global Active Power")
dev.off()
