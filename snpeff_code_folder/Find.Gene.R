library(stringr)
library(data.table)

SAMPLE <- Sys.getenv("SAMPLE")
RESULT_DIR <- Sys.getenv("RESULT_DIR")

setwd(RESULT_DIR)
data <- read.table(paste0(RESULT_DIR, "/temp.vcf"), head=T, comment.char="")

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
#insilico <- unlist(lapply(x3, function(x) x[3]))
Gene <- as.data.frame(cbind(GeneSymbol, Ensembl, Function))

#filter.data <- cbind(filter.data, Gene)
filter.data <- filter.data[,1:5]

#"A1","OR","LOG(OR)_SE","P" in glm
filter.data$key <- paste0(filter.data$X.CHROM,":",filter.data$POS)
GLM <- fread(paste0(RESULT_DIR,"/1e-2.snp.glm"), head=T)
GLM$key <- paste0(GLM$"#CHROM",":",GLM$POS)

info_GLM <- GLM[which(GLM$key %in% filter.data$key), c("A1","OR","LOG(OR)_SE","A1_FREQ","P")]
filter.data <- filter.data[,-which(colnames(filter.data) == "key")]
filter.data <- cbind(filter.data, info_GLM, Gene)

write.table(filter.data, paste0(RESULT_DIR, "/1e-2.snp.snpEff.dbsnp.GeneANN.vcf"), col.names=T, row.names=F, quote=F)

