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
d <- subset(d, Date >= "2007-02-01" & Date <= "2007-02-02")

# create line plot of three Sub_metering vars with legend
png(filename = "plot4.png", height = 480, width = 480)
par(mfrow = c(2, 2))

# upper left: line graph of Global Active Power similar to plot 2
plot(x = d$Time, y = d$Global_active_power, type = "l", xlab = "", ylab = "Global Active Power")
axis(side = 1, at = c(unique(d$Date), ""), labels = c("Thu", "Fri", "Sat"))

# upper right: Voltage use by time (line graph)
plot(x = d$Time, y = d$Voltage, type = "l", xlab = "datetime", ylab = "Voltage")
axis(side = 1, at = c(unique(d$Date), ""), labels = c("Thu", "Fri", "Sat"))

# lower left: Energy sub meeting similar to plot 3
plot(x = d$Time, y = d$Sub_metering_1, type = "l", xlab = "", ylab = "Energy sub metering")
lines(x = d$Time, y = d$Sub_metering_2, col = "red")
lines(x = d$Time, y = d$Sub_metering_3, col = "blue")
axis(side = 1, at = c(unique(d$Date), ""), labels = c("Thu", "Fri", "Sat"))
axis(side = 2, at = c(0, 10, 20, 30), labels = c(0, 10, 20, 30))
legend("topright", legend = c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"), 
       col = c("black", "red", "blue"), lty = c(1, 1, 1))

# lower right: Global Reactive Power
plot(x = d$Time, y = d$Global_reactive_power, type = "l", xlab = "datetime", ylab = "Global Reactive Power")
axis(side = 1, at = c(unique(d$Date), ""), labels = c("Thu", "Fri", "Sat"))

dev.off()
