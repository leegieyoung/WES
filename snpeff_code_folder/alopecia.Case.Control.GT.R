#!/bin/Rscript
library(stringr)
setwd("/ichrogene/project/temp/gylee/1.WES/2.gatk_result/alopecia.Case.Control/4.VariantFiltration")
if (!dir.exists(paste0("Find","/"))){
	dir.create(paste0("Find","/"))
}
#data <- read.table("2020.jds.variant.vcf", head=T, comment.char="")
data <- read.table("snps.indels_filtered.PASS.snpEff.SnpSift.vcf", head=T, comment.char="")
Article.list <- scan("/ichrogene/project/temp/gylee/Code/snpeff_code_folder/Article.sample.list", what=character(0))
Vali.list <- scan("/ichrogene/project/temp/gylee/Code/snpeff_code_folder/Validation.sample.list",what=character(0))
Control.list <- scan("/ichrogene/project/temp/gylee/Code/snpeff_code_folder/Control.sample.list",what=character(0))

#Only SNP
ACGT <- sapply(data$ALT,function(x) { if(nchar(x)==1){
 x1 <- x} else {
 x1 <- 0}})
data <- data[which(ACGT!=0),]

Info <- data[,1:8]
Geno <- data[,10:ncol(data)]

#AD 뽑기
alt <- sapply(Geno, function(col) sapply(str_split(col, ":"), `[`, 1))
AD <- sapply(Geno, function(col) sapply(str_split(col, ":"), `[`, 2))
colnames(AD) <- sapply(colnames(AD),function(x) {paste0("AD_",x)})

#GT 뽑기
alt <- gsub("0/0",0,alt)
alt <- gsub("0/1",1,alt)
alt <- gsub("1/1",2,alt)
alt <- gsub("0\\|0",0,alt)
alt <- gsub("0\\|1",1,alt)
alt <- gsub("1\\|1",2,alt)
alt <- gsub("\\./\\.",0,alt)
alt <- gsub("\\.\\|\\.",0,alt)

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
Article <- alt[,which(colnames(alt) %in% Article.list)]
Article <- cbind(Info, TOPMED, EAS_1000G,Article)
#해당rsID에 alt 내 depth 가 존재한느 샘플 찾기
Match_samples <- apply(Article[, 11:ncol(Article)] != 0, 1, function(row) {
  x1 <- colnames(Article)[11:ncol(Article)][row]
  paste0(x1, collapse = ",")
})
Article$Article_Match_samples <- Match_samples
N_Article_Match_samples <- sapply(Article$Article_Match_samples, function(row) {
  if(length(which(row==""))){
  x1 <- 0} else {
  x1 <- length(str_split(row, ",")[[1]])
}})
Article$N_Article_Match_samples <- unname(N_Article_Match_samples)

Vali <- alt[,which(colnames(alt) %in% Vali.list)]
Vali <- cbind(Info, TOPMED, EAS_1000G,Vali)
#해당rsID에 alt 내 depth 가 존재한느 샘플 찾기
Vali_Match_samples <- apply(Vali[, 11:ncol(Vali)] != 0, 1, function(row) {
  x1 <- colnames(Vali)[11:ncol(Vali)][row]
  paste0(x1, collapse = ",")
})
Vali$Vali_Match_samples <- Vali_Match_samples
N_Vali_Match_samples <- sapply(Vali$Vali_Match_samples, function(row) {
  if(length(which(row==""))){
  x1 <- 0} else {
  x1 <- length(str_split(row, ",")[[1]])
}})
Vali$N_Vali_Match_samples <- unname(N_Vali_Match_samples)

Control <- alt[,which(colnames(alt) %in% Control.list)]
Control <- cbind(Info, TOPMED, EAS_1000G,Control)
#해당rsID에 alt 내 depth 가 존재한느 샘플 찾기
Control_Match_samples <- apply(Control[, 11:ncol(Control)] != 0, 1, function(row) {
  x1 <- colnames(Control)[11:ncol(Control)][row]
  paste0(x1, collapse = ",")
})
Control$Control_Match_samples <- Control_Match_samples
N_Control_Match_samples <- sapply(Control$Control_Match_samples, function(row) {
  if(length(which(row==""))){
  x1 <- 0} else {
  x1 <- length(str_split(row, ",")[[1]])
}})
Control$N_Control_Match_samples <- unname(N_Control_Match_samples)

#merge
#merge <- cbind(Article, Vali[,11:ncol(Vali)], Control[,11:ncol(Control)])

merge <- cbind(Info,TOPMED, EAS_1000G, alt,AD, N_Article_Match_samples, N_Vali_Match_samples, N_Control_Match_samples)
if(length(which(merge$N_Article_Match_samples == 0)) !=0){
merge <- merge[-which(merge$N_Article_Match_samples == 0),]}
if(length(which(merge$N_Vali_Match_samples == 0)) !=0){
merge <- merge[-which(merge$N_Vali_Match_samples == 0),]}


#selected_rows1 <- sapply(merge$TOPMED, function(x) {
#  values <- as.numeric(strsplit(x, ",")[[1]])
#  any(values < 0.01)
#})
#
#selected_rows2 <- sapply(merge$TOPMED, function(x){
#       values <- as.numeric(strsplit(x, ",")[[1]])
#       any(values > 0.99,  na.rm = TRUE)
#})
#selected_rows3 <- sapply(merge$TOPMED, function(x){
#        values <- as.numeric(strsplit(x, ",")[[1]])
#        any(values == "No_freq",  na.rm = TRUE)
#})
#wtopmed <- c(selected_rows1, selected_rows2, selected_rows3)
#merge <- merge[wtopmed,]

selected_rows4 <- sapply(merge$EAS_1000G, function(x) {
  values <- as.numeric(strsplit(x, ",")[[1]])
  any(values < 0.01, na.rm = TRUE)
})
wselected_rows4 <- which(selected_rows4 == "TRUE")

selected_rows5 <- sapply(merge$EAS_1000G, function(x) {
  values <- as.numeric(strsplit(x, ",")[[1]])
  any(values > 0.99, na.rm = TRUE)
})
wselected_rows5 <- which(selected_rows5 == "TRUE")
wselected_rows6 <- which(merge$EAS_1000G=="No_freq")

weas <- c(wselected_rows4, wselected_rows5, wselected_rows6)
if(length(unique(sort(weas)))==length(weas)){
        result <- merge[weas,]
} else {
        print("The weas is error")
}

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
  if (all(match == -1)) {
	return("No")
  } else {
    return(sub("CLNDISDB=", "", regmatches(x, match)))
  }
})

CLNSIG <- sapply(x4, function(x) {
  match <- regexpr("CLNSIG=[^;]+", x)
  if (all(match == -1)) {
	return("No")
  } else {
    return(sub("CLNSIG=", "", regmatches(x, match)))
  }
})

CLNDN <- sapply(x4, function(x) {
  match <- regexpr("CLNDN=[^;]+", x)
  if (all(match == -1)) {
	return("No")
  } else {
    return(sub("CLNDN=", "", regmatches(x, match)))
  }
})

#Gene annotation
x5 <- str_split(result$INFO, ";")
ANN <- sapply(x5, function(x) {
match <- regexpr("ANN=[^;]+", x)
return(regmatches(x, match))
})

x6 <- str_split(ANN, "\\|")
GeneSymbol <- unlist(lapply(x6, function(x) x[4]))
Ensembl <- unlist(lapply(x6, function(x) x[5]))
Function <- unlist(lapply(x6, function(x) x[2]))
insilico <- unlist(lapply(x6, function(x) x[3]))
Gene <- as.data.frame(cbind(GeneSymbol, Ensembl, Function, insilico))

result <- cbind(result, Pp_HDIV, Pp_HVAR, SIFT, CADD_phred, CLNDISDB, CLNSIG, CLNDN, Gene)
result <- result[which(result$N_Control_Match_samples < length(Control.list)/10),]
##fisher #느림
#for (A in 1:nrow(result)){
#        A.table <- matrix(c(result$N_Article_Match_samples[A],(50-result$N_Article_Match_samples[A]),
#			    result$N_Control_Match_samples[A],(100-result$N_Control_Match_samples[A])), nrow=2)
#	V.table <- matrix(c(result$N_Vali_Match_samples[A],(19-result$N_Vali_Match_samples[A]),
#			    result$N_Control_Match_samples[A],(100-result$N_Control_Match_samples[A])), nrow=2)
#        A.fisher <- fisher.test(A.table, alternative = "two.sided")
#        V.fisher <- fisher.test(V.table, alternative = "two.sided")
#        result$AC.fisher[A] <- A.fisher$p.value
#        result$VC.fisher[A] <- V.fisher$p.value
#}

#Fisher test
# 사전에 테이블 생성
len_article <- length(Article.list)
len_control <- length(Control.list)
len_vali <- length(Vali.list)

AC_tables <- sapply(1:nrow(result), function(A) {
    c(result$N_Article_Match_samples[A], len_article - result$N_Article_Match_samples[A],
      result$N_Control_Match_samples[A], len_control - result$N_Control_Match_samples[A])
})
VC_tables <- sapply(1:nrow(result), function(A) {
    c(result$N_Vali_Match_samples[A], len_vali - result$N_Vali_Match_samples[A],
      result$N_Control_Match_samples[A], len_control - result$N_Control_Match_samples[A])
})

AC_fishers <- apply(AC_tables, 2, function(table) fisher.test(matrix(table, nrow = 2), alternative = "two.sided")$p.value)
VC_fishers <- apply(VC_tables, 2, function(table) fisher.test(matrix(table, nrow = 2), alternative = "two.sided")$p.value)

result$AC.fisher <- AC_fishers
result$VC.fisher <- VC_fishers

write.table(result ,"Find/GT.merge", col.names=T, row.names=F, sep='\t', quote=F)

#QC
QC.result <- result
QC.result <- QC.result[which(QC.result$AC.fisher < 0.05),]
QC.result <- QC.result[which(QC.result$VC.fisher < 0.05),]
QC.result <- QC.result[-which(QC.result$CADD_phred=="No"),]
#first_values <- sapply(str_split(QC.result$CADD_phred, ","), function(x) x[1])
#QC.result$CADD_phred <- as.numeric(first_values)
#QC.result <- QC.result[which(QC.result$CADD_phred >= 10),]
write.table(QC.result ,"Find/QC.GT.merge", col.names=T, row.names=F, sep='\t', quote=F)
