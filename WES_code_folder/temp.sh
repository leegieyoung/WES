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

Seq=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 "X" "Y" "M")
Odd=(1 3 5 7 9 11 13 15 17 19 21 "X")
Even=(2 4 6 8 10 12 14 16 18 20 22 "Y" "M")
Other=("X" "Y" "M")
mkdir /ichrogene/project/temp/gylee/1.WES/temp
A="M"

rm -rf /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/new3.chr${A}.vcf.gz
rm -rf /ichrogene/project/temp/gylee/1.WES/dbLOG/GenotypeGVCFs.new3.chr${A}.log
echo "======================================"
echo ${A}
gatk --java-options "-Xms2G -Xmx2G -XX:ParallelGCThreads=1" GenotypeGVCFs \
 -R /ichrogene/project/temp/gylee/1.WES/REFERENCE/fasta/Homo_sapiens_assembly38.fasta \
 -V gendb:///ichrogene/project/temp/gylee/1.WES/${Input}_chr${A} \
 -O /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/new3.chr${A}.vcf.gz > /ichrogene/project/temp/gylee/1.WES/dbLOG/GenotypeGVCFs.new3.chr${A}.log
