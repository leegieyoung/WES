#!/bin/Rscript
library(stringr)
setwd("/ichrogene/project/temp/gylee/1.WES/2.gatk_result/total69/4.VariantFiltration")
#data <- read.table("2020.jds.variant.vcf", head=T, comment.char="")
data <- read.table("snps.indels_filtered.PASS.snpEff.rsID.TMPRSS2.vcf", head=T, comment.char="")


Info <- data[,1:7]
Geno <- data[,10:ncol(data)]

#AD 뽑기
refalt <- ""
for (A in 1:ncol(Geno)){
		for (B in 1:nrow(Geno)){
		x1 <- unlist(str_split(Geno[B,A],":"))
		refalt <- c(refalt,x1[2])
	}
	refalt <- refalt[-1]
	Geno[,A] <- refalt
	refalt <- ""
}
#Alt depth 뽑기
alt <- ""
for (A in 1:ncol(Geno)){
	for (B in 1:nrow(Geno)){
		alt <- c(alt, str_split(Geno[,A], ",")[[B]][2])
	}
	alt <- alt[-1]
	Geno[,A] <- alt
	alt <- ""
}


#===========================================
#merge
#===========================================
#Train SNP information 추가
Train <- Geno[,20:ncol(Geno)]
Train <- cbind(Info, Train)
#해당rsID에 alt 내 depth 가 존재한느 샘플 찾기
Match_samples <- ""
for (A in 1:nrow(Train)){
	x1 <- colnames(Train)[8:ncol(Train)][which(Train[A,8:ncol(Train)] !=0)]
	x1 <- paste0(x1, collapse=",")
	Match_samples <- c(Match_samples, x1)
}
Match_samples <- Match_samples[-1]
Train$Match_samples <- Match_samples
Train <- Train[,c(1:7, ncol(Train))]


#Train SNP information 추가
Vali <- Geno[,1:19]   
Vali <- cbind(Info, Vali)
#해당rsID에 alt 내 depth 가 존재한느 샘플 찾기
Match_samples <- ""
for (A in 1:nrow(Vali)){ 
        x1 <- colnames(Vali)[8:ncol(Vali)][which(Vali[A,8:ncol(Vali)] !=0)]
        x1 <- paste0(x1, collapse=",")
        Match_samples <- c(Match_samples, x1)
}
Match_samples <- Match_samples[-1]
Vali$Match_samples <- Match_samples
Vali <- Vali[,c(1:7, ncol(Vali))]

write.table(Train ,"/ichrogene/project/temp/gylee/1.WES/2.gatk_result/total69/4.VariantFiltration/Find.Train_Vali_Matching/2020.jds.variant.vcf.Train", col.names=T, row.names=F, sep='\t', quote=F)
write.table(Vali ,"/ichrogene/project/temp/gylee/1.WES/2.gatk_result/total69/4.VariantFiltration/Find.Train_Vali_Matching/2020.jds.variant.vcf.Vali", col.names=T, row.names=F, sep='\t', quote=F)
