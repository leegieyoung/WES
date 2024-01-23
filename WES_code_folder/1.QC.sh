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
mkdir -p ${output_snpEff_Dir}
for A in $(cat ${fastq_Dir}/fastq.list)
do
#A="TN04061423"
##fastqc
fastqc -t 30 -o ${fastq_Dir}/${A} ${fastq_Dir}/${A}/${A}_1.fastq.gz > /dev/null 2>&1 &
fastqc -t 30 -o ${fastq_Dir}/${A} ${fastq_Dir}/${A}/${A}_2.fastq.gz /dev/null 2>&1 &

#BWA-A
echo "==========================="
echo "bwa mem : ${A}"
mkdir -p ${QC_Dir}/${A}/01_BWA
bwa mem -t 20 -M -R '@RG\tID:gylee\tPL:ILLUMINA\tPM:Hiseq\tLB:ureselectV6plus\tSM:alopecia' ${ref_Dir}/Homo_sapiens_assembly38.fasta ${fastq_Dir}/${A}/${A}_1.fastq.gz ${fastq_Dir}/${A}/${A}_2.fastq.gz > ${QC_Dir}/${A}/01_BWA/${A}.sam

echo "==========================="
echo "samtools view : ${A}"
samtools view --threads 20 -Sb ${QC_Dir}/${A}/01_BWA/${A}.sam > ${QC_Dir}/${A}/01_BWA/${A}.bam

echo "==========================="
echo "samtools sort : ${A}"
samtools sort --threads 20 -o ${QC_Dir}/${A}/01_BWA/${A}.sorted.bam ${QC_Dir}/${A}/01_BWA/${A}.bam

echo "==========================="
echo "samtools index : ${A}"
samtools index -@ 30 ${QC_Dir}/${A}/01_BWA/${A}.sorted.bam

#04.MarkDuplicate
mkdir ${QC_Dir}/${A}/02_MarkDuplicate

echo "==========================="
echo "MarkDuplicates : ${A}"
java -Xms24G -Xmx24G -XX:ParallelGCThreads=20 -jar /01.TOOLS/04.MARKDUP/picard-tools-1.119/MarkDuplicates.jar \
 I= ${QC_Dir}/${A}/01_BWA/${A}.sorted.bam \
 O= ${QC_Dir}/${A}/02_MarkDuplicate/${A}.sorted.markedup.bam \
 M= ${QC_Dir}/${A}/02_MarkDuplicate/${A}.markedup.metrics.txt
#
echo "==========================="
echo "BuildBamIndex : ${A}"
gatk --java-options "-Xms24G -Xmx24G -XX:ParallelGCThreads=15" BuildBamIndex \
 --INPUT ${QC_Dir}/${A}/02_MarkDuplicate/${A}.sorted.markedup.bam \
 -O ${QC_Dir}/${A}/02_MarkDuplicate/${A}.sorted.markedup.bai

#05,BQSR
mkdir ${QC_Dir}/${A}/03_BQSR
echo "==========================="
echo "BaseRecalibrator : ${A}"
gatk --java-options "-Xms24G -Xmx24G -XX:ParallelGCThreads=15" BaseRecalibrator \
 -I ${QC_Dir}/${A}/02_MarkDuplicate/${A}.sorted.markedup.bam \
 -R ${ref_Dir}/Homo_sapiens_assembly38.fasta \
 --known-sites ${ref_Dir}/dbsnp_146.hg38.vcf.gz \
 --known-sites ${ref_Dir}/Mills_and_1000G_gold_standard.indels.hg38.vcf.gz \
 -O ${QC_Dir}/${A}/03_BQSR/${A}.recal.table

echo "==========================="
echo "ApplyBQSR : ${A}"
gatk --java-options "-Xms24G -Xmx24G -XX:ParallelGCThreads=15" ApplyBQSR \
 -R ${ref_Dir}/Homo_sapiens_assembly38.fasta \
 -I ${QC_Dir}/${A}/02_MarkDuplicate/${A}.sorted.markedup.bam \
 --bqsr-recal-file ${QC_Dir}/${A}/03_BQSR/${A}.recal.table \
 -O ${QC_Dir}/${A}/03_BQSR/${A}.sorted.markedup.recal.bam
done
