#!/bin/bash
Input=$1
Result_Dir="/ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/4.VariantFiltration"
Singularity_Dir="/ichrogene/project/temp/gylee/Singularity"
data_Dir="/ichrogene/project/temp/gylee/1.WES/REFERENCE/snpEff/data"
REFERENCE="/ichrogene/project/temp/gylee/1.WES/REFERENCE/"
Seq=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 "X" "Y" "M")

#SNP
snp_snpeff() {
	if [ $# -ne 1 ];then
        echo "Please enter Sample_Name"
               exit
fi
	echo "${Input} / snpEff / GRCh38.86 / chr${A}_snps_filtered.PASS"
java -Xms2g -Xmx2g -jar ${Singularity_Dir}/snpEff/snpEff.jar eff -dataDir ${data_Dir} -v GRCh38.86 ${Result_Dir}/temp/chr${A}_snps_filtered.PASS.vcf.gz > ${Result_Dir}/temp/chr${A}_snps_filtered.PASS.snpEff.vcf
singularity exec --bind /ichrogene/:/ichrogene/ ${Singularity_Dir}/PRS.sif bcftools view --threads 32 ${Result_Dir}/temp/chr${A}_snps_filtered.PASS.snpEff.vcf -Oz -o ${Result_Dir}/temp/chr${A}_snps_filtered.PASS.snpEff.vcf.gz

	echo "${Input} / SnpSift / dbsnp151 / chr${A}_snps_filtered.PASS"
java -Xms2g -Xmx2g -jar ${Singularity_Dir}/snpEff/SnpSift.jar annotate ${REFERENCE}/dbsnp/dbsnp151.GRCh38.p7.chrM_edit.vcf.gz ${Result_Dir}/temp/chr${A}_snps_filtered.PASS.snpEff.vcf.gz > ${Result_Dir}/temp/chr${A}_snps_filtered.PASS.snpEff.rsID.vcf
singularity exec --bind /ichrogene/:/ichrogene/ ${Singularity_Dir}/PRS.sif bcftools view --threads 32 ${Result_Dir}/temp/chr${A}_snps_filtered.PASS.snpEff.rsID.vcf -Oz -o ${Result_Dir}/temp/chr${A}_snps_filtered.PASS.snpEff.rsID.vcf.gz

	echo "${Input} / SnpSift dbnsfp chr${A}_snps_filtered.PASS"
java -Xms2g -Xmx2g -jar ${Singularity_Dir}/snpEff/SnpSift.jar dbnsfp -dataDir ${data_Dir} -v -db ${REFERENCE}/dbNSFP/dbNSFP4.5a.txt.gz ${Result_Dir}/temp/chr${A}_snps_filtered.PASS.snpEff.rsID.vcf.gz > ${Result_Dir}/temp/chr${A}_snps_filtered.PASS.snpEff.rsID.dbnsfp.vcf
singularity exec --bind /ichrogene/:/ichrogene/ ${Singularity_Dir}/PRS.sif bcftools view --threads 32 ${Result_Dir}/temp/chr${A}_snps_filtered.PASS.snpEff.rsID.dbnsfp.vcf -Oz -o ${Result_Dir}/temp/chr${A}_snps_filtered.PASS.snpEff.rsID.dbnsfp.vcf.gz

	echo "${Input} / SnpSift CADD chr${A}_snps_filtered.PASS"
java -Xms2g -Xmx2g -jar ${Singularity_Dir}/snpEff/SnpSift.jar dbnsfp -dataDir ${data_Dir} -v -db ${REFERENCE}/dbNSFP/dbNSFP4.5a.txt.gz -f CADD_phred ${Result_Dir}/temp/chr${A}_snps_filtered.PASS.snpEff.rsID.dbnsfp.vcf.gz > ${Result_Dir}/temp/chr${A}_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.vcf
singularity exec --bind /ichrogene/:/ichrogene/ ${Singularity_Dir}/PRS.sif bcftools view --threads 32 ${Result_Dir}/temp/chr${A}_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.vcf -Oz -o ${Result_Dir}/temp/chr${A}_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.vcf.gz

        echo "${Input} / SnpSift clinvar chr${A}_snps_filtered.PASS"
java -Xms2g -Xmx2g -jar ${Singularity_Dir}/snpEff/SnpSift.jar annotate ${REFERENCE}/clinvar/GRCh38/clinvar_20240221.vcf.gz ${Result_Dir}/temp/chr${A}_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.vcf.gz > ${Result_Dir}/temp/chr${A}_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf
singularity exec --bind /ichrogene/:/ichrogene/ ${Singularity_Dir}/PRS.sif bcftools view --threads 32 ${Result_Dir}/temp/chr${A}_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf -Oz -o ${Result_Dir}/temp/chr${A}_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz
singularity exec --bind /ichrogene/:/ichrogene/ ${Singularity_Dir}/PRS.sif bcftools index --threads 32 ${Result_Dir}/temp/chr${A}_snps_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz

#==========
        echo "${Input} / snpEff / GRCh38.86 / chr${A}_indels_filtered.PASS"
java -Xms2g -Xmx2g -jar ${Singularity_Dir}/snpEff/snpEff.jar eff -dataDir ${data_Dir} -v GRCh38.86 ${Result_Dir}/temp/chr${A}_indels_filtered.PASS.vcf.gz > ${Result_Dir}/temp/chr${A}_indels_filtered.PASS.snpEff.vcf
singularity exec --bind /ichrogene/:/ichrogene/ ${Singularity_Dir}/PRS.sif bcftools view --threads 32 ${Result_Dir}/temp/chr${A}_indels_filtered.PASS.snpEff.vcf -Oz -o ${Result_Dir}/temp/chr${A}_indels_filtered.PASS.snpEff.vcf.gz

        echo "${Input} / SnpSift / dbsnp151 / chr${A}_indels_filtered.PASS"
java -Xms2g -Xmx2g -jar ${Singularity_Dir}/snpEff/SnpSift.jar annotate ${REFERENCE}/dbsnp/dbsnp151.GRCh38.p7.chrM_edit.vcf.gz ${Result_Dir}/temp/chr${A}_indels_filtered.PASS.snpEff.vcf.gz > ${Result_Dir}/temp/chr${A}_indels_filtered.PASS.snpEff.rsID.vcf
singularity exec --bind /ichrogene/:/ichrogene/ ${Singularity_Dir}/PRS.sif bcftools view --threads 32 ${Result_Dir}/temp/chr${A}_indels_filtered.PASS.snpEff.rsID.vcf -Oz -o ${Result_Dir}/temp/chr${A}_indels_filtered.PASS.snpEff.rsID.vcf.gz

        echo "${Input} / SnpSift dbnsfp chr${A}_indels_filtered.PASS"
java -Xms2g -Xmx2g -jar ${Singularity_Dir}/snpEff/SnpSift.jar dbnsfp -dataDir ${data_Dir} -v -db ${REFERENCE}/dbNSFP/dbNSFP4.5a.txt.gz ${Result_Dir}/temp/chr${A}_indels_filtered.PASS.snpEff.rsID.vcf.gz > ${Result_Dir}/temp/chr${A}_indels_filtered.PASS.snpEff.rsID.dbnsfp.vcf
singularity exec --bind /ichrogene/:/ichrogene/ ${Singularity_Dir}/PRS.sif bcftools view --threads 32 ${Result_Dir}/temp/chr${A}_indels_filtered.PASS.snpEff.rsID.dbnsfp.vcf -Oz -o ${Result_Dir}/temp/chr${A}_indels_filtered.PASS.snpEff.rsID.dbnsfp.vcf.gz

        echo "${Input} / SnpSift CADD chr${A}_indels_filtered.PASS"
java -Xms2g -Xmx2g -jar ${Singularity_Dir}/snpEff/SnpSift.jar dbnsfp -dataDir ${data_Dir} -v -db ${REFERENCE}/dbNSFP/dbNSFP4.5a.txt.gz -f CADD_phred ${Result_Dir}/temp/chr${A}_indels_filtered.PASS.snpEff.rsID.dbnsfp.vcf.gz > ${Result_Dir}/temp/chr${A}_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.vcf
singularity exec --bind /ichrogene/:/ichrogene/ ${Singularity_Dir}/PRS.sif bcftools view --threads 32 ${Result_Dir}/temp/chr${A}_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.vcf -Oz -o ${Result_Dir}/temp/chr${A}_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.vcf.gz

        echo "${Input} / SnpSift clinvar chr${A}_indels_filtered.PASS"
java -Xms2g -Xmx2g -jar ${Singularity_Dir}/snpEff/SnpSift.jar annotate ${REFERENCE}/clinvar/GRCh38/clinvar_20240221.vcf.gz ${Result_Dir}/temp/chr${A}_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.vcf.gz > ${Result_Dir}/temp/chr${A}_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf
singularity exec --bind /ichrogene/:/ichrogene/ ${Singularity_Dir}/PRS.sif bcftools view --threads 32 ${Result_Dir}/temp/chr${A}_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf -Oz -o ${Result_Dir}/temp/chr${A}_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz
singularity exec --bind /ichrogene/:/ichrogene/ ${Singularity_Dir}/PRS.sif bcftools index --threads 32 ${Result_Dir}/temp/chr${A}_indels_filtered.PASS.snpEff.rsID.dbnsfp.CADD.clinvar.vcf.gz

}
mkdir ${Result_Dir}/temp/
for A in "${Seq[@]}"
do
echo "========="
echo "${A} Start"
snp_snpeff ${A} > /dev/null 2>&1 &
sleep 30
done
wait

#Part 3
#singularity exec --bind /ichrogene/:/ichrogene/ ${Singularity_Dir}/PRS.sif bash /ichrogene/project/temp/gylee/Code/snpeff_code_folder/3.snpeff_merge.sh ${Input}
