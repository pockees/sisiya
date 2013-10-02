#!/bin/bash

language_file=language.txt

for language_id in "en" "tr"
do
	output_file=language_${language_id}.xml

	echo "<language>" > $output_file
	cat $language_file | while read x
	do 
		a=`echo $x	| cut -d "~" -f 2`
		if test "$language_id" = "en" ; then
			k=6
		else
			k=8
		fi
		b=`echo $x	| cut -d "~" -f $k` 
		echo "<record><strkey>$a</strkey> <value>$b</value></record>" >> $output_file
	done
	echo "</language>" >> $output_file 
done
