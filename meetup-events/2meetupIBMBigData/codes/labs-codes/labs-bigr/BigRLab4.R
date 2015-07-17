#___________________________________________________________________________#
# Start BigInsights

# From the Desktop, click on the “Start BigInsights” icon. This action will 
# start up various BigInsights components, including HDFS and Map/Reduce, on
# your machine. A Terminal window will pop up that will indicate progress. 
# Eventually, the Terminal window will disappear. Once done, return to 
# RStudio.

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


