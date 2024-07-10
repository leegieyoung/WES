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

