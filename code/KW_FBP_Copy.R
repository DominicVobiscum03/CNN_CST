library(PET)
library(png)

test <- read.csv("Z:/Research/ANN Work/raw_data/65sin.csv")
test <- test[,-c(1)]
test <- as.matrix(test)
image(test)

#Read in the Sinograms
filt1 <- read.csv("Z:/Research/ANN Work/raw_data/filtsinoa.csv")
filt1 <- as.matrix(filt1)
image(filt1)

filt2 <- read.csv("Z:/Research/ANN Work/raw_data/filtsinob.csv")
filt2 <- as.matrix(filt2)
image(filt2)

filt3 <- read.csv("Z:/Research/ANN Work/raw_data/filtsinoc.csv")
filt3 <- as.matrix(filt3)
image(filt3)

filt4 <- read.csv("Z:/Research/ANN Work/raw_data/filtsinod.csv")
filt4 <- as.matrix(filt4)
image(filt4)

filt5 <- read.csv("Z:/Research/ANN Work/raw_data/filtsinoe.csv")
filt5 <- as.matrix(filt5)
image(filt5)

filt6 <- read.csv("Z:/Research/ANN Work/raw_data/filtsinof.csv")
filt6 <- as.matrix(filt6)
image(filt6)

filt7 <- read.csv("Z:/Research/ANN Work/raw_data/filtsinog.csv")
filt7 <- as.matrix(filt4)
image(filt7)

filt8 <- read.csv("Z:/Research/ANN Work/raw_data/filtsinoh.csv")
filt8 <- as.matrix(filt8)
image(filt8)

# Back Projection

FBP1 <- iradon(filt1, XSamples = 64, YSamples = 64, mode = "BF")
filt1data <- FBP1$irData
image(filt1data)

FBP2 <- iradon(filt2, XSamples = 64, YSamples = 64, mode = "BF")
filt2data <- FBP2$irData
image(filt2data)

FBP3 <- iradon(filt3, XSamples = 64, YSamples = 64, mode = "BF")
filt3data <- FBP3$irData
image(filt3data)

FBP4 <- iradon(filt4, XSamples = 64, YSamples = 64, mode = "BF")
filt4data <- FBP4$irData
image(filt4data)

FBP5 <- iradon(filt5, XSamples = 64, YSamples = 64, mode = "BF")
filt5data <- FBP5$irData
image(filt5data)

FBP6 <- iradon(filt6, XSamples = 64, YSamples = 64, mode = "BF")
filt6data <- FBP6$irData
image(filt6data)

FBP7 <- iradon(filt7, XSamples = 64, YSamples = 64, mode = "BF")
filt7data <- FBP7$irData
image(filt7data)

FBP8 <- iradon(filt8, XSamples = 64, YSamples = 64, mode = "BF")
filt8data <- FBP8$irData
image(filt8data)

# Read in the biases
m1 <- as.matrix(read.csv("Z:/Research/ANN Work/raw_data/m1.csv"))
m2 <- as.matrix(read.csv("Z:/Research/ANN Work/raw_data/m2.csv"))

b1 <- matrix(m1[1,1], 64, 64)
b2 <- matrix(m1[1,2], 64, 64)
b3 <- matrix(m1[1,3], 64, 64)
b4 <- matrix(m1[1,4], 64, 64)
b5 <- matrix(m1[1,5], 64, 64)
b6 <- matrix(m1[1,6], 64, 64)
b7 <- matrix(m1[1,7], 64, 64)
b8 <- matrix(m1[1,8], 64, 64)

w1 <- m2[2,1]
w2 <- m2[3,1]
w3 <- m2[4,1]
w4 <- m2[5,1]
w5 <- m2[6,1]
w6 <- m2[7,1]
w7 <- m2[8,1]
w8 <- m2[9,1]

bf <- matrix(m2[1,1], 64, 64)

#Subtract biases

filta <- filt1data + b1
filtb <- filt2data + b2
filtc <- filt3data + b3
filtd <- filt4data + b4
filte <- filt5data + b5
filtf <- filt6data + b6
filtg <- filt7data + b7
filth <- filt8data + b8


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

filtse <- matrix(nrow = 64, ncol = 64)
for (i in 1:nrow(filte)){
  for (j in 1:ncol(filte)){
    filtse[i,j] <- -1/(1+exp(-(filte[i,j])))
  }
}
image(filtse)

filtsf <- matrix(nrow = 64, ncol = 64)
for (i in 1:nrow(filtf)){
  for (j in 1:ncol(filtf)){
    filtsf[i,j] <- -1/(1+exp(-(filtf[i,j])))
  }
}
image(filtsf)

filtsg <- matrix(nrow = 64, ncol = 64)
for (i in 1:nrow(filtg)){
  for (j in 1:ncol(filtg)){
    filtsg[i,j] <- -1/(1+exp(-(filtg[i,j])))
  }
}
image(filtsg)

filtsh <- matrix(nrow = 64, ncol = 64)
for (i in 1:nrow(filth)){
  for (j in 1:ncol(filth)){
    filtsh[i,j] <- -1/(1+exp(-(filth[i,j])))
  }
}
image(filtsh)


wfiltsa <- filtsa*w1
wfiltsb <- filtsb*w2
wfiltsc <- filtsc*w3
wfiltsd <- filtsd*w4
wfiltse <- filtse*w5
wfiltsf <- filtsf*w6
wfiltsg <- filtsg*w7
wfiltsh <- filtsh*w8



filts <- wfiltsa + wfiltsb + wfiltsc + wfiltsd + wfiltse + wfiltsf + wfiltsg + wfiltsh
image(filts)



filts2 <- filts + bf
image(filts2)

filtfull <- matrix(nrow = 64, ncol = 64)
for (i in 1:nrow(filts2)){
  for (j in 1:ncol(filts2)){
    filtfull[i,j] <- -1/(1+exp(-(filts2[i,j])))
  }
}


image(filtfull)

write.csv(filtfull, "Z:/Research/ANN Work/clean_data/FBP1.csv")
