#!/bin/Rscript
library(stringr)
setwd("/ichrogene/project/temp/gylee/1.WES/2.gatk_result/alopecia.Case.Control/4.VariantFiltration")
if (!dir.exists(paste0("Find_Nomaf","/"))){
	dir.create(paste0("Find_Nomaf","/"))
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

#Freq 뽑기, 부재할 경우 No_freq 로 대체
x1 <- str_split(data[, 8], ";")
EAS_1000G <- sapply(x1, function(x) {
  match <- regexpr("dbNSFP_1000Gp3_EAS_AF=[^;]+", x)
  if (all(match == -1)) {
    return("No_freq")
  } else {
    return(sub("dbNSFP_1000Gp3_EAS_AF=", "", regmatches(x, match)))  }})

#selected_rows1 <- sapply(EAS_1000G, function(x) {
#  values <- as.numeric(strsplit(x, ",")[[1]])
#  any(values < 0.05, na.rm = TRUE)
#})
#wselected_rows1 <- which(selected_rows1 == "TRUE")
#
#selected_rows2 <- sapply(EAS_1000G, function(x) {
#  values <- as.numeric(strsplit(x, ",")[[1]])
#  any(values > 0.95, na.rm = TRUE)
#})
#wselected_rows2 <- which(selected_rows2 == "TRUE")
#wselected_rows3 <- which(EAS_1000G=="No_freq")
#
#weas <- c(wselected_rows1, wselected_rows2, wselected_rows3)
#data <- data[weas,]

#AC뽑기, 1이하인 경우 제거
x2 <- str_split(data[, 8], ";")
AC <- sapply(x2, function(x) {
  match <- regexpr("AC=[^;]+", x)
  if (all(match == -1)) {
    return("No_AC")
  } else {
    return(sub("AC=", "", regmatches(x, match)[[1]]))
  }
})
wselected_rows4 <- which(as.numeric(AC) >= 2)
data <- data[wselected_rows4,]

#AD 뽑기
Geno <- data[,10:ncol(data)]
#Alt depth 뽑기, A 또는 V에서alt depth=0 인 경우 제거
Geno_AD <- sapply(Geno, function(col) sapply(str_split(col, ":"), `[`, 2))
ALT <- matrix(nrow=nrow(Geno_AD), ncol=ncol(Geno_AD))
for ( A in 1:ncol(Geno_AD)){
        temp <- Geno_AD[,A]
        temp2 <- unlist(lapply(str_split(temp,","), `[`,2))
        ALT[,A] <- temp2
}
colnames(ALT) <- colnames(Geno_AD)
A_ALT <- ALT[,Article.list]
A_zero <- apply(A_ALT,1, function(x) {all(x == "0")})
wA_zero <- which(A_zero=="TRUE")
V_ALT <- ALT[,Vali.list]
V_zero <- apply(V_ALT,1, function(x) {all(x == "0")})
wV_zero <- which(V_zero=="TRUE")
wAV_zero <- unique(c(wA_zero, wV_zero))
data <- data[-wAV_zero,]

#> dim(data)
#[1] 50041   178
#0.05/50041 = 9.991807e-07, GQ 60 이상
#GQ > 13 이상 = 0.05
#GQ QC
Geno <- data[,10:ncol(data)]
GQ <- sapply(Geno, function(col) sapply(str_split(col, ":"), `[`, 4))
colnames(GQ) <- sapply(colnames(GQ),function(x) {paste0("GQ_",x)})

#GQ 가 A,V에서 모두 13 미만인 경우
GQ <- gsub('\\.',0,GQ)
A_GQ <- GQ[,paste0("GQ_",Article.list)]
A_GQ_z <- apply(A_GQ,1, function(x) {all(as.numeric(x) < 13)})
wA_GQ_z <- which(A_GQ_z=="TRUE")
V_GQ <- GQ[,paste0("GQ_",Vali.list)]
V_GQ_z <- apply(V_GQ,1, function(x) {all(as.numeric(x) < 13)})
wV_GQ_z <- which(V_GQ_z=="TRUE")
wAV_GQ_z <- unique(wA_GQ_z, wV_GQ_z)
data <- data[-wAV_GQ_z,]
#> dim(data)
#[1] 45839   178

#GQ가 13 미만인 경우, alt = ./.
Info <- data[,1:8]
Geno <- data[,10:ncol(data)]
x1 <- str_split(data[, 8], ";")
EAS_1000G <- sapply(x1, function(x) {
  match <- regexpr("dbNSFP_1000Gp3_EAS_AF=[^;]+", x)
  if (all(match == -1)) {
    return("No_freq")
  } else {
    return(sub("dbNSFP_1000Gp3_EAS_AF=", "", regmatches(x, match)))  }})

alt <- sapply(Geno, function(col) sapply(str_split(col, ":"), `[`, 1))
AD <- sapply(Geno, function(col) sapply(str_split(col, ":"), `[`, 2))
colnames(AD) <- sapply(colnames(AD),function(x) {paste0("AD_",x)})
GQ <- sapply(Geno, function(col) sapply(str_split(col, ":"), `[`, 4))
colnames(GQ) <- sapply(colnames(GQ),function(x) {paste0("GQ_",x)})
GQ <- gsub('\\.',0,GQ)
alt <- gsub("\\|","/",alt)

for (A in 1:ncol(GQ)){
 wGQ13 <- which(as.numeric(GQ[,A]) < 13)
 alt[wGQ13,A]  <- "."
 AD[wGQ13,A] <- "."
}

DP <- sapply(Geno, function(col) sapply(str_split(col, ":"), `[`, 3))
colnames(DP) <- sapply(colnames(DP),function(x) {paste0("DP_",x)})

alt <- gsub("0/0",0,alt)
alt <- gsub("0/1",1,alt)
alt <- gsub("1/1",2,alt)

#===========================================
#merge
#===========================================
#Train SNP information 추가
Article <- alt[,which(colnames(alt) %in% Article.list)]
Article <- cbind(Info, EAS_1000G,Article)
#해당rsID에 alt 내 depth 가 존재한느 샘플 찾기
Match_samples <- apply(Article[, Article.list] != 0 & Article[, Article.list] != ".", 1, function(row) {
  x1 <- colnames(Article[,Article.list])[row]
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
Vali <- cbind(Info, EAS_1000G,Vali)
#해당rsID에 alt 내 depth 가 존재한느 샘플 찾기
Vali_Match_samples <- apply(Vali[, Vali.list] != 0 & Vali[, Vali.list] != ".", 1, function(row) {
  x1 <- colnames(Vali[,Vali.list])[row]
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
Control <- cbind(Info, EAS_1000G,Control)
#해당rsID에 alt 내 depth 가 존재한느 샘플 찾기
Control_Match_samples <- apply(Control[, Control.list] != 0 & Control[, Control.list] != ".", 1, function(row) {
  x1 <- colnames(Control[,Control.list])[row]
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

merge <- cbind(Info, EAS_1000G, alt,AD,GQ, N_Article_Match_samples, N_Vali_Match_samples, N_Control_Match_samples)
if(length(which(merge$N_Article_Match_samples == 0)) !=0){
merge <- merge[-which(merge$N_Article_Match_samples == 0),]}
if(length(which(merge$N_Vali_Match_samples == 0)) !=0){
merge <- merge[-which(merge$N_Vali_Match_samples == 0),]}
merge <- merge[which(merge$N_Control_Match_samples < length(Control.list)/10),]

#Fisher test
# 사전에 테이블 생성
AC_tables <- sapply(1:nrow(merge), function(A) {
    c(merge$N_Article_Match_samples[A], length(which(merge[A,Article.list]!=".")) - merge$N_Article_Match_samples[A],
      merge$N_Control_Match_samples[A], length(which(merge[A,Control.list]!=".")) - merge$N_Control_Match_samples[A])
})
VC_tables <- sapply(1:nrow(merge), function(A) {
    c(merge$N_Vali_Match_samples[A], length(which(merge[A,Vali.list]!=".")) - merge$N_Vali_Match_samples[A],
      merge$N_Control_Match_samples[A], length(which(merge[A,Control.list]!=".")) - merge$N_Control_Match_samples[A])
})

AC_fishers <- apply(AC_tables, 2, function(table) fisher.test(matrix(table, nrow = 2), alternative = "two.sided")$p.value)
VC_fishers <- apply(VC_tables, 2, function(table) fisher.test(matrix(table, nrow = 2), alternative = "two.sided")$p.value)

merge$AC.fisher <- AC_fishers
merge$VC.fisher <- VC_fishers

#result <- merge[which(merge$AC.fisher < 0.05 & merge$VC.fisher < 0.05),]
#fisher 안봄
result <- merge

#incilico
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

write.table(result ,"Find_Nomaf/QC.GT.merge", col.names=T, row.names=F, sep='\t', quote=F)
