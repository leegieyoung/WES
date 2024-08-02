#!/bin/bash
Dir="/ichrogene/project/temp/gylee/1.WES/2.gatk_result/skin.1004/5.custom.filter/result/Find_Nomaf"
rm -rf ${Dir}/QC.marker.vcf
cat ${Dir}/header ${Dir}/1.QC.marker.nohead >> ${Dir}/QC.marker.vcf
Seq=(2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 "X" "M")

for A in "${Seq[@]}"
do
grep -v '^#' ${Dir}/${A}.QC.marker.nohead > ${Dir}/temp.nohead
cat ${Dir}/QC.marker.vcf ${Dir}/temp.nohead > ${Dir}/temp.file
mv ${Dir}/temp.file ${Dir}/QC.marker.vcf
done

rm ${Dir}/temp.nohead


