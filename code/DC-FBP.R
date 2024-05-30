library(PET)
library(png)

#Read in the Sinograms
filt1 <- read.csv("raw_data/filtsinoa-DC.csv")
filt1 <- as.matrix(filt1)
image(filt1)

filt2 <- read.csv("raw_data/filtsinob-DC.csv")
filt2 <- as.matrix(filt2)
image(filt2)



# Back Projection

FBP1 <- iradon(filt1, XSamples = 256, YSamples = 256, mode = "BF")
filt1data <- FBP1$irData
image(filt1data)

FBP2 <- iradon(filt2, XSamples = 256, YSamples = 256, mode = "BF")
filt2data <- FBP2$irData
image(filt2data)


# Read in the biases
m1 <- as.matrix(read.csv("raw_data/m1-DC.csv"))
m2 <- as.matrix(read.csv("raw_data/m2-DC.csv"))

b1 <- matrix(m1[1,1], 256, 256)
b2 <- matrix(m1[1,2], 256, 256)


w1 <- m2[2,1]
w2 <- m2[3,1]


bf <- matrix(m2[1,1], 256, 256)

#Subtract biases

filta <- filt1data - b1
filtb <- filt2data - b2


filtsa <- matrix(nrow = 256, ncol = 256)
for (i in 1:nrow(filta)){
  for (j in 1:ncol(filta)){
    filtsa[i,j] <- -1/(1+exp(-filta[i,j]))
  }
}

image(filtsa)

filtsb <- matrix(nrow = 256, ncol = 256)
for (i in 1:nrow(filtb)){
  for (j in 1:ncol(filtb)){
    filtsb[i,j] <- -1/(1+exp(-(filtb[i,j])))
  }
}
image(filtsb)




filtsa <- filtsa*w1
filtsb <- filtsb*w2




filts <- filtsa + filtsb
image(filts)



filts2 <- filts - bf
filts2
image(filts2)

filtf <- matrix(nrow = 256, ncol = 256)
for (i in 1:nrow(filts2)){
  for (j in 1:ncol(filts2)){
    filtf[i,j] <- -1/(1+exp(-(filts2[i,j])))
  }
}


image(filtf)

write.csv(filtf, "clean_data/FBP1-DC.csv")




