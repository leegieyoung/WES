#!/bin/bash
Input=$1

bam_Dir="/ichrogene/project/temp/gylee/1.WES/0.raw/cnu/"
fastq_Dir="/ichrogene/project/temp/gylee/1.WES/0.raw/cnu/fastq"
ref_Dir="/ichrogene/project/temp/gylee/1.WES/REFERENCE/fasta/"
output_Dir="/ichrogene/project/temp/gylee/1.WES/2.weCall_result/"
Sing_Dir="/ichrogene/project/temp/gylee/Singularity"
scratch="/ichrogene/"
snpEff_Dir="/ichrogene/project/temp/gylee/1.WES/REFERENCE/snpEff/data/"
output_snpEff_Dir="/ichrogene/project/temp/gylee/1.WES/3.snpEff_result"
dbsnp_Dir="/ichrogene/project/temp/gylee/1.WES/REFERENCE/dbsnp"
QC_Dir="/ichrogene/project/temp/gylee/1.WES/1.QC/"

Seq=(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 "X" "Y" "M")
Odd1=(1 7 13 19)
Odd2=(3 9 15 21)
Odd3=(5 11 17 "X")
Even1=(2 8 14 20)
Even2=(4 10 16 22)
Even3=(6 12 18 "Y")
chrM="M"
Other=("X" "Y" "M")
mkdir /ichrogene/project/temp/gylee/1.WES/temp

#GenomicsDBImport
mkdir /ichrogene/project/temp/gylee/1.WES/dbLOG
for A in "${Odd1[@]}"
do
rm -rf /ichrogene/project/temp/gylee/1.WES/dbLOG/chr${A}.log
rm -rf /ichrogene/project/temp/gylee/1.WES/${Input}_chr${A}/
echo "=========================="
echo "Start chr${A}"
gatk --java-options "-Xms12G -Xmx12G -XX:ParallelGCThreads=6"  GenomicsDBImport \
 --genomicsdb-workspace-path /ichrogene/project/temp/gylee/1.WES/${Input}_chr${A}/ \
 -R /ichrogene/project/temp/gylee/1.WES/REFERENCE/fasta/Homo_sapiens_assembly38.fasta \
 --sample-name-map /ichrogene/project/temp/gylee/1.WES/${Input}.map \
 --tmp-dir /ichrogene/project/temp/gylee/1.WES/temp \
 --reader-threads 6 \
 --max-num-intervals-to-import-in-parallel 3 --intervals chr${A} > /ichrogene/project/temp/gylee/1.WES/dbLOG/chr${A}.log 2>&1 &
sleep 3
done
wait

for A in "${Even1[@]}"
do
rm -rf /ichrogene/project/temp/gylee/1.WES/dbLOG/chr${A}.log
rm -rf /ichrogene/project/temp/gylee/1.WES/${Input}_chr${A}/
echo "=========================="
echo "Start chr${A}"
gatk --java-options "-Xms12G -Xmx12G -XX:ParallelGCThreads=6"  GenomicsDBImport \
 --genomicsdb-workspace-path /ichrogene/project/temp/gylee/1.WES/${Input}_chr${A}/ \
 -R /ichrogene/project/temp/gylee/1.WES/REFERENCE/fasta/Homo_sapiens_assembly38.fasta \
 --sample-name-map /ichrogene/project/temp/gylee/1.WES/${Input}.map \
 --tmp-dir /ichrogene/project/temp/gylee/1.WES/temp \
 --reader-threads 6 \
 --max-num-intervals-to-import-in-parallel 3 --intervals chr${A} > /ichrogene/project/temp/gylee/1.WES/dbLOG/chr${A}.log 2>&1 &
sleep 3
done
wait

for A in "${Odd2[@]}"
do
rm -rf /ichrogene/project/temp/gylee/1.WES/dbLOG/chr${A}.log
rm -rf /ichrogene/project/temp/gylee/1.WES/${Input}_chr${A}/
echo "=========================="
echo "Start chr${A}"
gatk --java-options "-Xms12G -Xmx12G -XX:ParallelGCThreads=6"  GenomicsDBImport \
 --genomicsdb-workspace-path /ichrogene/project/temp/gylee/1.WES/${Input}_chr${A}/ \
 -R /ichrogene/project/temp/gylee/1.WES/REFERENCE/fasta/Homo_sapiens_assembly38.fasta \
 --sample-name-map /ichrogene/project/temp/gylee/1.WES/${Input}.map \
 --tmp-dir /ichrogene/project/temp/gylee/1.WES/temp \
 --reader-threads 6 \
 --max-num-intervals-to-import-in-parallel 3 --intervals chr${A} > /ichrogene/project/temp/gylee/1.WES/dbLOG/chr${A}.log 2>&1 &
sleep 3
done
wait

for A in "${Even2[@]}"
do
rm -rf /ichrogene/project/temp/gylee/1.WES/dbLOG/chr${A}.log
rm -rf /ichrogene/project/temp/gylee/1.WES/${Input}_chr${A}/
echo "=========================="
echo "Start chr${A}"
gatk --java-options "-Xms12G -Xmx12G -XX:ParallelGCThreads=6"  GenomicsDBImport \
 --genomicsdb-workspace-path /ichrogene/project/temp/gylee/1.WES/${Input}_chr${A}/ \
 -R /ichrogene/project/temp/gylee/1.WES/REFERENCE/fasta/Homo_sapiens_assembly38.fasta \
 --sample-name-map /ichrogene/project/temp/gylee/1.WES/${Input}.map \
 --tmp-dir /ichrogene/project/temp/gylee/1.WES/temp \
 --reader-threads 6 \
 --max-num-intervals-to-import-in-parallel 3 --intervals chr${A} > /ichrogene/project/temp/gylee/1.WES/dbLOG/chr${A}.log 2>&1 &
sleep 3
done
wait

for A in "${Odd3[@]}"
do
rm -rf /ichrogene/project/temp/gylee/1.WES/dbLOG/chr${A}.log
rm -rf /ichrogene/project/temp/gylee/1.WES/${Input}_chr${A}/
echo "=========================="
echo "Start chr${A}"
gatk --java-options "-Xms12G -Xmx12G -XX:ParallelGCThreads=6"  GenomicsDBImport \
 --genomicsdb-workspace-path /ichrogene/project/temp/gylee/1.WES/${Input}_chr${A}/ \
 -R /ichrogene/project/temp/gylee/1.WES/REFERENCE/fasta/Homo_sapiens_assembly38.fasta \
 --sample-name-map /ichrogene/project/temp/gylee/1.WES/${Input}.map \
 --tmp-dir /ichrogene/project/temp/gylee/1.WES/temp \
 --reader-threads 6 \
 --max-num-intervals-to-import-in-parallel 3 --intervals chr${A} > /ichrogene/project/temp/gylee/1.WES/dbLOG/chr${A}.log 2>&1 &
sleep 3
done
wait

for A in "${Even3[@]}"
do
rm -rf /ichrogene/project/temp/gylee/1.WES/dbLOG/chr${A}.log
rm -rf /ichrogene/project/temp/gylee/1.WES/${Input}_chr${A}/
echo "=========================="
echo "Start chr${A}"
gatk --java-options "-Xms12G -Xmx12G -XX:ParallelGCThreads=6"  GenomicsDBImport \
 --genomicsdb-workspace-path /ichrogene/project/temp/gylee/1.WES/${Input}_chr${A}/ \
 -R /ichrogene/project/temp/gylee/1.WES/REFERENCE/fasta/Homo_sapiens_assembly38.fasta \
 --sample-name-map /ichrogene/project/temp/gylee/1.WES/${Input}.map \
 --tmp-dir /ichrogene/project/temp/gylee/1.WES/temp \
 --reader-threads 6 \
 --max-num-intervals-to-import-in-parallel 3 --intervals chr${A} > /ichrogene/project/temp/gylee/1.WES/dbLOG/chr${A}.log 2>&1 &
sleep 3
done
wait

#chrM
rm -rf /ichrogene/project/temp/gylee/1.WES/dbLOG/chr${chrM}.log
rm -rf /ichrogene/project/temp/gylee/1.WES/${Input}_chr${chrM}/
echo "=========================="
echo "Start chr${chrM}"
gatk --java-options "-Xms12G -Xmx12G -XX:ParallelGCThreads=6"  GenomicsDBImport \
 --genomicsdb-workspace-path /ichrogene/project/temp/gylee/1.WES/${Input}_chr${chrM}/ \
 -R /ichrogene/project/temp/gylee/1.WES/REFERENCE/fasta/Homo_sapiens_assembly38.fasta \
 --sample-name-map /ichrogene/project/temp/gylee/1.WES/${Input}.map \
 --tmp-dir /ichrogene/project/temp/gylee/1.WES/temp \
 --reader-threads 6 \ 
 --max-num-intervals-to-import-in-parallel 3 --intervals chr${chrM} > /ichrogene/project/temp/gylee/1.WES/dbLOG/chr${chrM}.log 2>&1 &
wait

#GenotypeGVCFs
for A in "${seq[@]}"
do
rm -rf /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/chr${A}.vcf.gz
echo "======================================"
echo ${A}
gatk --java-options "-Xms2G -Xmx2G -XX:ParallelGCThreads=4" GenotypeGVCFs \
 -R /ichrogene/project/temp/gylee/1.WES/REFERENCE/fasta/Homo_sapiens_assembly38.fasta \
 -V gendb:///ichrogene/project/temp/gylee/1.WES/${Input}_chr${A} \
 -O /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/chr${A}.vcf.gz > /ichrogene/project/temp/gylee/1.WES/dbLOG/GenotypeGVCFs.chr${A}.log 2>&1 &
sleep 3
done
wait

gatk --java-options "-Xms58G -Xmx58G -XX:ParallelGCThreads=32" GatherVcfs \
 I= /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/chr1.vcf.gz \
 I= /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/chr2.vcf.gz \
 I= /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/chr3.vcf.gz \
 I= /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/chr4.vcf.gz \
 I= /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/chr5.vcf.gz \
 I= /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/chr6.vcf.gz \
 I= /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/chr7.vcf.gz \
 I= /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/chr8.vcf.gz \
 I= /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/chr9.vcf.gz \
 I= /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/chr10.vcf.gz \
 I= /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/chr11.vcf.gz \
 I= /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/chr12.vcf.gz \
 I= /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/chr13.vcf.gz \
 I= /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/chr14.vcf.gz \
 I= /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/chr15.vcf.gz \
 I= /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/chr16.vcf.gz \
 I= /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/chr17.vcf.gz \
 I= /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/chr18.vcf.gz \
 I= /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/chr19.vcf.gz \
 I= /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/chr20.vcf.gz \
 I= /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/chr21.vcf.gz \
 I= /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/chr22.vcf.gz \
 I= /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/chrX.vcf.gz \
 I= /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/chrY.vcf.gz \
 I= /ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/chrM.vcf.gz O=/ichrogene/project/temp/gylee/1.WES/2.gatk_result/${Input}/GenotypeGVCFs/merged.vcf.gz
