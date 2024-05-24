library(PET)

sino <- read.csv("raw_data/65sin.csv")

sino <- as.matrix(sino)
sino <- noquote(sino)

sino <- sino[,2:94]

FB<- iradon(sino, 65,65, "FB")
FB <- FB$irData
FB <- as.matrix(FB)
image(FB)
