#!/bin/bash
Input=$1
Result_Dir="/ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/4.VariantFiltration"
Singularity_Dir="/ichrogene/project/temp/gylee/Singularity"
data_Dir="/ichrogene/project/temp/gylee/1.WES/REFERENCE/snpEff/data"
REFERENCE="/ichrogene/project/temp/gylee/1.WES/REFERENCE/"
Seq=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 "X" "Y" "M")

echo "=================================="
echo "Input : ${Input}"
echo "Path : ${Result_Dir}"

#cp ${Result_Dir}/snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz ${Result_Dir}/snps.gz
gzip -d ${Result_Dir}/snps.gz
grep '^#C' ${Result_Dir}/snps > ${Result_Dir}/header
#grep -e 'dbNSFP' -e 'CADD' -e 'CLNDISDB' ${Result_Dir}/snps | grep -v '^#' > ${Result_Dir}/snps.temp

#cp ${Result_Dir}/indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz ${Result_Dir}/indels.gz
gzip -d ${Result_Dir}/indels.gz 
#grep -e 'dbNSFP' -e 'CADD' -e 'CLNDISDB' ${Result_Dir}/indels | grep -v '^#' > ${Result_Dir}/indels.temp

cat ${Result_Dir}/header ${Result_Dir}/snps ${Result_Dir}/indels >  ${Result_Dir}/snps.indels_no.filtered.PASS.snpEff.SnpSift.vcf

rm ${Result_Dir}/header
rm ${Result_Dir}/snps
rm ${Result_Dir}/indels
rm ${Result_Dir}/*temp
