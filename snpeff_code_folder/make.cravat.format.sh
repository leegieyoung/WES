#!/bin/bash
Chr=$1 

rm head
rm snp
rm indel
rm ${Chr}.snps.indels_filtered.PASS.cravat.vcf

grep '^#' snps_filtered.PASS.cravat.vcf > head
grep "^${Chr}" snps_filtered.PASS.cravat.vcf > snp
grep "^${Chr}" indels_filtered.PASS.cravat.vcf > indel
cat head snp indel > ${Chr}.snps.indels_filtered.PASS.cravat.vcf

rm head
rm snp
rm indel

