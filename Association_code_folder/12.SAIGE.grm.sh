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
SAIGE_dir="${Dir}/7.SAIGE"
Sig_dir="/ichrogene/project/temp/gylee/Singularity"
SAIGE_CD="/ichrogene/project/temp/gylee/0.GWAS/Code/SAIGE_code_folder"
#SAIGE_dir="${Dir}/2.SAIGE_result/${Sample}/result"

mkdir -p ${SAIGE_dir}/LOG
mkdir -p ${SAIGE_dir}/createSparseGRM

export RESULT_DIR="${plink_dir}/"
echo ${ANA_DIR}
export SAMPLE="${Sample}"
export Cli_DIR="${Dir}/1.clinical/"
export PHENO=${Trait}

${p2_Dir}/plink2 --pfile ${plink_dir}/${Sample}_hwe_het_pca \
 --memory ${MEM} \
 --exclude ${Inversion} \
 --indep-pairwise 200 100 0.1 \
 --out ${plink_dir}/${Sample}_hwe_het_pca_indepSNP

${p2_Dir}/plink2 --pfile ${plink_dir}/${Sample}_hwe_het_pca \
 --memory ${MEM} \
 --extract ${plink_dir}/${Sample}_hwe_het_pca_indepSNP.prune.in \
 --make-bed \
 --out ${plink_dir}/${Sample}_hwe_het_pca_prune
sed -i -e 's/^X/23/g' -e 's/^PAR1/23/g' -e 's/^PAR2/23/g' -e 's/^Y/24/g' -e 's/^MT/25/g' ${plink_dir}/${Sample}_hwe_het_pca_prune.bim

echo "=========================="
echo "Start Step0.createSparseGRM.sh"
echo "=========================="


Rscript ${SAIGE_CD}/createSparseGRM.R \
     --plinkFile=${plink_dir}/${Sample}_hwe_het_pca_prune \
     --nThreads=28  \
     --outputPrefix=${SAIGE_dir}/createSparseGRM/sparseGRM \
     --numRandomMarkerforSparseKin=5000 \
     --relatednessCutoff=0.05 > ${SAIGE_dir}/LOG/createSparseGRM.log

${p2_Dir}/plink2 --pfile ${plink_dir}/${Sample}_hwe_het_pca \
 --sort-vars \
 --memory ${MEM} \
 --make-pgen \
 --out ${plink_dir}/${Sample}_hwe_het_pca_sort

${p2_Dir}/plink2 --pfile ${plink_dir}/${Sample}_hwe_het_pca_sort \
 --make-bed \
 --memory ${MEM} \
 --out ${plink_dir}/${Sample}_hwe_het_pca_bfile

sed -i -e 's/^X/23/g' -e 's/^PAR1/23/g' -e 's/^PAR2/23/g' -e 's/^Y/24/g' -e 's/^MT/25/g' ${plink_dir}/${Sample}_hwe_het_pca_bfile.bim
