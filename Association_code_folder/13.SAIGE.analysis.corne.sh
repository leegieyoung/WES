#!/bin/sh
if [ $# -ne 5 ];then
   echo "Please enter Sample_Name"
     exit
fi

Sample=$1
Thread=$2
MEM=$3
Trait=$4
Cov=$5
Dir="/ichrogene/project/temp/gylee/1.WES/2.gatk_result/skin.1004/"
raw_dir="${Dir}/5.custom.filter/result/Find_Nomaf"
p2_Dir="/ichrogene/project/temp/gylee/Singularity/plink2"
Inversion="/ichrogene/project/temp/gylee/0.GWAS/REFERENCE/inversion.txt"
plink_dir="${Dir}/6.plinkQC"
SAIGE_dir="${Dir}/7.SAIGE"
Sig_dir="/ichrogene/project/temp/gylee/Singularity"
SAGE_CD="/ichrogene/project/temp/gylee/0.GWAS/Code/SAIGE_code_folder"


export RESULT_DIR="${SAIGE_dir}/"
echo ${ANA_DIR}
export SAMPLE="${Sample}"
export Cli_DIR="${Dir}/1.clinical/"
export PHENO=${Trait}
export COV=${Cov}

echo "=========================="
echo "Start step1_fitNULLGLMM.R"
echo "=========================="
#Single variants association
rm -rf ${plink_dir}/SAIGE_${Trait}_${Cov}.rda
rm -rf ${plink_dir}/SAIGE_${Trait}_${Cov}.varianceRatio.txt
Rscript ${SAGE_CD}/step1_fitNULLGLMM.R     \
 --plinkFile=${plink_dir}/${Sample}_hwe_het_pca_prune \
 --sparseGRMFile=${SAIGE_dir}/createSparseGRM/sparseGRM_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx \
 --sparseGRMSampleIDFile=${SAIGE_dir}/createSparseGRM/sparseGRM_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx.sampleIDs.txt \
 --phenoFile=${plink_dir}/covariate_forSAIGE.txt \
 --phenoCol=${Trait} \
 --covarColList=tewameter,PC1,PC2,PC3,PC4,PC5,PC6,PC7,PC8,PC9,PC10,age,${Cov} \
 --qCovarColList=${Cov} \
 --sampleIDColinphenoFile=#IID \
 --traitType=quantitative \
 --invNormalize=TRUE \
 --outputPrefix=${SAIGE_dir}/SAIGE_${Trait}_${Cov} \
 --nThreads=32 \
 --useSparseGRMtoFitNULL=TRUE \
 --isCateVarianceRatio=TRUE \
 --LOCO=TRUE \
 --outputPrefix_varRatio=${SAIGE_dir}/SAIGE_${Trait}_${Cov} \
 --IsOverwriteVarianceRatioFile=TRUE > ${SAIGE_dir}/LOG/SAIGE_${Trait}_${Cov}.log

echo "=========================="
echo "Single variants association"
echo "=========================="
#Step 2 for single variant tests only
Rscript ${SAGE_CD}/step2_SPAtests.R \
 --bedFile=${plink_dir}/${Sample}_hwe_het_pca_bfile.bed \
 --bimFile=${plink_dir}/${Sample}_hwe_het_pca_bfile.bim \
 --famFile=${plink_dir}/${Sample}_hwe_het_pca_bfile.fam \
 --sparseGRMFile=${SAIGE_dir}/createSparseGRM/sparseGRM_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx \
 --sparseGRMSampleIDFile=${SAIGE_dir}/createSparseGRM/sparseGRM_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx.sampleIDs.txt \
 --AlleleOrder=ref-first \
 --SAIGEOutputFile=${SAIGE_dir}/SAIGE_${Trait}.${Cov}.single.txt \
 --minMAF=0 \
 --minMAC=0.5 \
 --GMMATmodelFile=${SAIGE_dir}/SAIGE_${Trait}_${Cov}.rda \
 --varianceRatioFile=${SAIGE_dir}/SAIGE_${Trait}_${Cov}.varianceRatio.txt \
 --LOCO=FALSE \
 --is_Firth_beta=TRUE \
 --pCutoffforFirth=0.05 \
 --is_output_moreDetails=TRUE \
 --is_fastTest=TRUE > ${SAIGE_dir}/LOG/SAIGE_${Trait}_${Cov}.single.log

echo "=========================="
echo "Set based association"
echo "=========================="
#Step 3 for set-based tests
Rscript ${SAGE_CD}/step2_SPAtests.R \
 --bedFile=${plink_dir}/${Sample}_hwe_het_pca_bfile.bed \
 --bimFile=${plink_dir}/${Sample}_hwe_het_pca_bfile.bim \
 --famFile=${plink_dir}/${Sample}_hwe_het_pca_bfile.fam \
 --SAIGEOutputFile=${SAIGE_dir}/SAIGE_${Trait}.${Cov}.set-based.txt \
 --AlleleOrder=ref-first \
 --minMAF=0 \
 --minMAC=0.5 \
 --GMMATmodelFile=${SAIGE_dir}/SAIGE_${Trait}_${Cov}.rda \
 --varianceRatioFile=${SAIGE_dir}/SAIGE_${Trait}_${Cov}.varianceRatio.txt \
 --sparseGRMFile=${SAIGE_dir}/createSparseGRM/sparseGRM_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx \
 --sparseGRMSampleIDFile=${SAIGE_dir}/createSparseGRM/sparseGRM_relatednessCutoff_0.05_5000_randomMarkersUsed.sparseGRM.mtx.sampleIDs.txt \
 --groupFile=${Dir}/8.group/merge.txt \
 --annotation_in_groupTest="HIGH,missense:HIGH" \
 --maxMAF_in_groupTest=0.0005,0.001,0.01 \
 --is_output_markerList_in_groupTest=TRUE \
 --is_single_in_groupTest=TRUE \
 --is_Firth_beta=TRUE \
 --pCutoffforFirth=0.05 \
 --LOCO=FALSE \
 --is_fastTest=TRUE > ${SAIGE_dir}/LOG/SAIGE_${Trait}_${Cov}.set-based.log

Rscript /ichrogene/project/temp/gylee/0.GWAS/Code/R/Manhattan_plot.SAIGE.forlinear.R
