library(PET)
library(png)
knitr::opts_knit$set(root.dir='Z:/Research/ANN Work')

test <- read.csv("Z:/Research/ANN Work/raw_data/65sin.csv")
test <- test[,-c(1)]
test <- as.matrix(test)
image(test)

#Read in the Sinograms
filt1 <- read.csv("raw_data/filtsinoa.csv")
filt1 <- as.matrix(filt1)
image(filt1)

filt2 <- read.csv("raw_data/filtsinob.csv")
filt2 <- as.matrix(filt2)
image(filt2)

filt3 <- read.csv("raw_data/filtsinoc.csv")
filt3 <- as.matrix(filt3)
image(filt3)

filt4 <- read.csv("raw_data/filtsinod.csv")
filt4 <- as.matrix(filt4)
image(filt4)


# Back Projection

FBP1 <- iradon(filt1, XSamples = 64, YSamples = 64, mode = "CNF")
filt1data <- FBP1$irData
image(filt1data)

FBP2 <- iradon(filt2, XSamples = 64, YSamples = 64, mode = "CNF")
filt2data <- FBP2$irData
image(filt2data)

FBP3 <- iradon(filt3, XSamples = 64, YSamples = 64, mode = "CNF")
filt3data <- FBP3$irData
image(filt3data)

FBP4 <- iradon(filt4, XSamples = 64, YSamples = 64, mode = "CNF")
filt4data <- FBP4$irData
image(filt4data)

# Read in the biases
m1 <- as.matrix(read.csv("Z:/Research/ANN Work/raw_data/m1.csv"))
m2 <- as.matrix(read.csv("Z:/Research/ANN Work/raw_data/m2.csv"))

b1 <- matrix(m1[1,1], 64, 64)
b2 <- matrix(m1[1,2], 64, 64)
b3 <- matrix(m1[1,3], 64, 64)
b4 <- matrix(m1[1,4], 64, 64)

w1 <- m2[2,1]
w2 <- m2[3,1]
w3 <- m2[4,1]
w4 <- m2[5,1]

bf <- matrix(m2[1,1], 64, 64)

#Subtract biases

filta <- filt1data + b1
filtb <- filt2data + b2
filtc <- filt3data + b3
filtd <- filt4data + b4


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

filtsc <- matrix(nrow = 64, ncol = 64)
for (i in 1:nrow(filtc)){
  for (j in 1:ncol(filtc)){
    filtsc[i,j] <- -1/(1+exp(-(filtc[i,j])))
  }
}
image(filtsc)

filtsd <- matrix(nrow = 64, ncol = 64)
for (i in 1:nrow(filtd)){
  for (j in 1:ncol(filtd)){
    filtsd[i,j] <- -1/(1+exp(-(filtd[i,j])))
  }
}
image(filtsd)


wfiltsa <- filtsa*w1
wfiltsb <- filtsb*w2
wfiltsc <- filtsc*w3
wfiltsd <- filtsd*w4



filts <- wfiltsa + wfiltsb + wfiltsc + wfiltsd
image(filts)



filts2 <- filts + bf
image(filts2)

filtf <- matrix(nrow = 64, ncol = 64)
for (i in 1:nrow(filts2)){
  for (j in 1:ncol(filts2)){
    filtf[i,j] <- -1/(1+exp(-(filts2[i,j])))
  }
}


image(filtf)

write.csv(filtf, "Z:/Research/ANN Work/clean_data/FBP1.csv")
