#!/bin/sh

if test $# -ne 2 ; then
	echo "Usage : $0 header.template footer.template"
	exit 1
fi

header_file=$1
footer_file=$2
for f in $header_file $footer_file
do
	if test ! -f $f ; then
		echo "File : $f does not exist."
		exit 1
	fi
done

for file in sisiya_*.template
do
	echo $file
	file=${file%.*}
	if test -f ${file}.sh ;then
		echo "File : ${file}.sh exists. Removing..."
		echo "rm -f ${file}.sh"
	fi
	if test -f "${file}.header" ; then
		cat ${file}.header >  ${file}.sh
	else
		cat $header_file >  ${file}.sh
	fi
	cat ${file}.template  >> ${file}.sh
	if test -f "${file}.footer" ; then
		cat ${file}.footer >>  ${file}.sh
	else
		cat $footer_file >> ${file}.sh
	fi
	chmod 700 ${file}.sh
done
