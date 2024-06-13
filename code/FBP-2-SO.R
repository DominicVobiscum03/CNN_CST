library(PET)
library(png)

##Pre-combined

#Read in the Sinograms
#Filter 1 total
filt1 <- read.csv("raw_data/filtsinoa-final-SO.csv")
filt1 <- as.matrix(filt1)
image(filt1)

#Filter 2 total
filt2 <- read.csv("raw_data/filtsinob-final-SO.csv")
filt2 <- as.matrix(filt2)
image(filt2)

#filt3 <- read.csv("raw_data/filtsinoc-SO.csv")
#filt3 <- as.matrix(filt3)
#image(filt3)

#Back Projection
#Full filter 1 back projection
FBP1 <- iradon(filt1, XSamples = 64, YSamples = 64, mode = "BF")
filt1data <- FBP1$irData
image(filt1data)

#Full filter 2 back projection
FBP2 <- iradon(filt2, XSamples = 64, YSamples = 64, mode = "BF")
filt2data <- FBP2$irData
image(filt2data)

#FBP3 <- iradon(filt3, XSamples = 64, YSamples = 64, mode = "CNF")
#filt3data <- FBP3$irData
#image(filt3data)


# Read in the biases
m1 <- as.matrix(read.csv("raw_data/m1-SO-2.csv"))
m2 <- as.matrix(read.csv("raw_data/m2-SO-2.csv"))

b1 <- matrix(m1[1,1], 64, 64)
b2 <- matrix(m1[1,2], 64, 64)
#b3 <- matrix(m1[1,3], 64, 64)


w1 <- m2[2,1]
w2 <- m2[3,1]
#w3 <- m2[4,1]


bf <- matrix(m2[1,1], 64, 64)

#Subtract biases
#For original full
filta <- filt1data - b1
filtb <- filt2data - b2
#filtc <- filt3data + b3


filtsa <- matrix(nrow = 64, ncol = 64)
for (i in 1:nrow(filta)){
  for (j in 1:ncol(filta)){
    filtsa[i,j] <- 1/(1+exp(-filta[i,j]))
  }
}

image(filtsa)

filtsb <- matrix(nrow = 64, ncol = 64)
for (i in 1:nrow(filtb)){
  for (j in 1:ncol(filtb)){
    filtsb[i,j] <- 1/(1+exp(-(filtb[i,j])))
  }
}
image(filtsb)

#filtsc <- matrix(nrow = 64, ncol = 64)
#for (i in 1:nrow(filtc)){
# for (j in 1:ncol(filtc)){
#  filtsc[i,j] <- 1/(1+exp(-(filtc[i,j])))
#  }
#}
#image(filtsc)

filtsa <- filtsa*w1
filtsb <- filtsb*w2
#filtsc <- filtsc*w3


filts <- filtsa + filtsb #+ filtsc
image(filts)


filts2o <- filts - bf
filts2o
image(filts2o)


filtf <- matrix(nrow = 64, ncol = 64)
for (i in 1:nrow(filts2o)){
  for (j in 1:ncol(filts2o)){
    filtf[i,j] <- 1/(1+exp(-(filts2o[i,j])))
  }
}


image(filtf)




















##Separate convolutions

#Read in the Sinograms

#Filter 1 first half (left)
filt1a <- read.csv("raw_data/filtsinoa2-SO.csv")
filt1a <- as.matrix(filt1a[1:91,])
image(filt1a)

#Filter 1 second half (right)
filt1b <- read.csv("raw_data/filtsinoa2b-SO.csv")
filt1b <- as.matrix(filt1b[91:181,])
image(filt1b)

image(filt1a+filt1b)

#Filter 2 left half
filt2a <- read.csv("raw_data/filtsinob2-SO.csv")
filt2a <- as.matrix(filt2a[1:91,])
image(filt2a)

#Filter 2 right half
filt2b <- read.csv("raw_data/filtsinob2b-SO.csv")
filt2b <- as.matrix(filt2b[91:181,])
image(filt2b)

image(filt2a + filt2b)

# Back Projection

#Filter 1 left half back projection
FBP1a <- iradon(filt1a, XSamples = 64, YSamples = 64, mode = "BF")
filt1adata <- FBP1a$irData
image(filt1adata)

#Filter 1 right half back projection
FBP1b <- iradon(filt1b, XSamples = 64, YSamples = 64, mode = "BF")
filt1bdata <- FBP1b$irData
image(filt1bdata)

#Combine left and right
image(filt1adata+filt1bdata)
filt1tot <- filt1adata + filt1bdata

#Filter 2 left half back projection
FBP2a <- iradon(filt2a, XSamples = 64, YSamples = 64, mode = "BF")
filt2adata <- FBP2a$irData
image(filt2adata)

#Filter 2 right half back projection
FBP2b <- iradon(filt2b, XSamples = 64, YSamples = 64, mode = "BF")
filt2bdata <- FBP2b$irData
image(filt2bdata)

#Combine left and right
image(filt2adata+filt2bdata)
filt2tot <- filt2adata + filt2bdata

# Read in the biases
m1 <- as.matrix(read.csv("raw_data/m1-SO-2.csv"))
m2 <- as.matrix(read.csv("raw_data/m2-SO-2.csv"))

b1 <- matrix(m1[1,1], 64, 64)
b2 <- matrix(m1[1,2], 64, 64)
#b3 <- matrix(m1[1,3], 64, 64)

w1 <- m2[2,1]
w2 <- m2[3,1]
#w3 <- m2[4,1]

bf <- matrix(m2[1,1], 64, 64)

#Subtract biases

filta2 <- filt1tot - b1
filtb2 <- filt2tot - b2


filtsa2 <- matrix(nrow = 64, ncol = 64)
for (i in 1:nrow(filta2)){
  for (j in 1:ncol(filta2)){
    filtsa2[i,j] <- 1/(1+exp(-filta2[i,j]))
  }
}

image(filts2a)

filtsb2 <- matrix(nrow = 64, ncol = 64)
for (i in 1:nrow(filtb2)){
  for (j in 1:ncol(filtb2)){
    filtsb2[i,j] <- 1/(1+exp(-(filtb2[i,j])))
  }
}
image(filtsb2)

filtsa2 <- filtsa2*w1
filtsb2 <- filtsb2*w2

filts2 <- filtsa2 + filtsb2
image(filts2)

#Remove last bias
filts3 <- filts2 - bf
filts3
image(filts3)

#Last step
filtf2 <- matrix(nrow = 64, ncol = 64)
for (i in 1:nrow(filts3)){
  for (j in 1:ncol(filts3)){
    filtf2[i,j] <- 1/(1+exp(-(filts3[i,j])))
  } 
}


image(filtf2)


write.csv(filtf, "clean_data/FBP1-SO-2.csv")











##Side by side convolutions

##Separate convolutions

#Read in the Sinograms

#Filter 1 first half (left)
filt1a <- read.csv("raw_data/filtsinoa2-SO.csv")
filt1a <- as.matrix(filt1a[1:91,])
image(filt1a)

#Filter 1 second half (right)
filt1b <- read.csv("raw_data/filtsinoa2b-SO.csv")
filt1b <- as.matrix(filt1b[91:181,])
image(filt1b)

#combine filter 1
filt1comb <- rbind(filt1a, filt1b)
filt1comb <- as.matrix(filt1comb)
image(filt1comb)

#Filter 2 left half
filt2a <- read.csv("raw_data/filtsinob2-SO.csv")
filt2a <- as.matrix(filt2a[1:91,])
image(filt2a)

#Filter 2 right half
filt2b <- read.csv("raw_data/filtsinob2b-SO.csv")
filt2b <- as.matrix(filt2b[91:181,])
image(filt2b)

#combine filter 2
filt2comb <- rbind(filt2a, filt2b)
filt2comb <- as.matrix(filt2comb)
image(filt2comb)

# Back Projection

#Filter 1 back projection
FBP1tot <- iradon(filt1comb, XSamples = 64, YSamples = 64, mode = "BF")
filt1totdata <- FBP1tot$irData
image(filt1totdata)

#Filter 2 left half back projection
FBP2tot <- iradon(filt2comb, XSamples = 64, YSamples = 64, mode = "BF")
filt2totdata <- FBP2tot$irData
image(filt2totdata)

# Read in the biases
m1 <- as.matrix(read.csv("raw_data/m1-SO-2.csv"))
m2 <- as.matrix(read.csv("raw_data/m2-SO-2.csv"))

b1 <- matrix(m1[1,1], 64, 64)
b2 <- matrix(m1[1,2], 64, 64)
#b3 <- matrix(m1[1,3], 64, 64)

w1 <- m2[2,1]
w2 <- m2[3,1]
#w3 <- m2[4,1]

bf <- matrix(m2[1,1], 64, 64)

#Subtract biases

filta2 <- filt1totdata - b1
filtb2 <- filt2totdata - b2


filtsa2 <- matrix(nrow = 64, ncol = 64)
for (i in 1:nrow(filta2)){
  for (j in 1:ncol(filta2)){
    filtsa2[i,j] <- 1/(1+exp(-filta2[i,j]))
  }
}

image(filts2a)

filtsb2 <- matrix(nrow = 64, ncol = 64)
for (i in 1:nrow(filtb2)){
  for (j in 1:ncol(filtb2)){
    filtsb2[i,j] <- 1/(1+exp(-(filtb2[i,j])))
  }
}
image(filtsb2)

filtsa2 <- filtsa2*w1
filtsb2 <- filtsb2*w2

filts2 <- filtsa2 + filtsb2
image(filts2)

#Remove last bias
filts3 <- filts2 - bf
filts3
image(filts3)

#Last step
filtf2 <- matrix(nrow = 64, ncol = 64)
for (i in 1:nrow(filts3)){
  for (j in 1:ncol(filts3)){
    filtf2[i,j] <- 1/(1+exp(-(filts3[i,j])))
  } 
}


image(filtf2)


write.csv(filtf, "clean_data/FBP1-SO-2.csv")

