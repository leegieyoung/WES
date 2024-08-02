#!/bin/Rscript
library(data.table)
library(stringr)
pre_DIR="/ichrogene/project/temp/gylee/1.WES/2.gatk_result/skin.1004"
print("Make_DIR")
if (!dir.exists(paste0(pre_DIR,"/8.group/"))){
	dir.create(paste0(pre_DIR,"/8.group/"))
}

data <- fread("/ichrogene/project/temp/gylee/1.WES/2.gatk_result/skin.1004/6.plinkQC/skin.1004_hwe_het_pca_maf.snpEff.txt",head=T)

data <- data[,1:8]
data <- as.data.frame(data)
wHIGH <- grep("HIGH", data[,8])
HIGH <- data[wHIGH,]
ms <- data[-wHIGH,]
wms <- grep("missense_variant",ms[,8])
ms <- ms[wms,]

H_Gene <- lapply(HIGH[,8], function(x) {
  matches <- str_match_all(x, "HIGH\\|([^|]+)")[[1]]
  unique_matches <- as.data.frame(unique(matches))
  if(nrow(unique_matches) >1){
	unique_matches <- unique_matches[!grepl("^RP", unique_matches[,1]),]
 return(unique_matches[1,2])
 } else {
 return(unique_matches[1,2])
 }
})
HIGH[,8] <- unlist(H_Gene)
HIGH <- HIGH[!grepl("RP", HIGH[,8]),]
HIGH[,9] <- "HIGH"

ms_Gene <- lapply(ms[,8], function(x) {
  matches <- str_match_all(x, "missense_variant[^|]*\\|[^|]+\\|([^|]+)")[[1]]
  unique_matches <- as.data.table(unique(matches))
  if(nrow(unique_matches) >1){
        unique_matches <- unique_matches[!grepl("^RP", unique_matches[,1]),]
 return(unique_matches[1,2])
 } else {
 return(unique_matches[1,2])
 }
})
ms[,8] <- unlist(ms_Gene)
ms <- ms[!grepl("^RP", ms[,8]),]
ms[,9] <- "missense"

#merge
merge <- rbind(ms, HIGH)

#groupFile
Gene <- unique(merge$INFO)

for (A in Gene){
print(A)
result <- matrix(c(
c(A,"var",merge[which(merge$INFO==A),"ID"]),
c(A,"anno",merge[which(merge$INFO==A),"V9"])), nrow=2, byrow=T)
write.table(result,paste0(pre_DIR,"/8.group/",A,".txt"), quote=F, col.names=F, row.names=F, sep=' ')
}
