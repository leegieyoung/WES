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
Other=("X" "Y" "M")

for A in $(cat /ichrogene/project/temp/gylee/1.WES/skin.1004.list)
do
echo "============================"
echo "Start : ${A}"
#bcftools head ${QC_Dir}/${A}/04.Caller/${A}.g.vcf.gz > ${QC_Dir}/${A}/04.Caller/${A}.head
#sed -i "s/alopecia/${A}/g" ${QC_Dir}/${A}/04.Caller/${A}.head
#
#bcftools view --threads 31 ${QC_Dir}/${A}/04.Caller/${A}.head -Oz -o ${QC_Dir}/${A}/04.Caller/${A}.head.gz
#
#bcftools reheader --threads 31 -h ${QC_Dir}/${A}/04.Caller/${A}.head.gz \
# ${QC_Dir}/${A}/04.Caller/${A}.g.vcf.gz > ${QC_Dir}/${A}/04.Caller/reh.${A}.g.vcf.gz
#
#bcftools index -f -t --threads 31 ${QC_Dir}/${A}/04.Caller/reh.${A}.g.vcf.gz
#rm -rf ${QC_Dir}/${A}/04.Caller/${A}.head*

bcftools index -f -t --threads 31 ${QC_Dir}/${A}/04.Caller/${A}.g.vcf.gz

done

