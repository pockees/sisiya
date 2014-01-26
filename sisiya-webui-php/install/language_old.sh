#!/bin/bash

#echo "insert into languages values(0,'en','English','utf-8');"
#echo "insert into languages values(1,'tr','Turkish','utf-8');"

### number of languages
nlang=3
declare -i i=1 j k
cat language.txt | while read line
do
	s1=`echo $line | cut -d "~" -f 2`
	s2=`echo $line | cut -d "~" -f 4`
	echo "insert into strkeys values($i,'$s1','$s2');"
	j=1
	k=0
	while test $j -le $nlang
	do
		n=`echo "4 + $j * 2" | bc`
		s=`echo $line | cut -d "~" -f $n`
		#echo " j=$j n=$n k=$k"
		if test "$s" == "" ; then
			j=j+1
			continue
		fi
		echo "insert into interface values($k,$i,'$s');"
		j=j+1
		k=k+1
	done
	i=i+1

done
