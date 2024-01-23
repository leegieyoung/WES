#!/bin/bash
Result_Dir="/ichrogene/project/temp/gylee/1.WES/2.gatk_result/total69/4.VariantFiltration"
Singularity_Dir="/ichrogene/project/temp/gylee/Singularity"
data_Dir="/ichrogene/project/temp/gylee/1.WES/REFERENCE/snpEff/data"

#SNP
java -Xms60g -Xmx60g -jar ${Singularity_Dir}/snpEff/snpEff.jar eff -dataDir ${data_Dir} -v GRCh38.86 ${Result_Dir}/snps_filtered.PASS.vcf.gz > ${Result_Dir}/snps_filtered.PASS.snpEff.vcf
singularity exec --bind /ichrogene/:/ichrogene/ /ichrogene/project/temp/gylee/Singularity/PRS.sif bcftools view --threads 32 ${Result_Dir}/snps_filtered.PASS.snpEff.vcf  -Oz -o ${Result_Dir}/snps_filtered.PASS.snpEff.vcf.gz
java -Xms60g -Xmx60g -jar ${Singularity_Dir}/snpEff/SnpSift.jar annotate /ichrogene/project/temp/gylee/1.WES/REFERENCE/dbsnp/dbsnp151.GRCh38.p7.vcf.gz ${Result_Dir}/snps_filtered.PASS.snpEff.vcf.gz > ${Result_Dir}/snps_filtered.PASS.snpEff.rsID.vcf
singularity exec --bind /ichrogene/:/ichrogene/ /ichrogene/project/temp/gylee/Singularity/PRS.sif bcftools view --threads 32 ${Result_Dir}/snps_filtered.PASS.snpEff.rsID.vcf -Oz -o ${Result_Dir}/snps_filtered.PASS.snpEff.rsID.vcf.gz
java -Xms60g -Xmx60g -jar ${Singularity_Dir}/snpEff/SnpSift.jar dbnsfp -dataDir ${data_Dir} -v -db /ichrogene/project/temp/gylee/1.WES/REFERENCE/dbNSFP/dbNSFP4.5a.txt.gz ${Result_Dir}/snps_filtered.PASS.snpEff.rsID.vcf.gz > ${Result_Dir}/snps_filtered.PASS.snpEff.rsID.dbnsfp.vcf.gz

#INDEL
java -Xms60g -Xmx60g -jar ${Singularity_Dir}/snpEff/snpEff.jar eff -dataDir ${data_Dir} -v GRCh38.86 ${Result_Dir}/indels_filtered.PASS.vcf.gz > ${Result_Dir}/indels_filtered.PASS.snpEff.vcf
singularity exec --bind /ichrogene/:/ichrogene/ /ichrogene/project/temp/gylee/Singularity/PRS.sif bcftools view --threads 32 ${Result_Dir}/indels_filtered.PASS.snpEff.vcf  -Oz -o ${Result_Dir}/indels_filtered.PASS.snpEff.vcf.gz 
java -Xms60g -Xmx60g -jar ${Singularity_Dir}/snpEff/SnpSift.jar annotate /ichrogene/project/temp/gylee/1.WES/REFERENCE/dbsnp/dbsnp151.GRCh38.p7.vcf.gz ${Result_Dir}/indels_filtered.PASS.snpEff.vcf.gz > ${Result_Dir}/indels_filtered.PASS.snpEff.rsID.vcf
singularity exec --bind /ichrogene/:/ichrogene/ /ichrogene/project/temp/gylee/Singularity/PRS.sif bcftools view --threads 32 ${Result_Dir}/indels_filtered.PASS.snpEff.rsID.vcf -Oz -o ${Result_Dir}/indels_filtered.PASS.snpEff.rsID.vcf.gz
java -Xms60g -Xmx60g -jar ${Singularity_Dir}/snpEff/SnpSift.jar dbnsfp -dataDir ${data_Dir} -v -db /ichrogene/project/temp/gylee/1.WES/REFERENCE/dbNSFP/dbNSFP4.5a.txt.gz ${Result_Dir}/indels_filtered.PASS.snpEff.rsID.vcf.gz > ${Result_Dir}/indels_filtered.PASS.snpEff.rsID.dbnsfp.vcf.gz


