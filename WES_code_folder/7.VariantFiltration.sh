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
echo "VariantFiltration - SNP"
mkdir /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/4.VariantFiltration

gatk --java-options "-Xms50G -Xmx50G -XX:ParallelGCThreads=32" SelectVariants \
    -V /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/CalculateGenotypePosteriors/trio_refined_99.9.vcf.gz \
    -select-type SNP \
    -O /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/4.VariantFiltration/snps.vcf.gz

gatk --java-options "-Xms50G -Xmx50G -XX:ParallelGCThreads=32" VariantFiltration \
   -V /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/4.VariantFiltration/snps.vcf.gz \
   -filter "QD < 2.0" --filter-name "QD2" \
   -filter "QUAL < 30.0" --filter-name "QUAL30" \
   -filter "SOR > 3.0" --filter-name "SOR3" \
   -filter "FS > 60.0" --filter-name "FS60" \
   -filter "MQ < 40.0" --filter-name "MQ40" \
   -filter "MQRankSum < -12.5" --filter-name "MQRankSum-12.5" \
   -filter "ReadPosRankSum < -8.0" --filter-name "ReadPosRankSum-8" \
   -O /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/4.VariantFiltration/snps_filtered.vcf.gz

echo "======================================"
echo "VariantFiltration - SNP"

gatk --java-options "-Xms50G -Xmx50G -XX:ParallelGCThreads=32" SelectVariants \
    -V /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/CalculateGenotypePosteriors/trio_refined_99.9.vcf.gz \
    -select-type INDEL \
    -O /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/4.VariantFiltration/indels.vcf.gz

gatk --java-options "-Xms50G -Xmx50G -XX:ParallelGCThreads=32" VariantFiltration \
     -V /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/4.VariantFiltration/indels.vcf.gz \
    -filter "QD < 2.0" --filter-name "QD2" \
    -filter "QUAL < 30.0" --filter-name "QUAL30" \
    -filter "FS > 200.0" --filter-name "FS200" \
    -filter "ReadPosRankSum < -20.0" --filter-name "ReadPosRankSum-20" \
    -O /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/4.VariantFiltration/indels_filtered.vcf.gz
