#!/bin/sh

if [ $# -ne 1 ];then
    echo "#usage: sh $0 <sample name>"
        exit
fi
#Make WES folder
mkdir -p /scratch/hpc46a05/WES/CTC
CTC_folder="/scratch/hpc46a05/WES/CTC"
raw_data="${CTC_folder}/raw_CTC.fastq"
sample=$1
path="${CTC_folder}/result"
temp="${CTC_folder}/temp"

#Assign REFERENCE_folder
REF_PATH="/scratch/hpc46a05/REFERENCE/DNA"
REFERENCE="${REF_PATH}/gatk-best-practices/Homo_sapiens_assembly19.fasta"
SNP="${REF_PATH}/gatk-best-practices/Homo_sapiens_assembly19.dbsnp138.vcf"
INDEL="${REF_PATH}/gatk-best-practices/Homo_sapiens_assembly19.known_indels_20120518.vcf"
INTERVAL="${REF_PATH}/gatk-best-practices/wgs_calling_regions.v1.interval_list"
custom_PON="${REF_PATH}/PON/somatic-b37_Mutect2-exome-panel.vcf"
germline_resource="${REF_PATH}/gnomad/af-only-gnomad.raw.sites.b37.vcf.gz"
gnomAD="${REF_PATH}/gnomad/gnomad.exomes.r2.1.1.sites.vcf.gz"
gnomAD_interval_list="${REF_PATH}/gnomad/gnomad.exomes.r2.1.1.sites.vcf.gz"
mkdir ${path}/${sample}

#01.FASTQC
mkdir ${path}/${tumor}/01_FASTQC
fastqc -t 64 -o ${path}/${tumor}/01_FASTQC ${raw_data}/${tumor}/${tumor}_1.fastq.gz
fastqc -t 64 -o ${path}/${tumor}/01_FASTQC ${raw_data}/${tumor}/${tumor}_2.fastq.gz

#02.Trimmomatic
mkdir ${path}/${tumor}/02_Trimmomatic
java "-Xmx96G" -jar /01.TOOLS/02.Trimmomatic/Trimmomatic-0.39/trimmomatic-0.39.jar PE -threads 64 -phred33  ${raw_data}/${tumor}/${tumor}_1.fastq.gz ${raw_data}/${tumor}/${tumor}_2.fastq.gz ${path}/${tumor}/02_Trimmomatic/${tumor}_R1_P.fastq ${path}/${tumor}/02_Trimmomatic/${tumor}_R1_U.fastq ${path}/${tumor}/02_Trimmomatic/${tumor}_R2_P.fastq ${path}/${tumor}/02_Trimmomatic/${tumor}_R2_U.fastq ILLUMINACLIP:/scratch/x1997a11/ctDNA_adapter.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

#02.FASTQC
fastqc -t 64 -o ${path}/${tumor}/01_FASTQC ${path}/${tumor}/02_Trimmomatic/${tumor}_R1_P.fastq
fastqc -t 64 -o ${path}/${tumor}/01_FASTQC ${path}/${tumor}/02_Trimmomatic/${tumor}_R2_P.fastq


#03-BWA-tumor
mkdir ${path}/${tumor}/03_BWA
bwa mem -t 64 -M -R '@RG\tID:HHVLCDSXX\tPL:ILLUMINA\tPM:NOVASEQ\tSM:tumor' ${REFERENCE} ${path}/${tumor}/02_Trimmomatic/${tumor}_R1_P.fastq ${path}/${tumor}/02_Trimmomatic/${tumor}_R2_P.fastq > ${path}/${tumor}/03_BWA/${tumor}.sam

samtools view -Sb ${path}/${tumor}/03_BWA/${tumor}.sam > ${path}/${tumor}/03_BWA/${tumor}.bam

samtools sort -o ${path}/${tumor}/03_BWA/${tumor}.sorted.bam ${path}/${tumor}/03_BWA/${tumor}.bam

samtools index ${path}/${tumor}/03_BWA/${tumor}.sorted.bam

#04.MarkDuplicate-tumor
mkdir ${path}/${tumor}/04_MarkDuplicate
java "-Xmx96G" -jar /01.TOOLS/04.MARKDUP/picard-tools-1.119/MarkDuplicates.jar I= ${path}/${tumor}/03_BWA/${tumor}.sorted.bam O= ${path}/${tumor}/04_MarkDuplicate/${tumor}.sorted.markedup.bam M= ${path}/${tumor}/04_MarkDuplicate/${tumor}.markedup.metrics.txt

gatk --java-options "-Xmx96G" BuildBamIndex --INPUT ${path}/${tumor}/04_MarkDuplicate/${tumor}.sorted.markedup.bam

#05,BQSR-tumor
mkdir ${path}/${tumor}/05_BQSR
gatk --java-options "-Xmx96G" BaseRecalibrator -I ${path}/${tumor}/04_MarkDuplicate/${tumor}.sorted.markedup.bam -R ${REFERENCE} --known-sites ${SNP} --known-sites ${INDEL} -O ${path}/${tumor}/05_BQSR/${tumor}.recal.table

gatk --java-options "-Xmx96G" ApplyBQSR -R ${REFERENCE} -I ${path}/${tumor}/04_MarkDuplicate/${tumor}.sorted.markedup.bam --bqsr-recal-file ${path}/${tumor}/05_BQSR/${tumor}.recal.table -O ${path}/${tumor}/05_BQSR/${tumor}.sorted.markedup.recal.bam


#--------------------------------------mutect2 common tool--------------------------------
echo -e "\n \n gatk GetPileupSummaries tumor start \n \n"

#09-GetPileupSummaries 
mkdir ${path}/${tumor}/09_${tumor}-pileups 
gatk  --java-options "-Xmx96G" GetPileupSummaries -I ${path}/${tumor}/05_BQSR/${tumor}.sorted.markedup.recal.bam -V ${gnomAD} -L ${gnomAD_interval_list} -O ${path}/${tumor}/09_${tumor}-pileups/${tumor}-pileups.table --tmp-dir ${temp}


