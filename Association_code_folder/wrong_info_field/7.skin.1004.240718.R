#!/bin/Rscript
library(stringr)
library(data.table)
setwd("/ichrogene/project/temp/gylee/1.WES/2.gatk_result/skin.1004/5.custom.filter/result")
if (!dir.exists(paste0("Find_Nomaf","/"))){
	dir.create(paste0("Find_Nomaf","/"))
}
#data <- read.table("2020.jds.variant.vcf", head=T, comment.char="")

QC.marker <- function(data){
#> dim(data)
#[1] 183218   1013

#1.Only SNP
ACGT <- sapply(data$ALT,function(x) { if(nchar(x)==1){
 x1 <- x} else {
 x1 <- 0}})
data <- data[which(ACGT!=0),]

#2.DP_QC, Calling Rate < 90%
Geno <- data[,10:ncol(data)]
DP <- sapply(Geno, function(col) sapply(str_split(col, ":"), `[`, 3))
colnames(DP) <- sapply(colnames(DP),function(x) {paste0("DP_",x)})
DP <- gsub('\\.',0,DP)

DP_CR <- apply(DP, 1, function(x) {
	(length(x)-length(which(as.numeric(x) == 0)))/length(x)
})

wDP_CR <- which(DP_CR >= 0.9)
if(length(wDP_CR)!=0){
data <- data[wDP_CR,]
DP <- DP[wDP_CR,]
}

#3.GQ_QC, < 20
Geno <- data[,10:ncol(data)]
GQ <- sapply(Geno, function(col) sapply(str_split(col, ":"), `[`, 4))
colnames(GQ) <- sapply(colnames(GQ),function(x) {paste0("GQ_",x)})
GQ <- gsub('\\.',0,GQ)

GQ_z <- apply(GQ,1, function(x) {all(as.numeric(x) < 20)})
w_GQ_z <- which(GQ_z=="TRUE")
if(length(w_GQ_z)!=0){
data <- data[-w_GQ_z,]
DP <- DP[-w_GQ_z,]
GQ <- GQ[-w_GQ_z,]
}

#4.GQ가 20 미만인 경우, DP=0, GQ=0
for (A in 1:ncol(GQ)){
 wGQ20 <- which(as.numeric(GQ[,A]) < 20)
if(length(wGQ20)!=0){
DP[wGQ20,A] <- 0
GQ[wGQ20,A] <- 0
}
}

#5.DP_QC, Calling Rate < 90%
DP_CR <- apply(DP, 1, function(x) {
        (length(x)-length(which(as.numeric(x) == 0)))/length(x)
})
  
wDP_CR <- which(DP_CR >= 0.9)
if(length(wDP_CR)!=0){
data <- data[wDP_CR,]
DP <- DP[wDP_CR,]
GQ <- GQ[wDP_CR,]
}

#6. GQ < 20 인 경우, Missing 처리
Info <- data[,1:9]
Geno <- data[,10:ncol(data)]
alt <- sapply(Geno, function(col) sapply(str_split(col, ":"), `[`, 1))
for (A in 1:ncol(GQ)){
 wGQ20 <- which(as.numeric(GQ[,A]) < 20)
if(length(wGQ20)!=0){
alt[wGQ20,A] <- './.'
}
}

result <- cbind(Info, alt)
return(result)
}

Seq <- c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,"X","M")
for (A in Seq){
print(paste0("Start chr",A))
data <- fread(paste0(A,".sort.minac10.txt"), head=T)
assign("result", QC.marker(data))
fwrite(result, paste0("Find_Nomaf/",A,".QC.marker.nohead"), sep='\t')
}
