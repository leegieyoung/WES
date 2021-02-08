#!/bin/sh

if [ $# -ne 2 ];then
    echo "#usage: sh $0 <sample name>"
        exit
fi

sample=$1
tumor=$2
path="/scratch/x1997a11/WES/CTC"
temp="/home01/x1997a11/temp"
REFERENCE="/scratch/x1997a11/WES/REFERENCE/human_g1k_v37.fasta/human_g1k_v37/human_g1k_v37.fasta"
SNP="/scratch/x1997a11/WES/REFERENCE/human_g1k_v37.fasta/SNP/Homo_sapiens_assembly19.dbsnp138.vcf"
INDEL="/scratch/x1997a11/WES/REFERENCE/human_g1k_v37.fasta/INDEL/Homo_sapiens_assembly19.known_indels_20120518.vcf"
INTERVAL="/scratch/x1997a11/WES/CTC/S04380110_Covered.bed"
custom_PON="/scratch/x1997a11/WES/REFERENCE/human_g1k_v37.fasta/mutect2_pon/somatic-b37_Mutect2-exome-panel.vcf"
germline_resource="/scratch/x1997a11/WES/REFERENCE/human_g1k_v37.fasta/mutect2_germline-resource/af-only-gnomad.raw.sites.b37.vcf.gz"
#gnomAD="/scratch/x1997a11/WES/REFERENCE/human_g1k_v37.fasta/mutect2_germline-resource/af-only-gnomad.raw.sites.b37_biallelic.vcf"
#gnomAD="/scratch/x1997a11/WES/REFERENCE/human_g1k_v37.fasta/mutect2_germline-resource/somatic-b37_small_exac_common_3.vcf"
gnomAD="/scratch/x1997a11/WES/REFERENCE/human_g1k_v37.fasta/mutect2_gnomAD_chr_sites/gnomad.exomes.r2.1.1.sites_biallelic.vcf.gz"
gnomAD_interval_list="/scratch/x1997a11/WES/REFERENCE/human_g1k_v37.fasta/mutect2_gnomAD_chr_sites/exome_calling_regions.v1.interval_list"

echo -e "\n\n start sh : $0 \n Blood : $1 \n\n Kid : $2 \n\n"


#01.FASTQC
mkdir ${path}/${tumor}/01_FASTQC
fastqc -t 64 -o ${path}/${tumor}/01_FASTQC ${path}/${tumor}/${tumor}_1.fastq.gz
fastqc -t 64 -o ${path}/${tumor}/01_FASTQC ${path}/${tumor}/${tumor}_2.fastq.gz

#02.Trimmomatic
mkdir ${path}/${tumor}/02_Trimmomatic
trimmomatic PE -threads 64 -phred33  ${path}/${tumor}/${tumor}_1.fastq.gz ${path}/${tumor}/${tumor}_2.fastq.gz ${path}/${tumor}/02_Trimmomatic/${tumor}_R1_P.fastq ${path}/${tumor}/02_Trimmomatic/${tumor}_R1_U.fastq ${path}/${tumor}/02_Trimmomatic/${tumor}_R2_P.fastq ${path}/${tumor}/02_Trimmomatic/${tumor}_R2_U.fastq ILLUMINACLIP:/scratch/x1997a11/ctDNA_adapter.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:70

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
picard MarkDuplicates I= ${path}/${tumor}/03_BWA/${tumor}.sorted.bam O= ${path}/${tumor}/04_MarkDuplicate/${tumor}.sorted.markedup.bam M= ${path}/${tumor}/04_MarkDuplicate/${tumor}.markedup.metrics.txt

gatk --java-options "-Xmx64G" BuildBamIndex --INPUT ${path}/${tumor}/04_MarkDuplicate/${tumor}.sorted.markedup.bam

#05,BQSR-tumor
mkdir ${path}/${tumor}/05_BQSR
gatk --java-options "-Xmx64G" BaseRecalibrator -I ${path}/${tumor}/04_MarkDuplicate/${tumor}.sorted.markedup.bam -R ${REFERENCE} --known-sites ${SNP} --known-sites ${INDEL} -O ${path}/${tumor}/05_BQSR/${tumor}.recal.table

gatk --java-options "-Xmx64G" ApplyBQSR -R ${REFERENCE} -I ${path}/${tumor}/04_MarkDuplicate/${tumor}.sorted.markedup.bam --bqsr-recal-file ${path}/${tumor}/05_BQSR/${tumor}.recal.table -O ${path}/${tumor}/05_BQSR/${tumor}.sorted.markedup.recal.bam


#--------------------------------------mutect2 common tool--------------------------------
echo -e "\n \n gatk GetPileupSummaries Kid start \n \n"

#09-GetPileupSummaries 
#-V에 긴서열을 넣었음.
mkdir ${path}/${sample}/09_${tumor}-pileups 
gatk  --java-options "-Xmx64G" GetPileupSummaries -I ${path}/${tumor}/05_BQSR/${tumor}.sorted.markedup.recal.bam -V ${gnomAD} -L ${gnomAD_interval_list} -O ${path}/${sample}/09_${tumor}-pileups/${tumor}-pileups.table --tmp-dir ${temp}


#----------------------------------------force_calling_mode-----------------------------------
#PBS
qsub /scratch/x1997a11/PBS_Query/force_calling_mode/${tumor}-mutect2-fc.sh
#--------------------------------------mutect2 matched normal--------------------------------
#PBS
echo -e "\n \n gatk Mutect2 NM start \n \n"
qsub /scratch/x1997a11/PBS_Query/Matched_normal/${sample}_${tumor}-mutect2-MN.sh
#--------------------------------------mutect2 tumor only mode Kid--------------------------------
#PBS
echo -e "\n \n gatk Mutect2 tm Kid start \n \n"
qsub /scratch/x1997a11/PBS_Query/tumor_only_mode/${tumor}-mutect2-tm.sh

