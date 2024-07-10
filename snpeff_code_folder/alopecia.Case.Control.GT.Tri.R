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
#=======================================================
#Len#
#=======================================================
ALTLen <- sapply(result$ALT, function(x) {length(unlist(str_split(x,",")))})
#table(ALTLen)
#   1    2    3    4    5    6 
#2000 1268  243  106   52  105 

wLen1 <- which(ALTLen=="1")
wLen2 <- which(ALTLen=="2")
wLen3 <- which(ALTLen=="3")
wLen4 <- which(ALTLen=="4")
wLen5 <- which(ALTLen=="5")
wLen6 <- which(ALTLen=="6")

#Len2 중 A,V에서 동일한 genotype을 가지는 경우가 딱 1개만 존재하는 경우
resultLen2 <- result[wLen2,]

MT_row <- names(table(as.matrix(resultLen2[,c(Article.list, Vali.list, Control.list)])))[-1]
resultLen2$Match_Type <- "NA"
resultLen2$Match1_A <- 0
resultLen2$Match1_V <- 0
resultLen2$Match1_C <- 0
Types <- names(table(as.matrix(resultLen2[,11:179])))
alt1 <- c("0/1","1/1")
alt2 <- c("0/2","1/2","2/2")

for (B in 1:nrow(resultLen2)) {
#print(paste0("Start : ",B))
MT <- matrix(0, nrow=(length(MT_row)), ncol=3)
rownames(MT) <- MT_row
colnames(MT) <- c("A","V","C") 
 for (A in 2:length(Types)){
  Type <- Types[A]
  if(length(unname(table(as.character(resultLen2[B,Article.list])))[which(names(table(as.character(resultLen2[B,Article.list])))==Type)])!=0){
   MT[Type,"A"] <- unname(table(as.character(resultLen2[B,Article.list])))[which(names(table(as.character(resultLen2[B,Article.list])))==Type)]}
  if(length(unname(table(as.character(resultLen2[B,Vali.list])))[which(names(table(as.character(resultLen2[B,Vali.list])))==Type)])!=0){
   MT[Type,"V"] <- unname(table(as.character(resultLen2[B,Vali.list])))[which(names(table(as.character(resultLen2[B,Vali.list])))==Type)]}
  if(length(unname(table(as.character(resultLen2[B,Control.list])))[which(names(table(as.character(resultLen2[B,Control.list])))==Type)])!=0){
   MT[Type,"C"] <- unname(table(as.character(resultLen2[B,Control.list])))[which(names(table(as.character(resultLen2[B,Control.list])))==Type)]}
  }

walt1 <- which(rownames(MT) %in% alt1)
if(sum(MT[walt1,c("A","V")])==0){
 resultLen2$Match1_A[B] <- sum(MT[-walt1,"A"])
 resultLen2$Match1_V[B] <- sum(MT[-walt1,"V"])
 resultLen2$Match1_C[B] <- sum(MT[-walt1,"C"])
 resultLen2$Match_Type[B] <- "alt1"}
walt2 <- which(rownames(MT) %in% alt2)
if(sum(MT[walt2,c("A","V")])==0){
 resultLen2$Match1_A[B] <- sum(MT[-walt2,"A"])
 resultLen2$Match1_V[B] <- sum(MT[-walt2,"V"])
 resultLen2$Match1_C[B] <- sum(MT[-walt2,"C"])
 resultLen2$Match_Type[B] <- "alt2"}
}


	
unname(table(as.character(resultLen2[1,Control.list])))[which(names(table(as.character(resultLen2[1,Control.list])))==Type)]

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

write.table(result ,"Find/GT.Tri.merge", col.names=T, row.names=F, sep='\t', quote=F)

#QC
QC.result <- result
QC.result <- QC.result[which(QC.result$AC.fisher < 0.05),]
QC.result <- QC.result[which(QC.result$VC.fisher < 0.05),]
#QC.result <- QC.result[-which(QC.result$CADD_phred=="No"),]
#first_values <- sapply(str_split(QC.result$CADD_phred, ","), function(x) x[1])
#QC.result$CADD_phred <- as.numeric(first_values)
#QC.result <- QC.result[which(QC.result$CADD_phred >= 10),]
write.table(QC.result ,"Find/QC.GT.Tri.merge", col.names=T, row.names=F, sep='\t', quote=F)
