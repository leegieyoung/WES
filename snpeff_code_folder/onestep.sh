#singularity exec --bind /ichrogene/:/ichrogene/ /ichrogene/project/temp/gylee/Singularity/gatk.sif bash /ichrogene/project/temp/gylee/Code/WES_code_folder/6.no_calGenoPos.99.7.sh skin.1004
#singularity exec --bind /ichrogene/:/ichrogene/ /ichrogene/project/temp/gylee/Singularity/gatk.sif bash /ichrogene/project/temp/gylee/Code/WES_code_folder/7.VariantFiltration.no_calGenoPos.99.7.sh skin.1004
#singularity exec --bind /ichrogene/:/ichrogene/ /ichrogene/project/temp/gylee/Singularity/gatk.sif bash /ichrogene/project/temp/gylee/Code/WES_code_folder/8.filter-PASS.sh skin.1004 
singularity exec --bind /ichrogene/:/ichrogene/ /ichrogene/project/temp/gylee/Singularity/PRS.sif bash 1.snpeff.bcftools.sh skin.1004
bash 2.snpeff_anno.sh skin.1004
singularity exec --bind /ichrogene/:/ichrogene/ /ichrogene/project/temp/gylee/Singularity/PRS.sif bash 3.snpeff_merge.sh skin.1004
bash 4.snpeff_filter.sh skin.1004
