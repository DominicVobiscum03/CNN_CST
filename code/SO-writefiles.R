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
