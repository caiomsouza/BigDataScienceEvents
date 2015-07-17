setwd("~/labs-bigr")

rm(list = ls())

library(bigr)

bigr.connect(host="localhost", port=7052, user="biadmin", password="biadmin")

is.bigr.connected()

bigr.reconnect()

bigr.listfs()

bigr.listfs("/user/biadmin")

