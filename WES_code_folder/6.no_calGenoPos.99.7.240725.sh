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
echo "VariantRecalibrator - SNP"

#[A] Hard-filter a large cohort callset on ExcessHet using VariantFiltration 
mkdir /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/VariantRecalibrator
gatk --java-options "-Xms50G -Xmx50G -XX:ParallelGCThreads=32"  VariantFiltration \
    -V /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/merged.vcf.gz \
    --filter-expression "ExcessHet > 54.69" \
    --filter-name ExcessHet \
    -O /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/merged_excesshet.vcf.gz

#[B] Create sites-only VCF with MakeSitesOnlyVcf
gatk MakeSitesOnlyVcf \
        -I /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/merged_excesshet.vcf.gz \
        -O /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/merged_siteonly.vcf.gz

gatk --java-options "-Xms50G -Xmx50G -XX:ParallelGCThreads=32" VariantRecalibrator \
  -tranche 100.0 -tranche 99.75 -tranche 99.7 \
  -tranche 99.5 -tranche 99.0 -tranche 97.0 -tranche 96.0 \
  -tranche 95.0 -tranche 94.0 \
  -tranche 93.5 -tranche 93.0 -tranche 92.0 -tranche 91.0 -tranche 90.0 \
  -R ${ref_Dir}/Homo_sapiens_assembly38.fasta \
  -V /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/merged_siteonly.vcf.gz \
  --resource:hapmap,known=false,training=true,truth=true,prior=15.0 \
  ${ref_Dir}/hapmap_3.3.hg38.vcf.gz  \
  --resource:omni,known=false,training=true,truth=false,prior=12.0 \
  ${ref_Dir}/1000G_omni2.5.hg38.vcf.gz \
  --resource:1000G,known=false,training=true,truth=false,prior=10.0 \
  ${ref_Dir}/1000G_phase1.snps.high_confidence.hg38.vcf.gz \
  --resource:dbsnp,known=true,training=false,truth=false,prior=7 \
  ${ref_Dir}/dbsnp_146.hg38.vcf.gz \
  -an QD -an MQRankSum -an ReadPosRankSum -an FS -an MQ -an SOR -an DP \
  -mode SNP \
  --max-gaussians 4 \
  --trust-all-polymorphic \
  -O /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/VariantRecalibrator/merged_SNP1.recal \
  --tranches-file /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/VariantRecalibrator/output_SNP1.tranches

echo "======================================"
echo "VariantRecalibrator - INDEL"

gatk --java-options "-Xms50G -Xmx50G -XX:ParallelGCThreads=32" VariantRecalibrator \
  -tranche 100.0 -tranche 99.75 -tranche 99.7 \
  -tranche 99.5 -tranche 99.0 -tranche 97.0 -tranche 96.0 \
  -tranche 95.0 -tranche 94.0 -tranche 93.5 -tranche 93.0 \
  -tranche 92.0 -tranche 91.0 -tranche 90.0 \
  -R ${ref_Dir}/Homo_sapiens_assembly38.fasta \
  -V /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/merged_siteonly.vcf.gz \
  --resource:mills,known=false,training=true,truth=true,prior=12.0 \
  ${ref_Dir}/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz \
  --resource:dbsnp,known=true,training=false,truth=false,prior=2.0 \
  ${ref_Dir}/dbsnp_146.hg38.vcf.gz \
  --resource:axiomPoly,known=false,training=true,truth=false,prior=10 \
  ${ref_Dir}/Axiom_Exome_Plus.genotypes.all_populations.poly.hg38.vcf.gz \
  -an FS -an ReadPosRankSum -an MQRankSum -an QD -an SOR -an DP \
  -mode INDEL \
  --max-gaussians 4 \
  --trust-all-polymorphic \
  -O /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/VariantRecalibrator/merged_indel1.recal \
  --tranches-file /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/VariantRecalibrator/output_indel1.tranches

echo "======================================"
echo "ApplyVQSR - SNP"

gatk --java-options "-Xms50G -Xmx50G -XX:ParallelGCThreads=32" ApplyVQSR \
  -V /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/merged_excesshet.vcf.gz \
  --recal-file /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/VariantRecalibrator/merged_SNP1.recal \
  -mode SNP \
  --tranches-file /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/VariantRecalibrator/output_SNP1.tranches \
  --truth-sensitivity-filter-level 99.7 \
  --create-output-variant-index true \
  -O /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/VariantRecalibrator/SNP.recalibrated_99.7.vcf.gz

echo "======================================"
echo "ApplyVQSR - INDEL"

gatk --java-options "-Xms50G -Xmx50G -XX:ParallelGCThreads=32" ApplyVQSR \
  -V /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/VariantRecalibrator/SNP.recalibrated_99.7.vcf.gz \
  -mode INDEL \
  --recal-file /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/VariantRecalibrator/merged_indel1.recal \
  --tranches-file /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/VariantRecalibrator/output_indel1.tranches \
  --truth-sensitivity-filter-level 99.7 \
  --create-output-variant-index true \
  -O /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/VariantRecalibrator/indel.SNP.recalibrated_99.7.vcf.gz

#echo "======================================"
#echo "CalculateGenotypePosteriors"
#mkdir /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/CalculateGenotypePosteriors
#gatk --java-options "-Xms50G -Xmx50G -XX:ParallelGCThreads=32" CalculateGenotypePosteriors \
#   -V /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/VariantRecalibrator/indel.SNP.recalibrated_99.7.vcf.gz \
#   -O /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/CalculateGenotypePosteriors/trio_refined_99.7.vcf.gz
