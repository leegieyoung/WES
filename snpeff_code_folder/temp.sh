#!/bin/bash
Input=$1
Result_Dir="/ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/4.VariantFiltration"
Singularity_Dir="/ichrogene/project/temp/gylee/Singularity"
data_Dir="/ichrogene/project/temp/gylee/1.WES/REFERENCE/snpEff/data"
REFERENCE="/ichrogene/project/temp/gylee/1.WES/REFERENCE/"
Seq=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 "X" "Y" "M")

snp_snpeff() {
	if [ $# -ne 1 ];then
        echo "Please enter Sample_Name"
               exit
fi
singularity exec --bind /ichrogene/:/ichrogene/ ${Singularity_Dir}/PRS.sif bcftools view --threads 32 ${Result_Dir}/temp/chr${A}_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf -Oz -o ${Result_Dir}/temp/chr${A}_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz
singularity exec --bind /ichrogene/:/ichrogene/ ${Singularity_Dir}/PRS.sif bcftools index --threads 32 ${Result_Dir}/temp/chr${A}_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz

#==========
singularity exec --bind /ichrogene/:/ichrogene/ ${Singularity_Dir}/PRS.sif bcftools view --threads 32 ${Result_Dir}/temp/chr${A}_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf -Oz -o ${Result_Dir}/temp/chr${A}_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz
singularity exec --bind /ichrogene/:/ichrogene/ ${Singularity_Dir}/PRS.sif bcftools index --threads 32 ${Result_Dir}/temp/chr${A}_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz

}
mkdir ${Result_Dir}/temp/
for A in "${Seq[@]}"
do
echo "========="
echo "${A} Start"
snp_snpeff ${A} > /dev/null 2>&1 &
sleep 30
done
wait

#Part 3
#singularity exec --bind /ichrogene/:/ichrogene/ ${Singularity_Dir}/PRS.sif bash /ichrogene/project/temp/gylee/Code/snpeff_code_folder/3.snpeff_merge.sh ${Input}
