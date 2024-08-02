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
export Cli_DIR="${Dir}/1.clinical/"

${p2_Dir}/plink2 --pfile ${plink_dir}/${Sample}_maf_hwe_het \
 --remove ${Dir}/1.clinical/remove.PCA.list \
 --make-pgen \
 --out ${plink_dir}/${Sample}_maf_hwe_het_pca

${p2_Dir}/plink2 --pfile ${plink_dir}/${Sample}_maf_hwe_het \
 --exclude ${Inversion} \
 --indep-pairwise 200 100 0.1 \
 --threads ${Thread} \
 --memory ${MEM} \
 --out ${plink_dir}/${Sample}_pca_indepSNP

${p2_Dir}/plink2 --pfile ${plink_dir}/${Sample}_maf_hwe_het_pca \
 --double-id \
 --pca 10 \
 --extract ${plink_dir}/${Sample}_pca_indepSNP.prune.in \
 --threads ${Thread} \
 --out ${plink_dir}/${Sample}_maf_hwe_het_pca_PCA

singularity exec --bind /ichrogene/:/ichrogene/ ${Sig_dir}/PRS.sif Rscript /ichrogene/project/temp/gylee/0.GWAS/Code/R/covariate_forCNU.R 

cat ${Dir}/1.clinical/remove.PCA.list ${Dir}/1.clinical/remove.het.missing.fail.list > ${Dir}/1.clinical/remove.merge.list

${p2_Dir}/plink2 --pfile ${plink_dir}/${Sample} \
 --hwe 1e-6 \
 --make-pgen \
 --threads ${Thread} \
 --memory ${MEM} \
 --remove ${Dir}/1.clinical/remove.merge.list \
 --out ${plink_dir}/${Sample}_hwe_het_pca
