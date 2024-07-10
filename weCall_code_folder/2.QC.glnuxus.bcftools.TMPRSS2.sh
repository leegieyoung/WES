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

#for A in $(cat /ichrogene/project/temp/gylee/Code/weCall_code_folderTN.list)
#do
#singularity exec --bind ${scratch}:${scratch} ${Sing_Dir}/weCall.sif bcftools view -i 'FILTER="PASS"' ${output_Dir}/${A}.vcf > ${output_Dir}/${A}.PASS.vcf
#done

#echo "===================="
#echo "glnexus"
#rm -r /ichrogene/project/temp/gylee/Code/weCall_code_folder/GLnexus.DB
#singularity exec --bind ${scratch}:${scratch} ${Sing_Dir}/glnexus.sif glnexus_cli --config weCall --bed ${output_Dir}/TMPRSS2.bed ${output_Dir}/TN*.PASS.vcf > ${output_Dir}/alopecia.PASS.TMPRSS2.bcf

#echo "===================="
#echo "Convert bcf to vcf.gz"

#singularity exec --bind ${scratch}:${scratch} ${Sing_Dir}/weCall.sif bcftools view ${output_Dir}/alopecia.PASS.TMPRSS2.bcf | bgzip -c > ${output_Dir}/alopecia.PASS.TMPRSS2.vcf.gz
#echo "===================="
#echo "snpEff & SnpSift"

java -Xmx32g -jar ${Sing_Dir}/snpEff/snpEff.jar eff -dataDir ${snpEff_Dir} -v GRCh38.86 ${output_Dir}/alopecia.PASS.TMPRSS2.vcf.gz > ${output_snpEff_Dir}/raw1.vcf
java -Xmx32g -jar ${Sing_Dir}/snpEff/SnpSift.jar annotate ${dbsnp_Dir}/dbsnp151.GRCh38.p7.vcf.gz ${output_snpEff_Dir}/raw1.vcf >  ${output_snpEff_Dir}/alopecia.PASS.TMPRSS2.snpEff.rsID.vcf



