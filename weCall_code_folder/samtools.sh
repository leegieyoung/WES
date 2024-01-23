#!/bin/bash
#bam_Dir="/ichrogene/project/temp/gylee/1.WES/1.raw/cnu/"
bam_Dir="/ichrogene/project/temp/gylee/1.WES/1.raw/cnu_skin/"
ref_Dir="/ichrogene/project/temp/gylee/1.WES/REFERENCE/fasta/"
output_Dir="/ichrogene/project/temp/gylee/1.WES/2.weCall_result/"

#samtools flagstat ${bam_Dir}/TN1601D0395.bam > flagstat.TN1601D0395.bam
#samtools flagstat ${bam_Dir}/TN1601D0397.bam > flagstat.TN1601D0397.bam
#samtools flagstat ${bam_Dir}/TN1601D0399.bam > flagstat.TN1601D0399.bam
#samtools flagstat ${bam_Dir}/TN1601D0401.bam > flagstat.TN1601D0401.bam
#samtools flagstat ${bam_Dir}/TN1601D0404.bam > flagstat.TN1601D0404.bam
#samtools flagstat ${bam_Dir}/TN1601D0406.bam > flagstat.TN1601D0406.bam
#samtools flagstat ${bam_Dir}/TN1601D0408.bam > flagstat.TN1601D0408.bam
#samtools flagstat ${bam_Dir}/TN1601D0410.bam > flagstat.TN1601D0410.bam
#samtools flagstat ${bam_Dir}/TN1601D0413.bam > flagstat.TN1601D0413.bam
#samtools flagstat ${bam_Dir}/TN1601D0416.bam > flagstat.TN1601D0416.bam
#samtools flagstat ${bam_Dir}/TN1601D0419.bam > flagstat.TN1601D0419.bam
#samtools flagstat ${bam_Dir}/TN1601D0422.bam > flagstat.TN1601D0422.bam
#samtools flagstat ${bam_Dir}/TN1601D0425.bam > flagstat.TN1601D0425.bam
#samtools flagstat ${bam_Dir}/TN1601D0428.bam > flagstat.TN1601D0428.bam
#samtools flagstat ${bam_Dir}/TN1601D0430.bam > flagstat.TN1601D0430.bam
#samtools flagstat ${bam_Dir}/TN1601D0433.bam > flagstat.TN1601D0433.bam
#samtools flagstat ${bam_Dir}/TN1601D0436.bam > flagstat.TN1601D0436.bam
#samtools flagstat ${bam_Dir}/TN1601D0439.bam > flagstat.TN1601D0439.bam
#samtools flagstat ${bam_Dir}/TN1601D0442.bam > flagstat.TN1601D0442.bam
#samtools flagstat ${bam_Dir}/TN1601D0444.bam > flagstat.TN1601D0444.bam
#samtools flagstat ${bam_Dir}/TN1601D0447.bam > flagstat.TN1601D0447.bam
#samtools flagstat ${bam_Dir}/TN1601D0450.bam > flagstat.TN1601D0450.bam
#samtools flagstat ${bam_Dir}/TN1601D0452.bam > flagstat.TN1601D0452.bam
#samtools flagstat ${bam_Dir}/TN1601D0455.bam > flagstat.TN1601D0452.bam
mkdir ${bam_Dir}/flagstats
for A in $(cat ${bam_Dir}/bam.list)
do
samtools flagstat ${bam_Dir}/${A}.bam -@ 30 > ${bam_Dir}/flagstats/${A}.flagstats
done
