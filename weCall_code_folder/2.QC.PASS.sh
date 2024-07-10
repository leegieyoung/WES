#!/bin/bash
bam_Dir="/ichrogene/project/temp/gylee/1.WES/1.raw/cnu/"
ref_Dir="/ichrogene/project/temp/gylee/1.WES/REFERENCE/fasta/"
output_Dir="/ichrogene/project/temp/gylee/1.WES/2.weCall_result/"
Sing_Dir="/ichrogene/project/temp/gylee/Singularity"
scratch="/ichrogene/"
snpEff_Dir="/ichrogene/project/temp/gylee/1.WES/REFERENCE/snpEff/data/"
output_snpEff_Dir="/ichrogene/project/temp/gylee/1.WES/3.snpEff_result"
dbsnp_Dir="/ichrogene/project/temp/gylee/1.WES/REFERENCE/dbsnp"
mkdir -p ${output_snpEff_Dir}

#for A in $(cat /ichrogene/project/temp/gylee/Code/weCall_code_folder/TN.list)
#do
#singularity exec --bind ${scratch}:${scratch} ${Sing_Dir}/weCall.sif weCall --inputs ${bam_Dir}/${A}.bam --output ${output_Dir}/${A}.vcf --refFile ${ref_Dir}/GCF_000001405.40_GRCh38.p14_genomic.fa --numberOfJobs=30
#done

for A in $(cat /ichrogene/project/temp/gylee/Code/weCall_code_folder/TN.list)
do
bcftools view -i 'FILTER="PASS"'  ${output_Dir}/${A}.vcf > ${output_Dir}/${A}.PASS.vcf
done



