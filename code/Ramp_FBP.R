## Ramp Filter
library(PET)
library(png)

#Read in the Sinograms
#Filter 1 total
filt1 <- read.csv("C:/Users/sumloan/Documents/ANN_work/CNN_CST/raw_data/rampsino.csv")
filt1 <- as.matrix(filt1)
image(filt1)

#Back Projection
#Full filter 1 back projection
FBP1 <- iradon(filt1, XSamples = 64, YSamples = 64, mode = "BF")
filt1data <- FBP1$irData
image(filt1data)
