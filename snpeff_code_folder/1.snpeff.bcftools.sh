#!/bin/bash
Input=$1
Result_Dir="/ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/4.VariantFiltration"
Singularity_Dir="/ichrogene/project/temp/gylee/Singularity"
data_Dir="/ichrogene/project/temp/gylee/1.WES/REFERENCE/snpEff/data"
REFERENCE="/ichrogene/project/temp/gylee/1.WES/REFERENCE/"
Seq=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 "X" "Y" "M")

#SNP
mkdir ${Result_Dir}/temp
bcftools index -f --threads 32 ${Result_Dir}/snps_filtered.PASS.vcf.gz
for A in "${Seq[@]}"
do
    (
    nohup bcftools view --regions chr${A} ${Result_Dir}/snps_filtered.PASS.vcf.gz -Oz -o ${Result_Dir}/temp/chr${A}_snps_filtered.PASS.vcf.gz > /dev/null 2>&1
    ) &
    sleep 3  
done
wait

for A in "${Seq[@]}"
do
	(
	nohup bcftools index --threads 32 -f ${Result_Dir}/temp/chr${A}_snps_filtered.PASS.vcf.gz > /dev/null 2>&1
	) & 
	sleep 3
done
wait

#INDEL
echo "========================="
bcftools index -f --threads 32 ${Result_Dir}/indels_filtered.PASS.vcf.gz
for A in "${Seq[@]}" 
do
	(
	nohup bcftools view --regions chr${A} ${Result_Dir}/indels_filtered.PASS.vcf.gz -Oz -o ${Result_Dir}/temp/chr${A}_indels_filtered.PASS.vcf.gz > /dev/null 2>&1
	)
	sleep 3
done
wait

for A in "${Seq[@]}"
do
	(
	nohup bcftools index --threads 32 -f ${Result_Dir}/temp/chr${A}_indels_filtered.PASS.vcf.gz > /dev/null 2>&1
	) &
	sleep 3
done
wait
