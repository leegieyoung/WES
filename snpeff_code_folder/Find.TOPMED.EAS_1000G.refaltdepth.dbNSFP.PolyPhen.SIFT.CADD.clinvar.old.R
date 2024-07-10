#!/bin/Rscript
library(stringr)
setwd("/ichrogene/project/temp/gylee/1.WES/2.gatk_result/skin100/4.VariantFiltration")
#data <- read.table("2020.jds.variant.vcf", head=T, comment.char="")
data <- read.table("snps.indels_filtered.PASS.snpEff.SnpSift.vcf", head=T, comment.char="")


Info <- data[,1:8]
Geno <- data[,10:ncol(data)]
Geno_refalt <- data[,10:ncol(data)]

#AD 뽑기
Geno <- sapply(Geno, function(col) sapply(str_split(col, ":"), `[`, 2))

#Alt depth 뽑기
alt <- matrix(unlist(lapply(str_split(Geno, ","), `[`, 2)), nrow = nrow(Geno), byrow = TRUE)
colnames(alt) <- colnames(Geno)
refalt <- matrix(unlist(Geno), nrow = nrow(Geno), byrow = TRUE)
colnames(refalt) <- colnames(Geno)
colnames(refalt) <- gsub("Dae","refalt_Dae",colnames(refalt))

#Freq 뽑기, 부재할 경우 No_freq 로 대체
x2 <- str_split(data[, 8], ";")
TOPMED <- sapply(x2, function(x) {
  match <- regexpr("TOPMED=[^;]+", x)
  if (all(match == -1)) {
    return("No_freq")
  } else {
    return(sub("TOPMED=", "", regmatches(x, match)))
  }
})

x3 <- str_split(data[, 8], ";")
EAS_1000G <- sapply(x3, function(x) {
  match <- regexpr("dbNSFP_1000Gp3_EAS_AF=[^;]+", x)
  if (all(match == -1)) {
    return("No_freq")
  } else {
    return(sub("dbNSFP_1000Gp3_EAS_AF=", "", regmatches(x, match)))
  }
})

#A=7일 때 없음

#===========================================
#merge
#===========================================
#Train SNP information 추가
Train <- alt
Train_refalt <- refalt
Train <- cbind(Info, TOPMED, EAS_1000G,Train, Train_refalt)
#해당rsID에 alt 내 depth 가 존재한느 샘플 찾기
Match_samples <- apply(Train[, 11:110] != 0, 1, function(row) {
  x1 <- colnames(Train)[11:110][row]
  paste0(x1, collapse = ",")
})

Train$Match_samples <- Match_samples

#Train SNP information 추가
#merge
#Vali_Match_samples <- Vali[,ncol(Vali)]
merge <- Train
if(length(which(merge$Vali_Match_samples ==""))!=0){
merge <- merge[-which(merge$Vali_Match_samples ==""),]}
if(length(which(merge$Match_samples ==""))!=0){
merge <- merge[-which(merge$Match_samples ==""),]}

selected_rows <- sapply(merge$TOPMED, function(x) {
  values <- as.numeric(strsplit(x, ",")[[1]])
  any(values < 0.01)
})
temp <- merge[selected_rows,]

selected_rows2 <- sapply(temp$TOPMED, function(x){
	values <- as.numeric(strsplit(x, ",")[[1]])
	any(values > 0.99,  na.rm = TRUE)
})
temp <- temp[selected_rows2,]

selected_rows3 <- sapply(temp$EAS_1000G, function(x) {
  values <- as.numeric(strsplit(x, ",")[[1]])
  any(values < 0.01, na.rm = TRUE)
})
result0.01 <- temp[selected_rows3,]

selected_rows4 <- sapply(temp$EAS_1000G, function(x) {
  values <- as.numeric(strsplit(x, ",")[[1]])
  any(values > 0.99, na.rm = TRUE)
})
result0.99 <- temp[selected_rows4,]

result <- rbind(result0.01, result0.99)

x4 <- str_split(result$INFO, ";")
Pp_HDIV <- sapply(x4, function(x) {
  match <- regexpr("dbNSFP_Polyphen2_HDIV_pred=[^;]+", x)
  if (all(match == -1)) {
    return("No")
  } else {
    return(sub("dbNSFP_Polyphen2_HDIV_pred=", "", regmatches(x, match)))
  }
})

Pp_HVAR <- sapply(x4, function(x) {
  match <- regexpr("dbNSFP_Polyphen2_HVAR_pred=[^;]+", x)
  if (all(match == -1)) {
    return("No")
  } else {
    return(sub("dbNSFP_Polyphen2_HVAR_pred=", "", regmatches(x, match)))
  }
})

SIFT <- sapply(x4, function(x) {
  match <- regexpr("dbNSFP_SIFT_pred=[^;]+", x)
  if (all(match == -1)) {
    return("No")
  } else {
    return(sub("dbNSFP_SIFT_pred=", "", regmatches(x, match)))
  }
})

#CADD
CADD_phred <- sapply(x4, function(x) {
  match <- regexpr("dbNSFP_CADD_phred=[^;]+", x)
  if (all(match == -1)) {
    return("No")
  } else {
    return(sub("dbNSFP_CADD_phred=", "", regmatches(x, match)))
  }
})

#Clinvar
CLNDISDB <- sapply(x4, function(x) {
  match <- regexpr("CLNDISDB=[^;]+", x)
  if (all(match == -1)) {                                                                                                        return("No")
  } else {
    return(sub("CLNDISDB=", "", regmatches(x, match)))
  }
})

CLNSIG <- sapply(x4, function(x) {
  match <- regexpr("CLNSIG=[^;]+", x)
  if (all(match == -1)) {                                                                                                        return("No")
  } else {
    return(sub("CLNSIG=", "", regmatches(x, match)))
  }
})

CLNDN <- sapply(x4, function(x) {
  match <- regexpr("CLNDN=[^;]+", x)
  if (all(match == -1)) {                                                                                                        return("No")
  } else {
    return(sub("CLNDN=", "", regmatches(x, match)))
  }
})


result <- cbind(result, Pp_HDIV, Pp_HVAR, SIFT)
result <- cbind(result, CADD_phred, CLNDISDB, CLNSIG, CLNDN)
write.table(result ,"/ichrogene/project/temp/gylee/1.WES/2.gatk_result/skin100/4.VariantFiltration/Find/dbNSFP.CADD.clinvar.refaltdepth.vcf.merge", col.names=T, row.names=F, sep='\t', quote=F)
