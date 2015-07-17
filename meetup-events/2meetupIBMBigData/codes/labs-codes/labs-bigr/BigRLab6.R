#___________________________________________________________________________#
# Back to RStudio

# Return to RStudio session in the browser. When in Rstudio, you can use the 
# F11 key to go into "Full Screen" mode. This will maximize your viewing
# area. Use F11 again to go back to the original view.

# From within RStudio, run the following statements.

setwd("~/labs-bigr")                           # change directory

rm(list = ls())                                # clear workspace

library(bigr)                                  # Load Big R package

bigr.connect(host="localhost", port=7052,      # Connect to BigInsights
             user="biadmin", password="biadmin")


# Once again, define a bigr.frame over the "airline" dataset. Note how we can
# specify column types in this call.
air <- bigr.frame(dataSource="DEL", 
                  dataPath="/user/biadmin/airline_lab.csv",
                  coltypes=ifelse(1:29 %in% c(1,2,9,11,17,18,23), 
                                  "character", "integer"))

#___________________________________________________________________________#
# Preparation for modeling

# Big R supports in-database analytics. This implies that instead of bringing
# large amounts of data to your R clients, Big R can ship R code to the 
# BigInsights server and run it directly on the data.
# 
# To explore this concept, let's build a simple set of "decision tree" 
# models. Our models will predict flight arrival delay (ArrDelay) based on 
# 'DepDelay', 'DepTime', 'CRSArrTime' and 'Distance' as the predictor 
# variables. If this were a real-world exercise, the model will take many 
# more variables into account. However, in the interest of time, we will 
# limit our predictors to this small set.

# To keep things simple, let us build the models for two airlines, say United
# and Hawaiian. Filter the airline data appropriately.
airfilt <- air[air$UniqueCarrier %in% c("HA", "UA"),]

#___________________________________________________________________________#
# Computing correlation matrix

# Before we start building models, let's see if there's any correlation 
# between the pairs of columns we've selected. We'll use Big R's cor() method
# to compute Pearson's correlation coefficients. This function is identical 
# to the equivalent function on data.frames.
corr <- cor(airfilt[,c("ArrDelay", "DepDelay", 
                       "DepTime", "CRSArrTime", "Distance")])

# Print the correlation matrix. Looks like ArrDelay is strongly correlated 
# (0.911403248) with DepDelay (which is to be expected). In addition, 
# departure time (DepTime) and arrival time (ArrTime) are also somewhat 
# correlated (0.69462876). Interestingly, the Distance flown has almost no
# bearing on the ArrDelay and DepDelay
print(corr)


#___________________________________________________________________________#
# Make training and test sets

# When building models, an established practice is to use only a subset of 
# the data to train the model, while the rest is used for testing/validation.
# Using random sampling support in Big R, let  us split the data in "airfilt"
# into training set (~70%) and test set (~30%).

splits <- bigr.sample(airfilt, c(0.7, 0.3))

#___________________________________________________________________________#
# Examine the splits

# We now have two bigr.frame objects that represents the training and test
# sets.

class(splits)                       # splits is a "list" ... 

length(splits)                      # ... with two elements 

# Define two new variables for the two bigr.frames.
train <- splits[[1]]
test <- splits[[2]]

# Check the class of the objects
class(train)
class(test)

# Check if we roughly got the right split percentages.
nrow(train) / nrow(airfilt)         # Approximately 70%
nrow(test) / nrow(airfilt)          # Approximately 30%


#___________________________________________________________________________#
# Decision tree model

# Let us write an R function that builds a decision-tree model.
# 
# Line 1: Define the function signature. The function takes on a parameter, 
# df. "df" represents the data that will be used to build the model.
# 
# Line 2: The decision-tree algorithm comes to us from the open-source 
# package "rpart". This package has been previously installed on the 
# machine. This package needs to be loaded from within the function.
# 
# Lines 3-4: Define all the columns we're interested in. This includes the 
# reponse variable ("ArrDelay") and the predictors.
# 
# Line 5: Build the model. The expression "ArrDelay ~ ." is an R formula. It 
# indicates to R that ArrDelay is the response variable, while every other 
# column (.) is a predictor. The expression "df[,predcols]" projects only the
# needed columns.
# 
# Line 6: The model, which is an object of class "rpart", is returned by the 
# function.
# 

buildmodel <- function(df) {                                # line 1
    library(rpart)                                          # line 2
    predcols <- c('ArrDelay', 'DepDelay', 'DepTime',        # line 3
                  'CRSArrTime', 'Distance')                 # line 4
    model <- rpart(ArrDelay ~ ., df[,predcols])             # line 5
    return(model)                                           # line 6
}

#___________________________________________________________________________#
# Partitioned execution using groupApply

# Now, we will build several decision-tree models, one per airline
# 
# If you are familiar with R's "apply" functions, including lapply() and 
# tapply(), the Big R's groupApply() will look familiar to you. groupApply() 
# needs three things - the data, the grouping columns, and the R function to 
# call.

# Line 1: We're building models on the training set, i.e., "train"
# Line 2: Since we're interested in building one model per airline, we
#         group by UniqueCarrier
# Line 3: The R function we created above

# Run the following lines. It will take around 10-15 seconds to build the 
# models on a single-node cluster such as the one you're running on.

models <- groupApply(data = train,                                 # line 1
                     groupingColumns = train$UniqueCarrier,        # line 2
                     rfunction = buildmodel)                       # line 3

#___________________________________________________________________________#
# Examining the models

# groupApply() builds the models and stores them on BigInsights itself.
# We're presented with a bigr.list object that provides us access to the
# models.
class(models)

# The bigr.list, 'models', has two elements in it. The "group" column 
# indicates the value of the grouping column. The "status" column indicates 
# whether or note the execution of the R function was successful on that 
# group
print(models)


#___________________________________________________________________________#
# Pulling models to the client

# We can pull one or both models from BigInsights. This statement brings the 
# model for Hawaiian Airlines (models$HA) from the server and loads it into 
# the memory of your current R session. Note how the grouping column values 
# can be used to reference elements of the bigr.list (models).

modelHA <- bigr.pull(models$HA)

# Examine the model we retrieved from the cluster
class(modelHA)

print(modelHA)

# Visualize the model. You may want to enlarge the RStudio plot window so the
# graph fits. Note that the model has "strong" references to DepDelay, and 
# weak references to some of the other predictors. Some of the columns are 
# not even included in the model. What this is seemingly telling us is that 
# flight arrival delay is mostly dependent on whether the flight was late
# taking off.
source("~/labs-bigr/prettyTree.R")
prettyTree(modelHA)

#___________________________________________________________________________#
# Making predictions - Write the scoring function

# Now that our models have been created, we need to use them to make 
# predictions. Let's write another function that scores our models. In our
# case, scoring involves predicting arrival delay (ArrDelay) for flights.

# Study the following function carefully:
# Line 1: The function signature takes two parameters. 'df' is the data
# that we're scoring. 'models' is a bigr.list that contains the models
# Line 2: Load the library rpart
# Line 3: Extract out model that represents our carrier
# Line 4: Load the model from BigInsights and materialize it in R's memory
# Line 5: Do the actual prediction on each row in 'df' using 'model'
# Line 6: Return one row for each input flight. Each row has the following
# columns - Carrier, DepDelay, ArrDelay, Predicted Arrival Delay
scoreModels <- function(df, models) {                                   # line 1
    library(rpart)                                                      # line 2
    carrier <- df$UniqueCarrier[1]                                      # line 3
    model <- bigr.pull(models[carrier])                                 # line 4
    prediction <- predict(model, df)                                    # line 5
    return(data.frame(carrier, df$DepDelay, df$ArrDelay, prediction))   # line 6
}


#___________________________________________________________________________#
# Making predictions - Run the scoring

# Since we've built one model per airline, it makes sense for us to partition
# the test set by airline as well. Therefore, we'll use groupApply() again,
# and use the same grouping column as before (UniqueCarrier). As an added
# twist, we will subpartition each group in 2 batches. This batching allows
# Big R to split the input group into smaller chunks that can be easily
# managed by the R instances that are spawned on the server.

# Add a new column to "test". This column will have a value of either 0 or 1.
test$batch <- as.integer(bigr.random() * 2)

# Check that we have 4 groups, two for each airline. Also check that
# each batch has approximately the same # of rows.
summary(count(.) ~ UniqueCarrier + batch, object = test)

# Execute the groupApply function.
#
# Line 1: The input data is the test set
# Line 2: List of grouping columns, UniqueCarrier + Batch
# Line 3: The scoring function to invoke on each group
# Lines 4-8: The "shape" of the output of the scoring function. Earlier, we 
# defined the scoring function to return a data.frame with a specified number
# of columns and their corresponding types. That information needs to be
# provided to groupApply() as well.
# Line 8: Parameter that will be passed on from groupApply() to
# "scoreModels". In this case, it's our models object.

# This call will take 15-20 seconds. Internally, BigInsights spawns 4 R 
# instances, one for each partition. Since we're on a single-node cluster 
# these instances work in a serial fashion.

preds <- groupApply(test,                                          # line 1
                    list(test$UniqueCarrier, test$batch),          # line 2
                    scoreModels,                                   # line 3
                    signature=data.frame(carrier='Carrier',        # line 4
                                         DepDelay=1.0, 
                                         ArrDelay=1.0, 
                                         ArrDelayPred=1.0,
                                         stringsAsFactors=F),      # line 8
                    models)                                        # line 9

# The predictions are materialized on the cluster. As we've seen in other
# instances, Big R returns a bigr.frame object that holds the rows. Let's
# examine the dimensions and contents of our predictions.

# We should have the same # of rows in "preds" as we have in the "test" set.
print(nrow(preds))
print(nrow(test))

# Examine 5 predictions from the top. See what the actual "ArrDelay" was,
# and what our models predicted ("ArrDelayPred"). Do our predictions sound
# reasonable? It's hard to say with just 5 rows.
head(preds, 5)

#___________________________________________________________________________#
# Check model quality

# To assess our models accurately, we'll rely on the frequently used metric
# called RMSD. RMSD (root mean squared deviation) is a measure of the
# differences between values predicted by a model and the values actually
# observed.

# Wit Big R, we can easily compute RMSD using the following expression 
# executed against the "preds" bigr.frame that resides in BigInsights.

rmsd <- sqrt(sum((preds$ArrDelay - preds$ArrDelayPred) ^ 2) / nrow(preds))

# What's our RMSD?
print(rmsd)

# Lastly, let's examine some rows where our model was the most wrong.
preds$error <- abs(preds$ArrDelay - preds$ArrDelayPred)
head(bigr.sort(preds, preds$error, decr=T))

# We get an RMSD measure of 14-15 minutes, and our model is off by a lot on
# certain rows. We may be able to improve the model by using additional
# predictors such as departure and arrival cities (some airports are worse
# than others), day of the week (weekends have different traffic patterns
# than weekdays), etc. It is debatable whether our original data even has all
# of the predictors that affect arrival delay. For the moment though, we're
# done building and testing our model.

#___________________________________________________________________________#
# Free experimentation

# Use you knowledge of groupApply() to execute your own R functions on data 
# in BigInsights. Be careful, though! Your machine is only a single-node 
# cluster so BigInsights will need to serialize the processing of each 
# partition. This is precisely the reason why we chose to limit our model 
# building to two airlines. On a more powerful cluster with many cores and 
# nodes, Big R will automatically parallelize groupApply() to exploit the 
# full cluster.


