library(PET)
library(png)

#Read in the Sinograms
filt1 <- read.csv("raw_data/filtsinoa-SO.csv")
filt1 <- as.matrix(filt1)
image(filt1)

filt2 <- read.csv("raw_data/filtsinob-SO.csv")
filt2 <- as.matrix(filt2)
image(filt2)

#filt3 <- read.csv("raw_data/filtsinoc-SO.csv")
#filt3 <- as.matrix(filt3)
#image(filt3)


# Back Projection

FBP1 <- iradon(filt1, XSamples = 64, YSamples = 64, mode = "CNF")
filt1data <- FBP1$irData
image(filt1data)

FBP2 <- iradon(filt2, XSamples = 64, YSamples = 64, mode = "CNF")
filt2data <- FBP2$irData
image(filt2data)

#FBP3 <- iradon(filt3, XSamples = 64, YSamples = 64, mode = "CNF")
#filt3data <- FBP3$irData
#image(filt3data)


# Read in the biases
m1 <- as.matrix(read.csv("raw_data/m1-SO.csv"))
m2 <- as.matrix(read.csv("raw_data/m2-SO.csv"))

b1 <- matrix(m1[1,1], 64, 64)
b2 <- matrix(m1[1,2], 64, 64)
#b3 <- matrix(m1[1,3], 64, 64)


w1 <- m2[2,1]
w2 <- m2[3,1]
#w3 <- m2[4,1]


bf <- matrix(m2[1,1], 64, 64)

#Subtract biases

filta <- filt1data + b1
filtb <- filt2data + b2
#filtc <- filt3data + b3


filtsa <- matrix(nrow = 64, ncol = 64)
for (i in 1:nrow(filta)){
  for (j in 1:ncol(filta)){
    filtsa[i,j] <- -1/(1+exp(-filta[i,j]))
  }
}

image(filtsa)

filtsb <- matrix(nrow = 64, ncol = 64)
for (i in 1:nrow(filtb)){
  for (j in 1:ncol(filtb)){
    filtsb[i,j] <- -1/(1+exp(-(filtb[i,j])))
  }
}
image(filtsb)

#filtsc <- matrix(nrow = 64, ncol = 64)
#for (i in 1:nrow(filtc)){
 # for (j in 1:ncol(filtc)){
  #  filtsc[i,j] <- -1/(1+exp(-(filtc[i,j])))
#  }
#}
#image(filtsc)




filtsa <- filtsa*w1
filtsb <- filtsb*w2
#filtsc <- filtsc*w3




filts <- filtsa + filtsb #+ filtsc
image(filts)



filts2 <- filts - bf
filts2
image(filts2)

filtf <- matrix(nrow = 64, ncol = 64)
for (i in 1:nrow(filts2)){
  for (j in 1:ncol(filts2)){
    filtf[i,j] <- -1/(1+exp(-(filts2[i,j])))
  }
}


image(filtf)

write.csv(filtf, "clean_data/FBP1-SO.csv")




