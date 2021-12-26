#!/bin/sh

if [ $# -ne 2 ];then
    echo "#usage: sh $0 <sample name>"
        exit
fi
#Make WES folder
mkdir -p /scratch/hpc46a05/WES/CTC
CTC_folder="/scratch/hpc46a05/WES/CTC"
raw_data="${CTC_folder}/raw_CTC.fastq"
sample=$1
tumor=$2

mkdir ${CTC_folder}/result
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
mkdir ${path}/${sample}/01_FASTQC
fastqc -t 64 -o ${path}/${sample}/01_FASTQC ${raw_data}/${sample}/${sample}_1.fastq.gz
fastqc -t 64 -o ${path}/${sample}/01_FASTQC ${raw_data}/${sample}/${sample}_2.fastq.gz

#02.Trimmomatic
mkdir ${path}/${sample}/02_Trimmomatic
java "-Xmx96G" -jar /01.TOOLS/02.Trimmomatic/Trimmomatic-0.39/trimmomatic-0.39.jar PE -threads 64 -phred33  ${raw_data}/${sample}/${sample}_1.fastq.gz ${raw_data}/${sample}/${sample}_2.fastq.gz ${path}/${sample}/02_Trimmomatic/${sample}_R1_P.fastq ${path}/${sample}/02_Trimmomatic/${sample}_R1_U.fastq ${path}/${sample}/02_Trimmomatic/${sample}_R2_P.fastq ${path}/${sample}/02_Trimmomatic/${sample}_R2_U.fastq ILLUMINACLIP:/scratch/x1997a11/ctDNA_adapter.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36

#02.FASTQC
fastqc -t 64 -o ${path}/${sample}/01_FASTQC ${path}/${sample}/02_Trimmomatic/${sample}_R1_P.fastq
fastqc -t 64 -o ${path}/${sample}/01_FASTQC ${path}/${sample}/02_Trimmomatic/${sample}_R2_P.fastq

#03-BWA-sample
mkdir ${path}/${sample}/03_BWA
bwa mem -t 64 -M -R '@RG\tID:HHVLCDSXX\tPL:ILLUMINA\tPM:NOVASEQ\tSM:sample' ${REFERENCE} ${path}/${sample}/02_Trimmomatic/${sample}_R1_P.fastq ${path}/${sample}/02_Trimmomatic/${sample}_R2_P.fastq > ${path}/${sample}/03_BWA/${sample}.sam

samtools view -Sb ${path}/${sample}/03_BWA/${sample}.sam > ${path}/${sample}/03_BWA/${sample}.bam

samtools sort -o ${path}/${sample}/03_BWA/${sample}.sorted.bam ${path}/${sample}/03_BWA/${sample}.bam

samtools index ${path}/${sample}/03_BWA/${sample}.sorted.bam

#04.MarkDuplicate-sample
mkdir ${path}/${sample}/04_MarkDuplicate
java "-Xmx96G" -jar /01.TOOLS/04.MARKDUP/picard-tools-1.119/MarkDuplicates.jar I= ${path}/${sample}/03_BWA/${sample}.sorted.bam O= ${path}/${sample}/04_MarkDuplicate/${sample}.sorted.markedup.bam M= ${path}/${sample}/04_MarkDuplicate/${sample}.markedup.metrics.txt

gatk --java-options "-Xmx96G" BuildBamIndex --INPUT ${path}/${sample}/04_MarkDuplicate/${sample}.sorted.markedup.bam

#05,BQSR-sample
mkdir ${path}/${sample}/05_BQSR
gatk --java-options "-Xmx96G" BaseRecalibrator -I ${path}/${sample}/04_MarkDuplicate/${sample}.sorted.markedup.bam -R ${REFERENCE} --known-sites ${SNP} --known-sites ${INDEL} -O ${path}/${sample}/05_BQSR/${sample}.recal.table

gatk --java-options "-Xmx96G" ApplyBQSR -R ${REFERENCE} -I ${path}/${sample}/04_MarkDuplicate/${sample}.sorted.markedup.bam --bqsr-recal-file ${path}/${sample}/05_BQSR/${sample}.recal.table -O ${path}/${sample}/05_BQSR/${sample}.sorted.markedup.recal.bam

#09-GetPileupSummaries 
mkdir ${path}/${sample}/09_${sample}-pileups 
gatk  --java-options "-Xmx96G" GetPileupSummaries -I ${path}/${sample}/05_BQSR/${sample}.sorted.markedup.recal.bam -V ${gnomAD} -L ${gnomAD_interval_list} -O ${path}/${sample}/09_${sample}-pileups/${sample}-pileups.table --tmp-dir ${temp}


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

#--------------------------------------mutect2 matched normal--------------------------------
echo -e "\n \n gatk Mutect2 NM start \n \n"
#08-Mutect2
mkdir ${path}/${sample}/08_${tumor}-Mutect2-MN
gatk --java-options "-Xmx64G" Mutect2 \
 -R ${REFERENCE} \
 -I ${path}/${tumor}/05_BQSR/${tumor}.sorted.markedup.recal.bam \
 -tumor tumor \
 -I ${path}/${sample}/05_BQSR/${sample}.sorted.markedup.recal.bam \
 -normal sample \
 --germline-resource ${germline_resource} \
 --af-of-alleles-not-in-resource 0.000001 \
 --panel-of-normals ${custom_PON} \
 -L ${INTERVAL} \
 -dont-use-soft-clipped-bases true --force-active true \
 --active-probability-threshold 0.001 --max-reads-per-alignment-start 0 --min-base-quality-score 10 --pair-hmm-implementation FASTEST_AVAILABLE \
 --initial-tumor-lod 1.0 \
 --native-pair-hmm-threads 64 \
 -O ${path}/${sample}/08_${tumor}-Mutect2-MN/${tumor}-Mutect2-MN.vcf.gz

#--------------------------------------mutect2 tumor only mode --------------------------------
#08-Mutect2-tumor-only-mode
mkdir ${path}/${sample}/08_${tumor}-Mutect2-PON-tumor-only
gatk --java-options "-Xmx64G" Mutect2 \
 -R ${REFERENCE} \
 -I ${path}/${tumor}/05_BQSR/${tumor}.sorted.markedup.recal.bam \
 --germline-resource ${germline_resource} \
 --af-of-alleles-not-in-resource 0.0000000008588 \
 --panel-of-normals ${custom_PON} \
 -L ${INTERVAL} \
 --native-pair-hmm-threads 64 \
 -O ${path}/${sample}/08_${tumor}-Mutect2-PON-tumor-only/${tumor}-Mutect2-tumor-only.vcf.gz

#------------------------------------- Require Getpilesup -------------------------------------
#-- mutect2 MN --
#10-CalculateContamination
echo -e "\n \n calculationContamination start \n \n"
mkdir ${path}/${sample}/10_${tumor}-calculatecontamination-MN
gatk --java-options "-Xmx64G" CalculateContamination \
 -I ${path}/${tumor}/09_${tumor}-pileups/${tumor}-pileups.table \
 -matched ${path}/${sample}/09_${sample}-pileups/${sample}-pileups.table \
 --tumor-segmentation ${path}/${sample}/10_${tumor}-calculatecontamination-MN/${tumor}-segment.tsv \
 -O ${path}/${sample}/10_${tumor}-calculatecontamination-MN/${tumor}-contamination.table

echo -e "\n \n filtermutectcalls start \n \n"
#11-FilterMutectCalls-MN
mkdir ${path}/${sample}/11_${tumor}-FilterMutectCalls-MN
gatk --java-options "-Xmx64G" FilterMutectCalls \
 -R ${REFERENCE} \
 -V ${path}/${sample}/08_${tumor}-Mutect2-MN/${tumor}-Mutect2-MN.vcf.gz \
 --contamination-table ${path}/${sample}/10_${tumor}-calculatecontamination-MN/${tumor}-contamination.table \
 --tumor-segmentation ${path}/${sample}/10_${tumor}-calculatecontamination-MN/${tumor}-segment.tsv \
 -O ${path}/${sample}/11_${tumor}-FilterMutectCalls-MN/${tumor}-filtermutectcalls.vcf.gz

#------------------------------------- Require Getpilesup -------------------------------------
#-- mutect2 TM --
#10-CalculateContamination
mkdir ${path}/${sample}/10_${tumor}-calculatecontamination-tumor-only
gatk --java-options "-Xmx64G" CalculateContamination \
 -I ${path}/${sample}/09_${tumor}-pileups/${tumor}-pileups.table \
 --tumor-segmentation ${path}/${sample}/10_${tumor}-calculatecontamination-tumor-only/${tumor}-segment.tsv \
 -O ${path}/${sample}/10_${tumor}-calculatecontamination-tumor-only/${tumor}-contamination.table

echo "CalaulateContamination complete "

#11-FilterMutectCalls
mkdir ${path}/${sample}/11_${tumor}-FilterMutectCalls-tumor-only
gatk --java-options "-Xmx64G" FilterMutectCalls \
 -R ${REFERENCE} \
 -V ${path}/${sample}/08_${tumor}-Mutect2-PON-tumor-only/${tumor}-Mutect2-tumor-only.vcf.gz \
 --contamination-table ${path}/${sample}/10_${tumor}-calculatecontamination-tumor-only/${tumor}-contamination.table \
 --tumor-segmentation ${path}/${sample}/10_${tumor}-calculatecontamination-tumor-only/${tumor}-segment.tsv \
 -O ${path}/${sample}/11_${tumor}-FilterMutectCalls-tumor-only/${tumor}-filtermutectcalls-tumor-only.vcf.gz
echo " Filtermutectcalls complete "

