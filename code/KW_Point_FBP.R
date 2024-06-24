library(PET)
library(png)

#--------------------------------

simple <-matrix(rep(0,64*64),64,64)
simple[16,16] <-1
image(simple)
write.csv(simple,"Z:/Research/ANN Work/raw_data/simple_image.csv")
simple_rad <- as.matrix(radon(simple)$rData)
image(simple_rad)
write.csv(simple_rad,"Z:/Research/ANN Work/raw_data/simple_sino.csv")

phan1 <- as.matrix(phantom(n=64, design="B"))
image(phan1)
write.csv(phan1, "Z:/Research/ANN Work/raw_data/phantom_64_1.csv")

phan2 <- as.matrix(phantom(n=64, design="A"))
image(phan2)
write.csv(phan2, "Z:/Research/ANN Work/raw_data/phantom_64_2.csv")

phan3 <- as.matrix(phantom(n=64, design="C"))
image(phan3)
write.csv(phan3, "Z:/Research/ANN Work/raw_data/phantom_64_3.csv")

phan4 <- as.matrix(phantom(n=64, design="D"))
image(phan4)
write.csv(phan4, "Z:/Research/ANN Work/raw_data/phantom_64_4.csv")

rad1 <- as.matrix(radon(phan1)$rData)
image(rad1)
write.csv(rad1, "Z:/Research/ANN Work/raw_data/radontransform_64_1.csv")

rad2 <- as.matrix(radon(phan2)$rData)
image(rad2)
write.csv(rad2, "Z:/Research/ANN Work/raw_data/radontransform_64_2.csv")

rad3 <- as.matrix(radon(phan3)$rData)
image(rad3)
write.csv(rad3, "Z:/Research/ANN Work/raw_data/radontransform_64_3.csv")

rad4 <- as.matrix(radon(phan4)$rData)
image(rad4)
write.csv(rad4, "Z:/Research/ANN Work/raw_data/radontransform_64_4.csv")


FBP <- iradon(rad1, XSamples = 64, YSamples = 64, mode = "BF")
filtdata <- FBP$irData
image(filtdata)


#---------------------------------
image <- as.matrix(read.csv("Z:/Research/ANN Work/raw_data/65ref.csv"))
sinogram1 <-radon(image)

test <- read.csv("Z:/Research/ANN Work/raw_data/65sin.csv")
test <- test[,-c(1)]
test <- as.matrix(test)
image(test)
#---------------------------------



#Read in the Sinograms
filt1 <- read.csv("Z:/Research/ANN Work/raw_data/filtsinoa.csv")
filt1 <- as.matrix(filt1)
image(filt1)

filt2 <- read.csv("Z:/Research/ANN Work/raw_data/filtsinob.csv")
filt2 <- as.matrix(filt2)
image(filt2)



# Back Projection

FBP1 <- iradon(filt1, XSamples = 64, YSamples = 64, mode = "BF")
filt1data <- FBP1$irData
image(filt1data)

FBP2 <- iradon(filt2, XSamples = 64, YSamples = 64, mode = "BF")
filt2data <- FBP2$irData
image(filt2data)



# Read in the biases
m1 <- as.matrix(read.csv("Z:/Research/ANN Work/raw_data/m1.csv"))
m2 <- as.matrix(read.csv("Z:/Research/ANN Work/raw_data/m2.csv"))

b1 <- matrix(m1[1,1], 64, 64)
b2 <- matrix(m1[1,2], 64, 64)


w1 <- m2[2,1]
w2 <- m2[3,1]


bf <- matrix(m2[1,1], 64, 64)

#Subtract biases

filta <- filt1data + b1
filtb <- filt2data + b2



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



wfiltsa <- filtsa*w1
wfiltsb <- filtsb*w2




filts <- wfiltsa + wfiltsb
image(filts)



filts2 <- filts + bf
image(filts2)

filtfull <- matrix(nrow = 64, ncol = 64)
for (i in 1:nrow(filts2)){
  for (j in 1:ncol(filts2)){
    filtfull[i,j] <- 1/(1+exp(-(filts2[i,j])))
  }
}


image(filtfull)

write.csv(filtfull, "Z:/Research/ANN Work/clean_data/FBP1.csv")
