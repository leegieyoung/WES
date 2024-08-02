#!/bin/bash
Input=$1
#singularity exec --bind /ichrogene/:/ichrogene/ /ichrogene/project/temp/gylee/Singularity/gatk.sif bash 4.db.largeSample.240725.sh ${Input}

#singularity exec --bind /ichrogene/:/ichrogene/ /ichrogene/project/temp/gylee/Singularity/gatk.sif bash 4-2.db.largeSample.GenotypeGVCFs.sh ${Input}
singularity exec --bind /ichrogene/:/ichrogene/ /ichrogene/project/temp/gylee/Singularity/gatk.sif bash temp.4-2.db.largeSample.GenotypeGVCFs.sh ${Input}

singularity exec --bind /ichrogene/:/ichrogene/ /ichrogene/project/temp/gylee/Singularity/gatk.sif bash 5.merge.sh ${Input}

singularity exec --bind /ichrogene/:/ichrogene/ /ichrogene/project/temp/gylee/Singularity/PRS.sif bash 5.merge.index.sh ${Input}

singularity exec --bind /ichrogene/:/ichrogene/ /ichrogene/project/temp/gylee/Singularity/gatk.sif bash 6.no_calGenoPos.99.7.240725.sh ${Input}

singularity exec --bind /ichrogene/:/ichrogene/ /ichrogene/project/temp/gylee/Singularity/gatk.sif bash 7.VariantFiltration.no_calGenoPos.99.7.sh ${Input}

singularity exec --bind /ichrogene/:/ichrogene/ /ichrogene/project/temp/gylee/Singularity/PRS.sif bash 8.filter-PASS.sh ${Input}
