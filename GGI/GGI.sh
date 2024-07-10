awk '{print $1"\t"$2}'  /ichrogene/project/temp/gylee/1.WES/2.gatk_result/alopecia.Case.Control/4.VariantFiltration/Find_maf0.01/QC.GT.merge  > /ichrogene/project/temp/gylee/Code/GGI/region.file
sed -i '1,1d' /ichrogene/project/temp/gylee/Code/GGI/region.file
bcftools view --threads 30 \
 /ichrogene/project/temp/gylee/1.WES/2.gatk_result/alopecia.Case.Control/VariantRecalibrator/indel.SNP.recalibrated_99.7.vcf.gz \
 --regions-file /ichrogene/project/temp/gylee/Code/GGI/region.file \
 -o Find_maf0.01.vcf
