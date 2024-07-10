#!/bin/bash
bam_Dir="/ichrogene/project/temp/gylee/1.WES/1.raw/cnu/"
ref_Dir="/ichrogene/project/temp/gylee/1.WES/REFERENCE/fasta/"
output_Dir="/ichrogene/project/temp/gylee/1.WES/2.weCall_result/"

for A in $(cat TN.list)
do
weCall --inputs ${bam_Dir}/${A}.bam --output ${output_Dir}/${A}.vcf --refFile ${ref_Dir}/GCF_000001405.40_GRCh38.p14_genomic.fa --numberOfJobs=30
done

