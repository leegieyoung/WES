#!/bin/bash
Dir="/ichrogene/project/temp/gylee/1.WES/2.gatk_result/skin.1004/"
mkdir -p ${Dir}/5.custom.filter/result
Seq=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 "X" "Y" "M")



for A in "${Seq[@]}"
do
#bcftools view --threads 32 ${Dir}/5.custom.filter/${A}.vcf -Oz -o ${Dir}/5.custom.filter/${A}.vcf.gz
#bcftools sort ${Dir}/5.custom.filter/${A}.vcf.gz -Oz -o ${Dir}/5.custom.filter/${A}.sort.vcf.gz
#bcftools index --threads 32 ${Dir}/5.custom.filter/${A}.sort.vcf.gz
bcftools view -c 10 -C 1998 --threads 32 ${Dir}/5.custom.filter/${A}.sort.vcf.gz -Ov -o ${Dir}/5.custom.filter/${A}.sort.minac10.vcf
grep -v '^##' ${Dir}/5.custom.filter/${A}.sort.minac10.vcf > ${Dir}/5.custom.filter/result/${A}.sort.minac10.txt
done

Rscript /ichrogene/project/temp/gylee/Code/snpeff_code_folder/skin.code/7.skin.1004.240718.R 
