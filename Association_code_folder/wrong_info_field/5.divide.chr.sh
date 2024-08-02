#!/bin/bash
Dir="/ichrogene/project/temp/gylee/1.WES/2.gatk_result/skin.1004/"
mkdir ${Dir}/5.custom.filter
Seq=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 "X" "Y" "M")

for A in "${Seq[@]}"
do
echo ${A}
	(
nohup grep "^chr${A}\s" ${Dir}/4.VariantFiltration/snps.indels_no.filtered.PASS.snpEff.SnpSift.vcf > ${Dir}/5.custom.filter/raw.${A} 2> /dev/null 2>&1 
	) &
	sleep 2
done
wait

for A in "${Seq[@]}"
do
	(
nohup cat ${Dir}/5.custom.filter/header ${Dir}/5.custom.filter/raw.${A} > ${Dir}/5.custom.filter/${A}.vcf 2> /dev/null 2>&1
	) &
	sleep 2

rm ${Dir}/5.custom.filter/raw.${A}
done

