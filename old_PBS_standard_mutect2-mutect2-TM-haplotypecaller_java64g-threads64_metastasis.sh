#!/bin/sh

if [ $# -ne 2 ];then
    echo "#usage: sh $0 <sample name>"
        exit
fi

sample=$1
tumor=$2
path="/WES/CTC"
temp="/temp"
REFERENCE="human_g1k_v37.fasta"
SNP="Homo_sapiens_assembly19.dbsnp138.vcf"
INDEL="Homo_sapiens_assembly19.known_indels_20120518.vcf"
INTERVAL="S04380110_Covered.bed"
custom_PON="somatic-b37_Mutect2-exome-panel.vcf"
germline_resource="af-only-gnomad.raw.sites.b37.vcf.gz"
gnomAD="gnomad.exomes.r2.1.1.sites_biallelic.vcf.gz"
gnomAD_interval_list="exome_calling_regions.v1.interval_list"


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
echo -e "\n \n gatk GetPileupSummaries tumor start \n \n"

#09-GetPileupSummaries 
mkdir ${path}/${sample}/09_${tumor}-pileups 
gatk  --java-options "-Xmx64G" GetPileupSummaries -I ${path}/${tumor}/05_BQSR/${tumor}.sorted.markedup.recal.bam -V ${gnomAD} -L ${gnomAD_interval_list} -O ${path}/${sample}/09_${tumor}-pileups/${tumor}-pileups.table --tmp-dir ${temp}

echo -e "\n \n gatk GetPileupSummaries B\n \n"
mkdir ${path}/${sample}/temp-09_${sample}-pileups
gatk GetPileupSummaries -I ${path}/${sample}/05_BQSR/${sample}.sorted.markedup.recal.bam -V ${gnomAD} -L ${gnomAD} -O ${path}/${sample}/temp-09_${sample}-pileups/${sample}-pileups.table --tmp-dir ${temp}

#----------------------------------------force_calling_mode-----------------------------------
#08-Mutect2-force_calling_mode-mode
echo -e "\n\n CTC-B mutect2-force-calling-mode start\n\n"

mkdir ${path}/${sample}/08_${tumor}-Mutect2-PON-force_calling_mode
gatk --java-options "-Xmx64G" Mutect2 -R ${REFERENCE} -I ${path}/${tumor}/05_BQSR/${tumor}.sorted.markedup.recal.bam --germline-resource ${germline_resource} --af-of-alleles-not-in-resource 0.00000005 --panel-of-normals ${custom_PON} -L ${INTERVAL} --native-pair-hmm-threads 64 -O ${path}/${sample}/08_${tumor}-Mutect2-PON-force_calling_mode/${tumor}-customPON-somatic-force_calling_mode.vcf.gz --dont-use-soft-clipped-bases true --force-active true --active-probability-threshold 0.001 --max-reads-per-alignment-start 0 --min-base-quality-score 10  --pair-hmm-implementation FASTEST_AVAILABLE -bamout ${path}/${sample}/08_${tumor}-Mutect2-PON-force_calling_mode/${tumor}-customPON-somatic-force_calling_mode.bam

echo -e "\n\n CTC-B mutect2-force-calling-mode end\n\n"

#10-CalculateContamination
mkdir ${path}/${sample}/10_${tumor}-calculatecontamination-force_calling_mode
gatk --java-options "-Xmx64G" CalculateContamination -I ${path}/${sample}/09_${tumor}-pileups/${tumor}-pileups.table --tumor-segmentation ${path}/${sample}/10_${tumor}-calculatecontamination-force_calling_mode/${tumor}-segment.tsv -O ${path}/${sample}/10_${tumor}-calculatecontamination-force_calling_mode/${tumor}-contamination.table
echo -e "\n\nCalaulateContamination complete\n\n "

#11-FilterMutectCalls
mkdir ${path}/${sample}/11_${tumor}-FilterMutectCalls-force_calling_mode
gatk --java-options "-Xmx64G" FilterMutectCalls -R ${REFERENCE} -V ${path}/${sample}/08_${tumor}-Mutect2-PON-force_calling_mode/${tumor}-customPON-somatic-force_calling_mode.vcf.gz --contamination-table ${path}/${sample}/10_${tumor}-calculatecontamination-force_calling_mode/${tumor}-contamination.table --tumor-segmentation ${path}/${sample}/10_${tumor}-calculatecontamination-force_calling_mode/${tumor}-segment.tsv -O ${path}/${sample}/11_${tumor}-FilterMutectCalls-force_calling_mode/${tumor}-filtermutectcalls-force_calling_mode.vcf.gz
echo -e "\n\n Filtermutectcalls complete \n\n"

#--------------------------------------mutect2 matched normal--------------------------------
echo -e "\n \n gatk Mutect2 NM start \n \n"
#08-Mutect2
mkdir ${path}/${sample}/08_${tumor}Mutect2-force-calling-mode-MN
gatk --java-options "-Xmx64G" Mutect2 -R ${REFERENCE} -I ${path}/${tumor}/05_BQSR/${tumor}.sorted.markedup.recal.bam -tumor tumor  -I ${path}/${sample}/05_BQSR/${sample}.sorted.markedup.recal.bam -normal blood  --germline-resource ${germline_resource} --af-of-alleles-not-in-resource 0.000001 --panel-of-normals ${custom_PON} -L ${INTERVAL} -dont-use-soft-clipped-bases true --force-active true --active-probability-threshold 0.001 --max-reads-per-alignment-start 0 --min-base-quality-score 10 --pair-hmm-implementation FASTEST_AVAILABLE --bam-writer-type ALL_POSSIBLE_HAPLOTYPES -bamout ${path}/${sample}/08_${tumor}Mutect2-force-calling-mode-MN/${tumor}-customPON-somatic-Mutect2-force-calling-mode-MN.bam --initial-tumor-lod 1.0 --native-pair-hmm-threads 64 -O ${path}/${sample}/08_${tumor}Mutect2-force-calling-mode-MN/${tumor}-customPON-somatic-Mutect2-force-calling-mode-MN.vcf.gz

#10-CalculateContamination
echo -e "\n \n calculationContamination start \n \n"
mkdir ${path}/${sample}/10_${tumor}-calculatecontamination-force-calling-mode-MN
gatk --java-options "-Xmx64G" CalculateContamination -I ${path}/${sample}/09_${tumor}-pileups/${tumor}-pileups.table -matched ${path}/${sample}/09_${sample}-pileups/${sample}-pileups.table --tumor-segmentation ${path}/${sample}/10_${tumor}-calculatecontamination-force-calling-mode-MN/${tumor}-segment.tsv -O ${path}/${sample}/10_${tumor}-calculatecontamination-force-calling-mode-MN/${tumor}-contamination.table

echo -e "\n \n filtermutectcalls start \n \n"
#11-FilterMutectCalls-force-calling-mode-MN
mkdir ${path}/${sample}/11_${tumor}-FilterMutectCalls-force-calling-mode-MN
gatk --java-options "-Xmx64G" FilterMutectCalls -R ${REFERENCE} -V ${path}/${sample}/08_${tumor}Mutect2-force-calling-mode-MN/${tumor}-customPON-somatic-Mutect2-force-calling-mode-MN.vcf.gz --contamination-table ${path}/${sample}/10_${tumor}-calculatecontamination-force-calling-mode-MN/${tumor}-contamination.table --tumor-segmentation ${path}/${sample}/10_${tumor}-calculatecontamination-force-calling-mode-MN/${tumor}-segment.tsv -O ${path}/${sample}/11_${tumor}-FilterMutectCalls-force-calling-mode-MN/${tumor}-filtermutectcalls.vcf.gz

#--------------------------------------mutect2 tumor only mode --------------------------------
#08-Mutect2-tumor-only-mode
mkdir ${sample}/08_${tumor}-Mutect2-PON-tumor-only
gatk Mutect2 -R ${REFERENCE} -I ${tumor}/05_BQSR/${tumor}.sorted.markedup.recal.bam --germline-resource ${germline_resource} --af-of-alleles-not-in-resource 0.0000000008588 --panel-of-normals ${custom_PON} -L ${INTERVAL} --native-pair-hmm-threads 4 -O ${sample}/08_${tumor}-Mutect2-PON-tumor-only/${tumor}-customPON-somatic-tumor-only.vcf.gz

echo " mutect2-tumor-only-mode complete "

#09-GetPileupSummaries 

#10-CalculateContamination
mkdir ${sample}/10_${tumor}-calculatecontamination-tumor-only
gatk CalculateContamination -I ${sample}/09_${tumor}-pileups/${tumor}-pileups.table --tumor-segmentation ${sample}/10_${tumor}-calculatecontamination-tumor-only/${tumor}-segment.tsv -O ${sample}/10_${tumor}-calculatecontamination-tumor-only/${tumor}-contamination.table
echo "CalaulateContamination complete "

#11-FilterMutectCalls
mkdir ${sample}/11_${tumor}-FilterMutectCalls-tumor-only
gatk FilterMutectCalls -R ${REFERENCE} -V ${sample}/08_${tumor}-Mutect2-PON-tumor-only/${tumor}-customPON-somatic-tumor-only.vcf.gz --contamination-table ${sample}/10_${tumor}-calculatecontamination-tumor-only/${tumor}-contamination.table --tumor-segmentation ${sample}/10_${tumor}-calculatecontamination-tumor-only/${tumor}-segment.tsv -O ${sample}/11_${tumor}-FilterMutectCalls-tumor-only/${tumor}-filtermutectcalls-tumor-only.vcf.gz
echo " Filtermutectcalls complete "

