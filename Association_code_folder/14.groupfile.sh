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
SAGE_CD="/ichrogene/project/temp/gylee/0.GWAS/Code/SAIGE_code_folder"
snpeff_dir="/ichrogene/project/temp/gylee/1.WES/REFERENCE/snpEff/data"

export RESULT_DIR="${SAIGE_dir}/"
echo ${ANA_DIR}
export SAMPLE="${Sample}"
export Cli_DIR="${Dir}/1.clinical/"
export PHENO=${Trait}
export COV=${Cov}

${p2_Dir}/plink2 --pfile ${plink_dir}/${Sample}_hwe_het_pca \
 --max-maf 0.01 \
 --recode vcf \
 --out ${plink_dir}/${Sample}_hwe_het_pca_maf

singularity exec --bind /ichrogene/:/ichrogene/ ${Sig_dir}/PRS.sif bcftools view --threads 32 ${plink_dir}/${Sample}_hwe_het_pca_maf.vcf -Oz -o ${plink_dir}/${Sample}_hwe_het_pca_maf.vcf.gz

singularity exec --bind /ichrogene/:/ichrogene/ ${Sig_dir}/PRS.sif bcftools index -f --threads 32 ${plink_dir}/${Sample}_hwe_het_pca_maf.vcf.gz

java -Xms4g -Xmx4g -jar ${Sig_dir}/snpEff/snpEff.jar eff -dataDir ${snpeff_dir} -v GRCh38.86 ${plink_dir}/${Sample}_hwe_het_pca_maf.vcf.gz \
 > ${plink_dir}/${Sample}_hwe_het_pca_maf.snpEff.vcf

grep -v '^##' ${plink_dir}/${Sample}_hwe_het_pca_maf.snpEff.vcf > ${plink_dir}/${Sample}_hwe_het_pca_maf.snpEff.txt
