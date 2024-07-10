#/bin/bash
Input=$1
singularity exec --bind /ichrogene/:/ichrogene/ /ichrogene/project/temp/gylee/Singularity/minimac4_1.0.3.sif bcftools index -f -t --threads 32 /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/merged.vcf.gz
