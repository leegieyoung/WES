library(stringr)
setwd("/ichrogene/project/temp/gylee/1.WES/2.gatk_result/total69/4.VariantFiltration")
data <- read.table("snps.indels_filtered.PASS.snpEff.SnpSift.vcf", head=T, comment.char="")

filter.data <- data

x2 <- str_split(filter.data$INFO, ";")
ANN <- sapply(x2, function(x) {
match <- regexpr("ANN=[^;]+", x)
return(regmatches(x, match))
})

x3 <- str_split(ANN, "\\|")
GeneSymbol <- unlist(lapply(x3, function(x) x[4]))
Ensembl <- unlist(lapply(x3, function(x) x[5]))
Function <- unlist(lapply(x3, function(x) x[2]))
insilico <- unlist(lapply(x3, function(x) x[3]))
Gene <- as.data.frame(cbind(GeneSymbol, Ensembl, Function, insilico))

filter.data <- cbind(filter.data, Gene)

filter.data <- filter.data[,c(1:5,(ncol(filter.data)-3):(ncol(filter.data)))]
write.table(filter.data, "Find/snps.indels_filtered.PASS.snpEff.SnpSift.GeneANN.vcf", col.names=T, row.names=F, quote=F)
