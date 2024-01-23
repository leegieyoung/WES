#!/bin/bash
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

for A in $(cat ${fastq_Dir}/divide_for_haplotypecaller/part5.list)
do
echo "==========================="
echo "HaplotypeCaller : ${A}"
rm -rf ${QC_Dir}/${A}/04.Caller
mkdir ${QC_Dir}/${A}/04.Caller
gatk --java-options "-Xms7G -Xmx7G -XX:ParallelGCThreads=4" HaplotypeCaller \
 --native-pair-hmm-threads 4 \
 -R ${ref_Dir}/Homo_sapiens_assembly38.fasta \
 -I ${QC_Dir}/${A}/03_BQSR/${A}.sorted.markedup.recal.bam \
 -O ${QC_Dir}/${A}/04.Caller/${A}.g.vcf.gz \
 -ERC GVCF 
done
