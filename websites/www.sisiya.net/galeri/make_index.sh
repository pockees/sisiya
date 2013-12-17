#!/bin/sh

pwd_str=`pwd`
index_file="${pwd_str}/index.html"
#if [ -f $index_file ]; then
# echo "Making copy of the old $file ..."
# mv -v $index_file $index_file.old.$$
#fi

declare -i i

i=1

inc_file="screenshots.inc"
> $inc_file


for file in *.png
do
	echo -n "<a href="galeri/$file"><img src=\"galeri/"		>> $inc_file
	echo -n "$file"					>> $inc_file
	echo -n '" width="250" height="150" alt="'	>> $inc_file
	echo -n "$file"					>> $inc_file
	echo =n '" /></a>'				>> $inc_file  
	i=i+1
	if test $i -gt 4 ; then
		echo '<br /><br />'     >> $inc_file
		i=1
	fi
done

> $index_file
echo -n '<HTML><HEAD><TITLE>SisIYA</TITLE></HEAD><BODY BGCOLOR="WHITE">'            >> $index_file
cat $inc_file | sed -e "s/galeri\///g" >> $index_file
echo '</BODY></HTML>' >> $index_file
