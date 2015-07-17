#___________________________________________________________________________#
# Back to RStudio

# Return to RStudio session in the browser. When in Rstudio, you can use the 
# F11 key to go into "Full Screen" mode. This will maximize your viewing
# area. Use F11 again to go back to the original view.

# From within RStudio, run the following statements.

setwd("~/labs-bigr")      # change directory

rm(list = ls())           # clear workspace


#___________________________________________________________________________#
# Load Big R
# Load the Big R package into your R session.
library(bigr)


#___________________________________________________________________________#
# Connect to BigInsights

# Note how one needs to specify the right credentials for this call.
bigr.connect(host="localhost", port=7052, 
             user="biadmin", password="biadmin")

# Verify that the connection was successful.
is.bigr.connected()    

# If you ever lose your connection during these exercises, run the following
# line to reconnect. You can also invoke bigr.connect() as we did above.
bigr.reconnect()


#___________________________________________________________________________#
# Browse files on HDFS

# Once connected, you will be able to browse the HDFS file system and examine
# datasets that have already been loaded onto the cluster.

bigr.listfs()                     # List files under root "/"

bigr.listfs("/user/biadmin")      # List files under /user/biadmin


#___________________________________________________________________________#
# Connect to a big data set

# "/user/biadmin/airline_lab.csv" is one of the datasets that you will see. 
# This is a comma-delimited file (type = "DEL"). Let's "connect" to it and 
# explore it a bit. This is done by creating a bigr.frame over the dataset. A
# bigr.frame is an R object that mimics R's own data.frame. However, unlike
# R, a bigr.frame does not load that data in memory as that would be 
# impractical. The data stays in HDFS. However, you will still be able to 
# explore this data using the Big R API.

air <- bigr.frame(dataSource="DEL", 
                  dataPath="/user/biadmin/airline_lab.csv",header=TRUE)

# Check that "air" is an object of "bigr.frame"
class(air)


#___________________________________________________________________________#
# Exploring table metadata

# Examine the structure of the dataset. Note that the output looks very 
# similar to R's data.frames. The dataset has 29 variables (i.e. columns). 
# The first few values of each column are also shown. Examine the columns and
# see what they may possibly represent.
str(air)


#___________________________________________________________________________#
# Column types

# Notice that the column types are all "character" (abbreviated as "chr"). 
# Unless specified otherwise, Big R automatically assumes all data to be 
# strings. However, we know that only columns Year (1), Month (2), 
# UniqueCarrier (9), TailNum (11), Origin (17), Dest (18), CancellationCode 
# (23) are strings, while the rest are numbers. Let us assign the correct
# column types. 

# First, we build a vector that holds the column types for all columns
ct <- ifelse(1:29 %in% c(1,2,9,11,17,18,23), "character", "integer")
print(ct)

# Assign the column types
coltypes(air) <- ct


#___________________________________________________________________________#
# Data dimensions

# This data originally comes from US Department of Transportation 
# (http://www.rita.dot.gov), and it provides us information on every US 
# flight over the past couple of decades. The original data has approximately
# 125+ million rows. For this lab, we're only using a small sample. Let us
# examine the dimensions of the dataset.

nrow(air)     # Number of rows (i.e. flights) in the data
ncol(air)     # Number of attributes recorded for each flight


#___________________________________________________________________________#
# Summarizing frames

# Let us summarize some key columns to gain further understanding of this 
# data. You'll see that the years range from 1987-2008.
summary(air[, c("Year", "Month", "UniqueCarrier")])


#___________________________________________________________________________#
# Summarizing vectors and basic visualization

# Summarizing columns one by one will give us additional information. In some
# cases, we will also visualize the information.

# The following statement shows us the distribution of flights by year. 
# Again, we have 22 years worth of data. What you will see is a vector that
# has the "year" for the name, and the flight count for the values.

summary(air$Year)

# Let us glue Big R's summary() with R's visualization capabilities to see 
# the same data distribution graphically. Before you do this, make sure the 
# "Plots" window (lower right hand pane of RStudio) is in view, and that it 
# is sized big enough to display the plot. We see that the flight volume has 
# gradually increased over the years. Feel free to "Zoom" the plot to pop up 
# a separate window. To close the popped-up window, press "Ctrl F4".

barplot(summary(air$Year))                # Visualize it!


# Similarly, we can also examine the distribution of flights by airline 
# (UniqueCarrier). We have 29 airlines in this dataset, including United
# (UA), Delta (DL), and many others.

summary(air$UniqueCarrier)

# Again, visualizing the data will give us a better perspective. We will use 
# Big R to aggregate the data, sort it, and then plot it. Can you tell which
# airlines have the most # of flights? Which ones have the least? Does this
# resonate with your own experience? Again, you can "Zoom" the plot window
# for a better view, and close it when done.

barplot(sort(summary(air$UniqueCarrier)))


# Try summarizing some of the other columns (i.e. vectors) such as
# Distance, Orig, Dest, etc. What does this tell you?
summary(air$Distance)                    


#___________________________________________________________________________#

# Attaching bigr.frame to R search path

# Notice how we used the expression "air$" to reference various columns.
# Similar to R's data.frames, you can attach a bigr.frame ('air') to R search
# path. This will make it easy for us to reference columns without requiring 
# a prefix.
attach(air)


#___________________________________________________________________________#
# Drilling down

# Over the next few exercises, let's drill down into the data and ask 
# specific questions. These exercises will demonstrate that the Big R API on 
# bigr.frames closely mirrors the R API on data.frames.

# Of the 128790 flights in all, how many were flown by American, South West
# and Delta?
length(UniqueCarrier[UniqueCarrier %in% c("AA", "WN", "DL")])

# How many flights were delayed by more than 15 minutes on departure?
length(DepDelay[DepDelay >= 15])

# How many flights flew between San Francisco and LA?
nrow(air[Origin %in% c("SFO", "LAX") 
         & Dest %in% c("SFO", "LAX"),])


#___________________________________________________________________________#
# Detaching bigr.frame

# Let us detach 'air' from the R search path. After this step, we will need
# to specify a complete prefix to reference columns in a bigr.frame.
detach(air)


#___________________________________________________________________________#
# Selections and projections

# Let us filter the data set for flights that were delayed by more than 15 
# minutes at departure or arrival. In addition, we will only project a few 
# columns. We will call the new object "airSubset". Note how this syntax is 
# identical to an equivalent formulation on R's data.frames. It looks and 
# feels like we're operating against data.frames, except we're seamlessly
# going against data in BigInsights.

airSubset <- air[air$Cancelled == 0
                  & (air$DepDelay >= 15 | air$ArrDelay >= 15),
                  c("UniqueCarrier", "Origin", "Dest", "DepDelay", "ArrDelay")]


# Examine the class of the newly created object. It is also a bigr.frame 
# that's been derived from the original "air" bigr.frame. 
class(airSubset)


#___________________________________________________________________________#
# Operations on derived frames

# Big R does not actually materialize the derived dataset on the BigInsights 
# server. The selections and projections are performed "on the fly" against 
# the original data. In the following exercises, we'll use the "airSubset" to
# perform some queries.

# Examine the dimensions of the new frame. That's 29230 rows and 5 columns.
dim(airSubset)

# Examine 5 rows. Note that either the arrival or the departure delay is 15+
# minutes.
head(airSubset, 5)

# What percentage of flights were delayed overall? 22.7% is the answer.
nrow(airSubset) / nrow(air)

# What percentage of Hawaiian Airlines flights were delayed? 7.4% is much 
# lesser than the system-wide delay of 22.7%. The results are not surprising.
# The islands have shorter flights and good weather, and these factors
# probably lend themselves to a lower delay rate. Again, note that we Big R
# expressions closely mirror equivalent R expressions.
haFlightsDelayed <- airSubset[airSubset$UniqueCarrier %in% c("HA"),]
haFlights <- air[air$UniqueCarrier == "HA",]
nrow(haFlightsDelayed) / nrow(haFlights)


#___________________________________________________________________________#
# Sorting

# Besides selections and projections, Big R supports other relational 
# operations such as projecting derived columns, sorting, aggregations, 
# joining and duplicate elimination. Some of these operations are covered in 
# the later sections of this lab. For the moment, let us see how sorting
# works in Big R.

# Which were the "longest" flights based on on distance flown? Here, Big R 
# generates another derived bigr.frame ("bf") that holds the result of the 
# sort. Again, the sort itself is performed on the fly and the results are
# not materialized unless so desired.
bf <- bigr.sort(air, by = air$Distance, decreasing = T)
bf <- bf[,c("Origin", "Dest", "Distance")]
class(bf)

# Examine the top 6 rows. Not surpringly, flights from the east coast
# cities to Hawaii are the longest.
head(bf)


#___________________________________________________________________________#
# Aggregations

# In the earlier exercises, we summarized bigr.frame and bigr.vectors. Big R 
# provides a more powerful mechanism to compute specific aggregates. Using 
# R's formula notation, one can specify columns to aggregate along with any 
# grouping constructs. An R formula is an expression of type "LHS ~ RHS". For
# our purposes, on the LHS (left-hand-side), we specify the columns we're 
# interested in, and what aggregation functions need to be computed on those 
# columns. On the RHS (right-hand-side), we specify any grouping. To compute
# aggregates on the entire data, use a dot (.).


# What's the mean flying distance and mean flying time for all airlines? If
# you know SQL, the following query is equivalent to "select avg(Distance),
# avg(CRSElapsedTime) from air". It tells us that the average flight flew
# ~701 miles, and took about 2 hours.
formula <- mean(Distance) + mean(CRSElapsedTime) ~ .
summary(air, formula)


# What is the # of flights, mean flying distance and mean flying time per
# airline? This yields a table of 29 airlines. The Distance is in miles,
# while the time is in minutes.
summary(air, count(.) + mean(Distance) + mean(ActualElapsedTime) 
        ~ UniqueCarrier)


#___________________________________________________________________________#
# Visualizing data using box plots

# Let's use R's visualization capabilities to plot the distribution of flying
# distance per airline. This plot provides us some of the same information we
# gathered a few minutes ago. The picture tells us that HA (Hawaiian) and AQ
# (Aloha) have the smallest median flying distance, which is expected because
# inter-island flights in Hawaii are around ~30 mins per flight.

bigr.boxplot(air$Distance ~ air$UniqueCarrier)  +
    labs(title = "Distance flown by Airline")


#___________________________________________________________________________#
# Visualizing big data using heatmaps

# How about producing a "heatmap" that shows how the flight volume was 
# distributed across the calendar year. We'll pick 3 years, say 2000, 2001 
# and 2002. But before we do so, let us load a plotting function that will 
# produce the heatmap for us.

source("calendarHeat.R")

# Use Big R to filter the years we need.
air2 <- air[air$Cancelled == 0
            & (air$Year == "2000" | air$Year == "2001" | air$Year == "2002"),]

# Summarize flight volume by Year, Month and Day
df <- summary(air2, count(Month) ~ Year + Month + DayofMonth)

# Build the "date" string as a separate column
df$DateStr <- paste(df$Year, df$Month, df$DayofMonth, sep="-");


# Plot the graph, and zoom it out. Do you notice any patterns? Any anomalies?
# Do you notice a white spot in the middle of the chart? Do you know why
# that spot is white?
calendarHeat(df$DateStr, df[,4] * 100, varname="Flight Volume")


#___________________________________________________________________________#
# Visualizing big data using histograms

# Let's examine the distribution of flights by hour. bigr.histogram() is a 
# utility method that computes histogram statistics on BigInsights, and uses 
# R package "ggplot2" to render the plot. This plot shows the flight volume 
# for every hour in the day. Notice how very few flights take off in the
# early morning hours. Majority of the flight volume comes between 7AM - 7PM,
# with the volume tapering off after 8 PM.

bigr.histogram(air$DepTime, nbins=24) +
    labs(title = "Flight Volume (Arrival) by Hour")


#___________________________________________________________________________#
# Visualizing big data using geographical maps

# How about plotting the routes that have the most flights flown? First,
# let us load the functions that render a US map.

source("mapRoutes.R")

# To our original bigr.frame, "air", add two columns that represent the
# city pairs.
air2 <- air
air2$City1 <- ifelse(air2$Origin < air2$Dest, air2$Origin, air2$Dest)
air2$City2 <- ifelse(air2$Origin >= air2$Dest, air2$Origin, air2$Dest)

# Compute the frequency of flights between all city pairs
df <- summary(count(UniqueCarrier) ~ City1 + City2, object = air2)
flights <- df[order(df[,3], decreasing=T), ][1:15,]
print(flights)
colnames(flights) <- c("airport1", "airport2", "cnt")

# Plot the data! This plot works best if you were to maximize the size
# of the plot window before executing the following statement.
mapRoutes(flights)


#___________________________________________________________________________#
# Free experimentation

# We're at the end of this set of exercises. Use your knowledge of R and 
# data.frames to formulate more queries against the "air" dataset. 
# Alternatively, move to the next set of exercises in "BigRLab6.R"




