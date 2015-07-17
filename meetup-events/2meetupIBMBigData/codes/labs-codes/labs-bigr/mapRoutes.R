library(maps)
library(geosphere)
library(ggplot2)
library(lattice)
library(grid)
library(chron)

##############################################################################
#                        Airline Routes                                      #
##############################################################################

mapRoutes <- function(flights) {
    # Display the US map
    par(mar=rep(0,4), oma = c(0,0,0,0))
    par(mar=rep(0,4))
    xlim <- c(-171.738281, -56.601563)
    ylim <- c(12.039321, 71.856229)
    
    tofile <- F
    if (tofile) png(file = "myplot.png", bg = "transparent", width = 1480, height = 1480)
    
    map("world", col="#B2f2f2", fill=T, bg="white", lwd=0.01, lty = 0.01,
        xlim=xlim, ylim=ylim)
    title(main = list("Busiest airline routes 1988-2008", col="blue"))
    
    pal <- colorRampPalette(c("#f2f2f2", "red"))
    colors <- pal(100)
    
    airports <- read.csv("airports.csv", header=TRUE) 
    
    fsub <- flights
    fsub <- fsub[order(fsub$cnt),]
    maxcnt <- max(fsub$cnt)
    for (j in 1:nrow(fsub)) {
        air1 <- airports[airports$iata == fsub[j,]$airport1,]
        air2 <- airports[airports$iata == fsub[j,]$airport2,]
        inter <- gcIntermediate(c(air1[1,]$long, air1[1,]$lat), c(air2[1,]$long, air2[1,]$lat), n=100, addStartEnd=TRUE)
        colindex <- round( (fsub[j,]$cnt / maxcnt) * length(colors) )
        if (fsub[j,]$cnt >= 400) {
            text(air1[1,]$long, air1[1,]$lat, air1$iata, cex=0.8)
            text(air2[1,]$long, air2[1,]$lat, air2$iata, cex=0.8)
        }
        lines(inter, col=colors[colindex], lwd=0.8)
    }
    if (tofile) dev.off()
}
