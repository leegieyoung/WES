library(stringr)
library(data.table)

setwd("/ichrogene/project/temp/gylee/1.WES/2.gatk_result/total69/4.VariantFiltration/Find")
data <- read.table("dbNSFP.CADD.clinvar.refaltdepth.vcf.merge.forTtest.txt", head=T)


for (A in 1:nrow(data)){
	A.table <- matrix(c(data$Article[A],(50-data$Article[A]),data$Control[A],(100-data$Control[A])), nrow=2)
	V.table <- matrix(c(data$Validation[A],(19-data$Validation[A]),data$Control[A],(100-data$Control[A])), nrow=2)
	A.fisher <- fisher.test(A.table, alternative = "two.sided")
        V.fisher <- fisher.test(V.table, alternative = "two.sided")
	data$AC.fisher[A] <- A.fisher$p.value
	data$VC.fisher[A] <- V.fisher$p.value
}


x2 <- str_split(data$INFO, ";")
ANN <- sapply(x2, function(x) {
match <- regexpr("ANN=[^;]+", x)
return(regmatches(x, match))
})

x3 <- str_split(ANN, "\\|")
GeneSymbol <- unlist(lapply(x3, function(x) x[4]))
Ensembl <- unlist(lapply(x3, function(x) x[5]))
Function <- unlist(lapply(x3, function(x) x[2]))
#insilico <- unlist(lapply(x3, function(x) x[3]))
Gene <- as.data.frame(cbind(GeneSymbol, Ensembl, Function))

data <- cbind(data, Gene)


write.table(data, "dbNSFP.CADD.clinvar.refaltdepth.vcf.merge.Ttest.txt", col.names=T, row.names=F, quote=F)
