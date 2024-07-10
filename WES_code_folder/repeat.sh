#!/bin/bash
singularity exec --bind /ichrogene/:/ichrogene/ /ichrogene/project/temp/gylee/Singularity/gatk.sif bash test.sh
singularity exec --bind /ichrogene/:/ichrogene/ /ichrogene/project/temp/gylee/Singularity/gatk.sif bash 1.QC.sh 
