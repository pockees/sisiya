#!/bin/bash

language_file=language.txt
output_file=language_strkeys.xml

echo "<strkeys>" > $output_file
cat $language_file | while read x
do 
	a=`echo $x | cut -d "~" -f 2`
	b=`echo $x|cut -d "~" -f 4` 
	echo "<record><strkey>$a</strkey> <definition>$b</definition></record>" >> $output_file
done
echo "</strkeys>" >> $output_file 
