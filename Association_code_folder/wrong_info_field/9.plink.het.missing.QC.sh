#!/bin/sh
if [ $# -ne 4 ];then
        echo "Please enter Sample_Name"
               exit
fi

Sample=$1
Thread=$2
MEM=$3
Trait=$4
Dir="/ichrogene/project/temp/gylee/1.WES/2.gatk_result/skin.1004/"
raw_dir="${Dir}/5.custom.filter/result/Find_Nomaf"
p2_Dir="/ichrogene/project/temp/gylee/Singularity/plink2"
Inversion="/ichrogene/project/temp/gylee/0.GWAS/REFERENCE/inversion.txt"
Output_dir="${Dir}/5.custom.filter/result/2.plink_result"
Sig_dir="/ichrogene/project/temp/gylee/Singularity"
#SAIGE_dir="${Dir}/2.SAIGE_result/${Sample}/result"

mkdir -p ${Output_dir}
mkdir -p ${Output_dir}

export RESULT_DIR="${Output_dir}/"
echo ${ANA_DIR}
export SAMPLE="${Sample}"
export plink_DIR="${plink_dir}/"

${p2_Dir}/plink2 --vcf ${raw_dir}/QC.marker.vcf \
 --update-sex ${Dir}/1.clinical/skin.covariate.txt \
 --remove ${Dir}/1.clinical/remove.list \
 --rm-dup force-first \
 --set-missing-var-ids @:#:\$r:\$a \
 --new-id-max-allele-len 168 \
 --make-pgen --split-par hg38 --out ${Output_dir}/${Sample}

${p2_Dir}/plink2 --pfile ${Output_dir}/${Sample} \
 --maf 0.01 \
 --make-pgen \
 --threads ${Thread} \
 --memory ${MEM} \
 --out ${Output_dir}/${Sample}_maf

${p2_Dir}/plink2 --pfile ${Output_dir}/${Sample}_maf \
 --hwe 1e-6 \
 --make-pgen \
 --threads ${Thread} \
 --memory ${MEM} \
 --out ${Output_dir}/${Sample}_maf_hwe

echo ""
echo "===================Check heterozygosity========================"
echo ""

${p2_Dir}/plink2 --pfile ${Output_dir}/${Sample}_maf_hwe \
 --exclude ${Inversion} \
 --indep-pairwise 50 5 0.2 \
 --memory ${MEM} \
 --out ${Output_dir}/${Sample}_indepSNP

${p2_Dir}/plink2 --pfile ${Output_dir}/${Sample}_maf_hwe \
 --missing \
 --memory ${MEM} \
 --out ${Output_dir}/Before_miss

${p2_Dir}/plink2 --pfile ${Output_dir}/${Sample}_maf_hwe \
 --extract ${Output_dir}/${Sample}_indepSNP.prune.in --het \
 --memory ${MEM} \
 --out ${Output_dir}/Before_het

awk '{print $4"\tPheno"}' ${Output_dir}/Before_miss.smiss > ${Output_dir}/B_F_MISS
paste -d '\t' ${Output_dir}/Before_het.het ${Output_dir}/B_F_MISS > ${Output_dir}/R_BeforeQC_check.txt

singularity exec --bind /ichrogene/:/ichrogene/ ${Sig_dir}/PRS.sif Rscript /ichrogene/project/temp/gylee/0.GWAS/Code/R/het-missing.R

