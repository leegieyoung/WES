library("ggplot2")
setwd("/ichrogene/project/temp/gylee/Code/CC_code_folder")
cli <- read.csv("clinical_cnu_skin.csv", head=T, comment.char="", sep=',')
dim(cli)
if(length(which(cli$MatchOfSurvey.ID=="X"))!=0){
cli <- cli[-which(cli$MatchOfSurvey.ID=="X"),]
}

if(length(which(cli$MatchOfSurvey.ID=="X"))!=0){
cli <- cli[-which(cli$MatchOfSurvey.ID=="X"),]
}
dim(cli)

cli <- cli[,-which(colnames(cli) =="MatchOfSurvey.ID")]

if(length(which(cli$indentometer=="" | cli$indentometer=="#DIV/0!"))!=0){
#cli <- cli[-which(cli$indentometer=="" | cli$indentometer=="#DIV/0!"),]
cli[which(cli$indentometer=="" | cli$indentometer=="#DIV/0!"),] <- "0"
}
if(length(which(cli$corneometer=="" | cli$corneometer=="#DIV/0!"))!=0){
cli[which(cli$corneometer=="" | cli$corneometer=="#DIV/0!"),] <- "0"  
}
if(length(which(cli$tewameter=="" | cli$tewameter=="#DIV/0!"))!=0){
cli[which(cli$tewameter=="" | cli$tewameter=="#DIV/0!"),] <- "0"
}
if(length(which(cli$melanin=="" | cli$melanin=="#DIV/0!"))!=0){
cli[which(cli$melanin=="" | cli$melanin=="#DIV/0!"),] <- "0"
}
if(length(which(cli$erythema=="" | cli$erythema=="#DIV/0!"))!=0){
cli[which(cli$erythema=="" | cli$erythema=="#DIV/0!"),] <- "0"
}

dim(cli)

#if(length(which(cli$height==0))!=0){
#cli <- cli[-which(cli$height==0),]
#}
#dim(cli)
#
#if(length(which(cli$weight==0))!=0){
#cli <- cli[-which(cli$weight==0),]
#}
#dim(cli)
#
#if(length(which(cli$BMI==0))!=0){
#cli <- cli[-which(cli$BMI==0),]
#}
#dim(cli)

SUR12=c("SUR1","SUR2.1","SUR2.2","SUR2.3","SUR2.4","SUR2.5","SUR2.6","SUR2.7","SUR3.2","SUR3.3","SUR3.4","SUR4.1","SUR4.3","SUR5.1","SUR5.2","SUR5.3","SUR5.4")
for (A in SUR12){
print(A)
print(table(cli[,A]))
print(length(which(cli[,A]==4 | cli[,A]==3)))
if(length(which(cli[,A]==4 | cli[,A]==3))!=0){
#cli <- cli[-which(cli[,A]==4 | cli[,A]==3),]
cli[which(cli[,A]==4 | cli[,A]==3),] <- "0"
}
}
dim(cli)

cli <- cli[,-which(colnames(cli) =="number")]
cli <- cli[,-which(colnames(cli) =="Chart.No.")]
cli <- cli[,-which(colnames(cli) =="SUR1.1")]

#for (A in 6:10){
	#print(paste0("ncol is : ",A))
	#print(sum(is.na(cli[,A])))
#	cli[,A] <- as.numeric(cli[,A])
#	cli[,A] <- scale(cli[,A], center=TRUE, scale=FALSE)
#}
cli_rm0 <- sapply(cli, function(x) {x[x == 0] <- NA; return(x)})
#CC
#CCdata <- cli[,-(1:4)]
CCdata <- as.data.frame(cli_rm0[,-(1:3)])
#CCdata <- CCdata[,c("indentometer","corneometer","tewameter","melanin","erythema","Age","MARKVU.PGA.AGE","height","weight","BMI","SUR1_GY","SUR1.T2D","SUR1.HBP","SUR1.Hlip","SUR1.PAD","SUR1.Tuber","SUR1.stroke","SUR1.T2D.HBP.Hlip","SUR1.T2D.Hlip","SUR1.T2D.Hlip_vs_HBP","SUR2.1","SUR2.2","SUR2.3","SUR2.4","SUR2.5","SUR2.6","SUR2.7","SUR3.2","SUR3.3","SUR3.4","SUR4.1","SUR4.3","SUR5.1","SUR5.2","SUR5.3","SUR5.4","SUR5.5_GY","SUR5.6_GY")]
CCdata <- CCdata[,c("indentometer","corneometer","tewameter","melanin","erythema","Age","MARKVU.PGA.AGE","height","weight","BMI","SUR1_GY","SUR1.T2D","SUR1.HBP","SUR1.Hlip","SUR1.T2D.HBP.Hlip","SUR1.T2D.Hlip","SUR1.PAD","SUR1.Tuber","SUR1.stroke","SUR2.1","SUR2.2","SUR2.3","SUR2.4","SUR2.5","SUR2.6","SUR2.7","SUR3.2","SUR3.3","SUR3.4","SUR4.1","SUR4.3","SUR5.1","SUR5.2","SUR5.3","SUR5.4","SUR5.5_GY","SUR5.6_GY")]

CCdata <- sapply(CCdata, as.numeric)
CCdata <- as.data.frame(CCdata)
correlation_matrix <- cor(CCdata, use = "pairwise.complete.obs")
write.table(correlation_matrix,"clinical_cnu_skin.cc.txt", col.names=T, row.names=T, quote=F, sep='\t')
correlation_df <- as.data.frame(as.table(correlation_matrix))

colnames(correlation_df) <- c("Var1", "Var2", "Corr")

correlation_df$Pvalue <- '1'
for (A in 1:nrow(correlation_df)){
test <- cor.test(CCdata[,as.character(correlation_df[A,1])], CCdata[,as.character(correlation_df[A,2])], use = "pairwise.complete.obs")
correlation_df$Pvalue[A]<- test$p.value
}
write.table(correlation_df,"cc.pvalue.txt", col.names=T, row.names=F, quote=F, sep='\t')

# 히트맵으로 시각화
png(paste0("skin_",nrow(cli),"_heatmap.png"), width=20, height=16, units="cm", res=200)
p <- ggplot(data = correlation_df, aes(x = Var1, y = Var2, fill = Corr)) +
  geom_tile() +
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", midpoint = 0, limit = c(-1, 1)) +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, vjust = 1, size = 6, hjust = 1), 
	axis.text.y = element_text(vjust = 1, size = 6, hjust = 1),
	legend.text = element_text(size=6),
	legend.title = element_text(size=10)) +
  labs(title = "Corr Heatmap")
print(p)
dev.off()
