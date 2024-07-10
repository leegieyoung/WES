#!/bin/bash
Input=$1
Result_Dir="/ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/4.VariantFiltration"
Singularity_Dir="/ichrogene/project/temp/gylee/Singularity"
data_Dir="/ichrogene/project/temp/gylee/1.WES/REFERENCE/snpEff/data"
REFERENCE="/ichrogene/project/temp/gylee/1.WES/REFERENCE/"
Seq=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 "X" "Y" "M")

#SNP
snp_index() {
	if [ $# -ne 1 ];then
        echo "Please enter Sample_Name"
               exit
fi
	echo "${Input} / snpEff / GRCh38.86 / chr${A}_snps_filtered.PASS"
bcftools reheader --threads 32 -h ${Result_Dir}/temp/snp_header.gz \
 ${Result_Dir}/temp/chr${A}_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz -o ${Result_Dir}/temp/reh.chr${A}_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz

bcftools reheader --threads 32 -h ${Result_Dir}/temp/indel_header.gz \
 ${Result_Dir}/temp/chr${A}_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz -o ${Result_Dir}/temp/reh.chr${A}_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz

bcftools index -f --threads 32 ${Result_Dir}/temp/reh.chr${A}_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz 
bcftools index -f --threads 32 ${Result_Dir}/temp/reh.chr${A}_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz
}

#=================================
bcftools view -h ${Result_Dir}/temp/chrM_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz -Oz -o ${Result_Dir}/temp/snp_header.gz
bcftools view -h ${Result_Dir}/temp/chrM_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz -Oz -o ${Result_Dir}/temp/indel_header.gz

for A in "${Seq[@]}"
do
snp_index ${A}
sleep 2
done
wait

bcftools concat --threads 31 -n -Oz \
 ${Result_Dir}/temp/reh.chr1_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr2_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr3_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr4_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr5_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr6_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr7_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr8_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr9_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr10_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr11_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr12_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr13_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr14_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr15_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr16_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr17_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr18_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr19_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr20_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr21_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr22_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chrX_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chrY_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chrM_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 > ${Result_Dir}/snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz 

bcftools concat --threads 31 -n -Oz \
 ${Result_Dir}/temp/reh.chr1_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr2_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr3_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr4_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr5_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr6_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr7_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr8_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr9_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr10_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr11_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr12_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr13_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr14_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr15_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr16_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr17_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr18_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr19_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr20_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr21_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chr22_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chrX_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chrY_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 ${Result_Dir}/temp/reh.chrM_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz \
 > ${Result_Dir}/indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz

