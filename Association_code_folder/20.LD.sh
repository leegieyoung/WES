#!/bin/sh
if [ $# -ne 2 ];then
   echo "Please enter Sample_Name"
     exit
fi

Var1=$1
Var2=$2
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

${Sig_dir}/plink19/plink --bfile ${plink_dir}/skin.1004.bfile --allow-extra-chr --ld $Var1 $Var2
