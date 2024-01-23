#!/bin/bash
Input=$1

bam_Dir="/ichrogene/project/temp/gylee/1.WES/0.raw/cnu/"
fastq_Dir="/ichrogene/project/temp/gylee/1.WES/0.raw/cnu/fastq"
ref_Dir="/ichrogene/project/temp/gylee/1.WES/REFERENCE/fasta/"
output_Dir="/ichrogene/project/temp/gylee/1.WES/2.weCall_result/"
Sing_Dir="/ichrogene/project/temp/gylee/Singularity"
scratch="/ichrogene/"
snpEff_Dir="/ichrogene/project/temp/gylee/1.WES/REFERENCE/snpEff/data/"
output_snpEff_Dir="/ichrogene/project/temp/gylee/1.WES/3.snpEff_result"
dbsnp_Dir="/ichrogene/project/temp/gylee/1.WES/REFERENCE/dbsnp"
QC_Dir="/ichrogene/project/temp/gylee/1.WES/1.QC/"

#VariantRecalibrator
echo "======================================"
echo "PASS - SNP"
bcftools view --threads 32 -f  'PASS' /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/4.VariantFiltration/snps_filtered.vcf.gz -Oz -o /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/4.VariantFiltration/snps_filtered.PASS.vcf.gz
echo "======================================"
echo "PASS - INDEL"
bcftools view --threads 32 -f  'PASS' /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/4.VariantFiltration/indels_filtered.vcf.gz -Oz -o /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/4.VariantFiltration/indels_filtered.PASS.vcf.gz
