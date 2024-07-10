#singularity exec --bind /ichrogene/:/ichrogene/ /ichrogene/project/temp/gylee/Singularity/gatk.sif bash /ichrogene/project/temp/gylee/Code/WES_code_folder/6.no_calGenoPos.99.7.sh alopecia.Case.Control
singularity exec --bind /ichrogene/:/ichrogene/ /ichrogene/project/temp/gylee/Singularity/gatk.sif bash /ichrogene/project/temp/gylee/Code/WES_code_folder/7.VariantFiltration.no_calGenoPos.99.7.sh alopecia.Case.Control
singularity exec --bind /ichrogene/:/ichrogene/ /ichrogene/project/temp/gylee/Singularity/gatk.sif bash /ichrogene/project/temp/gylee/Code/WES_code_folder/8.filter-PASS.sh alopecia.Case.Control 
singularity exec --bind /ichrogene/:/ichrogene/ /ichrogene/project/temp/gylee/Singularity/PRS.sif bash 1.snpeff.bcftools.sh alopecia.Case.Control
bash 2.snpeff_anno.sh alopecia.Case.Control
singularity exec --bind /ichrogene/:/ichrogene/ /ichrogene/project/temp/gylee/Singularity/PRS.sif bash 3.snpeff_merge.sh alopecia.Case.Control
bash 4.snpeff_filter.sh alopecia.Case.Control
