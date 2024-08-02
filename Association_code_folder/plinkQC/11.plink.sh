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
export Cli_DIR="${Dir}/1.clinical/"

#${p2_Dir}/plink2 --pfile ${Output_dir}/${Sample}_g_m_maf_hwe_het \
# --remove ${Dir}/1.clinical/remove.PCA.list \
# --make-pgen \
# --out ${Output_dir}/${Sample}_g_m_maf_hwe_het_pca
#
#${p2_Dir}/plink2 --pfile ${Output_dir}/${Sample}_g_m_maf_hwe_het \
# --exclude ${Inversion} \
# --indep-pairwise 50 5 0.02 \
# --threads ${Thread} \
# --memory ${MEM} \
# --out ${Output_dir}/${Sample}_pca_indepSNP
#
#${p2_Dir}/plink2 --pfile ${Output_dir}/${Sample}_g_m_maf_hwe_het_pca \
# --double-id \
# --pca 10 \
# --extract ${Output_dir}/${Sample}_pca_indepSNP.prune.in \
# --threads ${Thread} \
# --out ${Output_dir}/${Sample}_g_m_maf_hwe_het_pca_PCA
#
#singularity exec --bind /ichrogene/:/ichrogene/ ${Sig_dir}/PRS.sif Rscript /ichrogene/project/temp/gylee/0.GWAS/Code/R/covariate_forCNU.R 
#
##
#
#${p2_Dir}/plink2 --pfile ${Output_dir}/${Sample} \
# --geno 0.1 \
# --make-pgen \
# --threads ${Thread} \
# --memory ${MEM} \
# --out ${Output_dir}/${Sample}_g
#
#${p2_Dir}/plink2 --pfile ${Output_dir}/${Sample}_g \
# --mind 0.1 \
# --make-pgen \
# --threads ${Thread} \
# --memory ${MEM} \
# --out ${Output_dir}/${Sample}_g_m
#
#rm -rf ${Output_dir}/${Sample}_g.pgen
#rm -rf ${Output_dir}/${Sample}_g.psam
#rm -rf ${Output_dir}/${Sample}_g.pvar
#
#cat ${Dir}/1.clinical/remove.PCA.list ${Dir}/1.clinical/remove.het.missing.fail.list > ${Dir}/1.clinical/remove.merge.list
#
#${p2_Dir}/plink2 --pfile ${Output_dir}/${Sample}_g_m \
# --hwe 1e-6 \
# --make-pgen \
# --threads ${Thread} \
# --memory ${MEM} \
# --remove ${Dir}/1.clinical/remove.merge.list \
# --out ${Output_dir}/${Sample}_g_m_hwe_het_pca


#홍반
${p2_Dir}/plink2 --pfile ${Output_dir}/${Sample}_g_m_hwe_het_pca \
 --glm hide-covar \
 --memory ${MEM} \
 --pheno ${Output_dir}/covariate_forplink.txt \
 --pheno-name erythema \
 --covar-name PC1-PC10 age Sur2_2 \
 --covar-variance-standardize \
 --out ${Output_dir}/${Sample}_Sur2_2

${p2_Dir}/plink2 --pfile ${Output_dir}/${Sample}_g_m_hwe_het_pca \
 --glm hide-covar \
 --memory ${MEM} \
 --pheno ${Output_dir}/covariate_forplink.txt \
 --pheno-name erythema \
 --covar-name PC1-PC10 age \
 --covar-variance-standardize \
 --out ${Output_dir}/${Sample}_NoCov

#탄력
${p2_Dir}/plink2 --pfile ${Output_dir}/${Sample}_g_m_hwe_het_pca \
 --glm hide-covar \
 --memory ${MEM} \
 --pheno ${Output_dir}/covariate_forplink.txt \
 --pheno-name indentometer \
 --covar-name PC1-PC10 age Sur2_3 Sur3_2 Sur4_3 Sur5_3 \
 --covar-variance-standardize \
 --out ${Output_dir}/${Sample}_Sur23_32_43_53

${p2_Dir}/plink2 --pfile ${Output_dir}/${Sample}_g_m_hwe_het_pca \
 --glm hide-covar \
 --memory ${MEM} \
 --pheno ${Output_dir}/covariate_forplink.txt \
 --pheno-name indentometer \
 --covar-name PC1-PC10 age \
 --covar-variance-standardize \
 --out ${Output_dir}/${Sample}


