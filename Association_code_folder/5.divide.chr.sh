#!/bin/bash
Dir="/ichrogene/project/temp/gylee/1.WES/2.gatk_result/skin.1004/"
mkdir -p ${Dir}/5.custom.filter/tmp
mkdir -p ${Dir}/5.custom.filter/log
REF_dir="/ichrogene/project/temp/gylee/1.WES/REFERENCE/fasta/"
Seq=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 "X" "Y" "M")
#Seq=("X")
#Seq=(1 2 6 7)
bcftools view --threads 32 ${Dir}/5.custom.filter/header -Oz -o ${Dir}/5.custom.filter/header.gz
for A in "${Seq[@]}"
do
A="chr${A}"
echo "===================================="
echo "Start : ${A}"
echo "===================================="
rm ${Dir}/5.custom.filter/log/5.divide.chr.sh.${A}.log
	(
	rm ${Dir}/5.custom.filter/indels.${A}.vcf.gz
	bcftools view -r ${A} --threads 32 ${Dir}/4.VariantFiltration/indels_filtered.PASS.vcf.gz -Oz -o ${Dir}/5.custom.filter/indels.${A}.vcf.gz

	rm ${Dir}/5.custom.filter/reh_indels.${A}.vcf.gz
	bcftools reheader -h ${Dir}/5.custom.filter/header.gz ${Dir}/5.custom.filter/indels.${A}.vcf.gz > ${Dir}/5.custom.filter/reh_indels.${A}.vcf.gz

	rm ${Dir}/5.custom.filter/reh_indels.${A}.vcf.gz.csi
	bcftools index --threads 32 ${Dir}/5.custom.filter/reh_indels.${A}.vcf.gz

	rm ${Dir}/5.custom.filter/snps.${A}.vcf.gz
        bcftools view -r ${A} --threads 32 ${Dir}/4.VariantFiltration/snps_filtered.PASS.vcf.gz -Oz -o ${Dir}/5.custom.filter/snps.${A}.vcf.gz

	rm ${Dir}/5.custom.filter/reh_snps.${A}.vcf.gz
        bcftools reheader -h ${Dir}/5.custom.filter/header.gz ${Dir}/5.custom.filter/snps.${A}.vcf.gz > ${Dir}/5.custom.filter/reh_snps.${A}.vcf.gz

	rm ${Dir}/5.custom.filter/reh_snps.${A}.vcf.gz.csi
	bcftools index --threads 32 ${Dir}/5.custom.filter/reh_snps.${A}.vcf.gz

	rm ${Dir}/5.custom.filter/${A}.vcf.gz
	bcftools concat --threads 32 -a -D -Oz \
	${Dir}/5.custom.filter/reh_snps.${A}.vcf.gz \
	${Dir}/5.custom.filter/reh_indels.${A}.vcf.gz -o ${Dir}/5.custom.filter/${A}.vcf.gz

	rm ${Dir}/5.custom.filter/${A}.vcf.gz.csi
	bcftools index --threads 32 ${Dir}/5.custom.filter/${A}.vcf.gz

	rm ${Dir}/5.custom.filter/${A}.sort.vcf.gz
	bcftools sort ${Dir}/5.custom.filter/${A}.vcf.gz \
	 --temp-dir ${Dir}/5.custom.filter/tmp/ \
	  -Oz -o ${Dir}/5.custom.filter/${A}.sort.vcf.gz

	rm ${Dir}/5.custom.filter/${A}.sort.vcf.gz.csi
	bcftools index --threads 32 ${Dir}/5.custom.filter/${A}.sort.vcf.gz

	rm ${Dir}/5.custom.filter/${A}.sort.both.vcf.gz
	bcftools norm -m -both -cs --threads 32 ${Dir}/5.custom.filter/${A}.sort.vcf.gz \
	 -f ${REF_dir}/Homo_sapiens_assembly38.fasta \
	 -Oz -o ${Dir}/5.custom.filter/${A}.sort.both.vcf.gz

	rm ${Dir}/5.custom.filter/${A}.sort.both.vcf.gz.csi
	bcftools index --threads 32 ${Dir}/5.custom.filter/${A}.sort.both.vcf.gz

	rm ${Dir}/5.custom.filter/${A}.sort.both.AC.vcf
	bcftools view -c 10 -C 1998 --threads 32 \
	 ${Dir}/5.custom.filter/${A}.sort.both.vcf.gz \
	 -o ${Dir}/5.custom.filter/${A}.sort.both.AC.vcf

	rm ${Dir}/5.custom.filter/result/${A}.sort.both.AC.minac10.txt
	grep -v "^##" ${Dir}/5.custom.filter/${A}.sort.both.AC.vcf > ${Dir}/5.custom.filter/result/${A}.sort.both.AC.minac10.txt
echo "===================================="
echo "End : ${A}"
echo "===================================="
	) & 2> ${Dir}/5.custom.filter/log/5.divide.chr.sh.${A}.log  2>&1

	sleep 2
done
wait

Rscript /ichrogene/project/temp/gylee/Code/snpeff_code_folder/skin.code/7.skin.1004.both.240723.R
