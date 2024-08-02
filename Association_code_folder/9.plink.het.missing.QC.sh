#!/bin/sh
if [ $# -ne 3 ];then
        echo "Please enter Sample_Name"
               exit
fi

Sample=$1
Thread=$2
MEM=$3
Dir="/ichrogene/project/temp/gylee/1.WES/2.gatk_result/skin.1004/"
raw_dir="${Dir}/5.custom.filter/result/Find_Nomaf"
p2_Dir="/ichrogene/project/temp/gylee/Singularity/plink2"
p19_Dir="/ichrogene/project/temp/gylee/Singularity/plink19"
Inversion="/ichrogene/project/temp/gylee/0.GWAS/REFERENCE/inversion.txt"
plink_dir="${Dir}/6.plinkQC"
Sig_dir="/ichrogene/project/temp/gylee/Singularity"
#SAIGE_dir="${Dir}/2.SAIGE_result/${Sample}/result"

mkdir -p ${plink_dir}
mkdir -p ${plink_dir}

export RESULT_DIR="${plink_dir}/"
echo ${ANA_DIR}
export SAMPLE="${Sample}"
export plink_DIR="${plink_dir}/"
sed 's/\(^\|[[:space:]]\)-9\([[:space:]]\|$\)/\1NA\2/g' skin.covariate.txt > skin.covariate.NA.txt
sed -i 's/\(^\|[[:space:]]\)-9\([[:space:]]\|$\)/\1NA\2/g' skin.covariate.NA.txt
sed -i 's/\(^\|[[:space:]]\)-9\([[:space:]]\|$\)/\1NA\2/g' skin.covariate.NA.txt
sed -i 's/\(^\|[[:space:]]\)-9\([[:space:]]\|$\)/\1NA\2/g' skin.covariate.NA.txt
sed -i 's/\(^\|[[:space:]]\)-9\([[:space:]]\|$\)/\1NA\2/g' skin.covariate.NA.txt
sed -i 's/\(^\|[[:space:]]\)-9\([[:space:]]\|$\)/\1NA\2/g' skin.covariate.NA.txt
sed -i 's/\(^\|[[:space:]]\)-9\([[:space:]]\|$\)/\1NA\2/g' skin.covariate.NA.txt
sed -i 's/\(^\|[[:space:]]\)-9\([[:space:]]\|$\)/\1NA\2/g' skin.covariate.NA.txt
sed -i 's/\(^\|[[:space:]]\)-9\([[:space:]]\|$\)/\1NA\2/g' skin.covariate.NA.txt
sed -i 's/\(^\|[[:space:]]\)-9\([[:space:]]\|$\)/\1NA\2/g' skin.covariate.NA.txt
sed -i 's/\(^\|[[:space:]]\)-9\([[:space:]]\|$\)/\1NA\2/g' skin.covariate.NA.txt
sed -i 's/\(^\|[[:space:]]\)-9\([[:space:]]\|$\)/\1NA\2/g' skin.covariate.NA.txt

${p2_Dir}/plink2 --vcf ${raw_dir}/QC.marker.vcf \
 --update-sex ${Dir}/1.clinical/skin.covariate.NA.txt \
 --remove ${Dir}/1.clinical/remove.list \
 --rm-dup force-first \
 --set-missing-var-ids @:#:\$r:\$a \
 --new-id-max-allele-len 232 \
 --make-pgen --split-par hg38 \
 --not-chr PAR1 PAR2 \
 --out ${plink_dir}/${Sample}

${p2_Dir}/plink2 --pfile ${plink_dir}/${Sample} \
 --maf 0.0001 \
 --make-pgen \
 --threads ${Thread} \
 --memory ${MEM} \
 --out ${plink_dir}/${Sample}_maf

${p2_Dir}/plink2 --pfile ${plink_dir}/${Sample}_maf \
 --hwe 1e-6 \
 --make-pgen \
 --threads ${Thread} \
 --memory ${MEM} \
 --out ${plink_dir}/${Sample}_maf_hwe

echo ""
echo "===================Check heterozygosity========================"
echo ""

${p2_Dir}/plink2 --pfile ${plink_dir}/${Sample}_maf_hwe \
 --exclude ${Inversion} \
 --indep-pairwise 200 100 0.1 \
 --memory ${MEM} \
 --out ${plink_dir}/${Sample}_indepSNP

${p2_Dir}/plink2 --pfile ${plink_dir}/${Sample}_maf_hwe \
 --extract ${plink_dir}/${Sample}_indepSNP.prune.in \
 --missing \
 --memory ${MEM} \
 --out ${plink_dir}/Before_miss

${p2_Dir}/plink2 --pfile ${plink_dir}/${Sample}_maf_hwe \
 --extract ${plink_dir}/${Sample}_indepSNP.prune.in --het \
 --memory ${MEM} \
 --out ${plink_dir}/Before_het

awk '{print $4"\tPheno"}' ${plink_dir}/Before_miss.smiss > ${plink_dir}/B_F_MISS
paste -d '\t' ${plink_dir}/Before_het.het ${plink_dir}/B_F_MISS > ${plink_dir}/R_BeforeQC_check.txt

singularity exec --bind /ichrogene/:/ichrogene/ ${Sig_dir}/PRS.sif Rscript /ichrogene/project/temp/gylee/0.GWAS/Code/R/het-missing.R

