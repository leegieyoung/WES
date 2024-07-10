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
data <- data[which(ACGT==0),]

Info <- data[,1:8]
Geno <- data[,10:ncol(data)]

#AD 뽑기
alt <- sapply(Geno, function(col) sapply(str_split(col, ":"), `[`, 1))
AD <- sapply(Geno, function(col) sapply(str_split(col, ":"), `[`, 2))
colnames(AD) <- sapply(colnames(AD),function(x) {paste0("AD_",x)})
#GT 뽑기
alt <- gsub("\\|","/",alt)
alt <- gsub("0/0",0,alt)
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

#===========================================
merge <- cbind(Info,TOPMED, EAS_1000G, alt,AD)

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

#Article, Validation에서 전부 Ref homo인 경우 제거
AVresult <- result[,c(Article.list,Vali.list)]
W <- which(apply(AVresult, 1, function(x) all(x == 0)))

if(sum(as.numeric(as.matrix(AVresult[W,])))==0){
result <- result[-W,]
}
#=======================================================
#Len#
#=======================================================
result$Match_Type <- "NA"
result$Match_A <- 0
result$Match_V <- 0
result$Match_C <- 0

ALTLen <- sapply(result$ALT, function(x) {length(unlist(str_split(x,",")))})
Types <- names(table(alt))
Types <- Types[-1]
MT <- matrix(0,nrow=length(Types), ncol=3)
rownames(MT) <- Types
colnames(MT) <- c("A","V","C")

alt1 <- c("0/1","1/1")
alt2 <- c("0/2","1/2","2/2")
alt3 <- c("0/3","1/3","2/3","3/3")
alt4 <- c("0/4","1/4","2/4","3/4","4/4")
alt5 <- c("0/5","1/5","2/5","3/5","4/5","5/5")
alt6 <- c("0/6","1/6","2/6","3/6","4/6","5/6","6/6")

walt1 <- which(rownames(MT) %in% alt1)
walt2 <- which(rownames(MT) %in% alt2)
walt3 <- which(rownames(MT) %in% alt3)
walt4 <- which(rownames(MT) %in% alt4)
walt5 <- which(rownames(MT) %in% alt5)
walt6 <- which(rownames(MT) %in% alt6)

#table(ALTLen)
#   1    2    3    4    5    6 
#3271 1908  348  143   72  121 
for (B in 1:nrow(result)){
 MT <- matrix(0,nrow=length(Types), ncol=3)
 rownames(MT) <- Types
 colnames(MT) <- c("A","V","C")

 for (A in 1:length(Types)){
  Type <- Types[A]
  if(length(unname(table(as.character(result[B,Article.list])))[which(names(table(as.character(result[B,Article.list])))==Type)])!=0){
   MT[Type,"A"] <- unname(table(as.character(result[B,Article.list])))[which(names(table(as.character(result[B,Article.list])))==Type)]}
  if(length(unname(table(as.character(result[B,Vali.list])))[which(names(table(as.character(result[B,Vali.list])))==Type)])!=0){
   MT[Type,"V"] <- unname(table(as.character(result[B,Vali.list])))[which(names(table(as.character(result[B,Vali.list])))==Type)]}
  if(length(unname(table(as.character(result[B,Control.list])))[which(names(table(as.character(result[B,Control.list])))==Type)])!=0){
   MT[Type,"C"] <- unname(table(as.character(result[B,Control.list])))[which(names(table(as.character(result[B,Control.list])))==Type)]}
  }

if(sum(MT[,"A"]) != 0 & sum(MT[,"V"]) != 0){
 if(sum(MT[-walt1,"A"])==0){
  result$Match_A[B] <- sum(MT[walt1,"A"])
  result$Match_V[B] <- sum(MT[walt1,"V"])
  result$Match_C[B] <- sum(MT[walt1,"C"])
  result$Match_Type[B] <- "alt1"
 } else if (sum(MT[-walt2,"A"])==0){
  result$Match_A[B] <- sum(MT[walt2,"A"])
  result$Match_V[B] <- sum(MT[walt2,"V"])
  result$Match_C[B] <- sum(MT[walt2,"C"])
  result$Match_Type[B] <- "alt2"
 } else if (sum(MT[-walt3,"A"])==0){
  result$Match_A[B] <- sum(MT[walt3,"A"])
  result$Match_V[B] <- sum(MT[walt3,"V"])
  result$Match_C[B] <- sum(MT[walt3,"C"])
  result$Match_Type[B] <- "alt3"
 } else if (sum(MT[-walt4,"A"])==0){
  result$Match_A[B] <- sum(MT[walt4,"A"])
  result$Match_V[B] <- sum(MT[walt4,"V"])
  result$Match_C[B] <- sum(MT[walt4,"C"])
  result$Match_Type[B] <- "alt4"
 } else if (sum(MT[-walt5,"A"])==0){
  result$Match_A[B] <- sum(MT[walt5,"A"])
  result$Match_V[B] <- sum(MT[walt5,"V"])
  result$Match_C[B] <- sum(MT[walt5,"C"])
  result$Match_Type[B] <- "alt5"
 } else if (sum(MT[-walt6,"A"])==0){
  result$Match_A[B] <- sum(MT[walt6,"A"])
  result$Match_V[B] <- sum(MT[walt6,"V"])
  result$Match_C[B] <- sum(MT[walt6,"C"])
  result$Match_Type[B] <- "alt6"
 }
 }
}
result_temp <- result

wNA <- which(result$Match_Type=="NA")
if(length(wNA)!=0){
result <- result[-wNA,]}

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
result <- result[which(result$Match_C < length(Control.list)/10),]
result[, 11:179] <- apply(result[, 11:179], 2, function(x) {
  if (is.character(x)) {
	gsub("/", ",", x)
  } else {
    x
  }
})

result[, 11:179] <- apply(result[, 11:179], 2, function(x) {
  if (is.character(x)) {
        gsub("\\|", ",", x)
  } else {
    x
  }
})

#Fisher test
# 사전에 테이블 생성
len_article <- length(Article.list)
len_control <- length(Control.list)
len_vali <- length(Vali.list)

AC_tables <- sapply(1:nrow(result), function(A) {
    c(result$Match_A[A], len_article - result$Match_A[A],
      result$Match_C[A], len_control - result$Match_C[A])
})
VC_tables <- sapply(1:nrow(result), function(A) {
    c(result$Match_V[A], len_vali - result$Match_V[A],
      result$Match_C[A], len_control - result$Match_C[A])
})

AC_fishers <- apply(AC_tables, 2, function(table) fisher.test(matrix(table, nrow = 2), alternative = "two.sided")$p.value)
VC_fishers <- apply(VC_tables, 2, function(table) fisher.test(matrix(table, nrow = 2), alternative = "two.sided")$p.value)

result$AC.fisher <- AC_fishers
result$VC.fisher <- VC_fishers

write.table(result ,"Find/GT.multi.merge", col.names=T, row.names=F, sep='\t', quote=F)

#QC
QC.result <- result
QC.result <- QC.result[which(QC.result$AC.fisher < 0.05),]
QC.result <- QC.result[which(QC.result$VC.fisher < 0.05),]
#QC.result <- QC.result[-which(QC.result$CADD_phred=="No"),]
#first_values <- sapply(str_split(QC.result$CADD_phred, ","), function(x) x[1])
#QC.result$CADD_phred <- as.numeric(first_values)
#QC.result <- QC.result[which(QC.result$CADD_phred >= 10),]
write.table(QC.result ,"Find/QC.GT.multi.merge", col.names=T, row.names=F, sep='\t', quote=F)
