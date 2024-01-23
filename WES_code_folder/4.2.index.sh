singularity exec --bind /ichrogene/:/ichrogene/ /ichrogene/project/temp/gylee/Singularity/minimac4_1.0.3.sif bcftools index -f -t --threads 32 merged.vcf.gz
