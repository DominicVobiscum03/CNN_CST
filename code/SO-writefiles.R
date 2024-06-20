#Read in libraries
library(PET)
library(png)

#Define phantom
pic <- phantom(n=64, design = "B")
image(pic)

#Write phantom into a csv
pic <- as.matrix(pic)
write.csv(pic, "raw_data/SO-pic.csv")

#Create sinogram
sino <- radon(pic)

#Write sinogram into a csv
sino <- as.matrix(sino$rData)
write.csv(sino, "raw_data/SO-sinogram.csv")


#backproject sinogram
FBP <- iradon(sino, XSamples = 64, YSamples = 64, mode = "BF")
image(matrix(FBP))

#sino2
sino2 <- radon(pic, ThetaSamples = 182)
sino2 <- as.matrix(sino2$rData)
write.csv(sino2, "raw_data/SO-sinogram-182.csv")