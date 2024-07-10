#!/bin/bash
#sed -n '1,10p' cnu.skin.100.list > cnu.skin.part1.list
#sed -n '11,20p' cnu.skin.100.list > cnu.skin.part2.list
#sed -n '21,30p' cnu.skin.100.list > cnu.skin.part3.list
#sed -n '31,40p' cnu.skin.100.list > cnu.skin.part4.list
#sed -n '41,50p' cnu.skin.100.list > cnu.skin.part5.list
#sed -n '51,60p' cnu.skin.100.list > cnu.skin.part6.list
#sed -n '61,70p' cnu.skin.100.list > cnu.skin.part7.list
#sed -n '71,80p' cnu.skin.100.list > cnu.skin.part8.list
#sed -n '81,90p' cnu.skin.100.list > cnu.skin.part9.list
#sed -n '91,100p' cnu.skin.100.list > cnu.skin.part10.list

sed -n '101,229p' /ichrogene/project/temp/gylee/1.WES/0.raw/cnu_skin/bam.list > cnu.skin.part2.list
sed -n '230,358p' /ichrogene/project/temp/gylee/1.WES/0.raw/cnu_skin/bam.list > cnu.skin.part3.list
sed -n '359,487p' /ichrogene/project/temp/gylee/1.WES/0.raw/cnu_skin/bam.list > cnu.skin.part4.list
sed -n '488,616p' /ichrogene/project/temp/gylee/1.WES/0.raw/cnu_skin/bam.list > cnu.skin.part5.list
sed -n '617,745p' /ichrogene/project/temp/gylee/1.WES/0.raw/cnu_skin/bam.list > cnu.skin.part6.list
sed -n '746,874p' /ichrogene/project/temp/gylee/1.WES/0.raw/cnu_skin/bam.list > cnu.skin.part7.list
sed -n '875,1004p' /ichrogene/project/temp/gylee/1.WES/0.raw/cnu_skin/bam.list > cnu.skin.part8.list

for A in $(seq 2 8)
do
cp cnu.skin.part1.sh cnu.skin.part${A}.sh
sed -i "s/part1/part${A}/g" cnu.skin.part${A}.sh
done

