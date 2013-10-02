#!/bin/bash
#
#    Copyright (C) 2003  Erdal Mutlu
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#
#######################################################################################
### Echoes a integer value. If the value is less than 10, then it echo a 0 in front of the value.
echo_value()
{
	str=${1:0:1}
	if test "$str" = "0" ; then
		if test $1 -eq 0 ; then
			echo "00"
		else
			echo $1
		fi
		return
	fi
	if test $1 -lt 10 ; then
		echo "0$1"
	else
		echo $1
	fi
}

### Echoes a string formed of day,hour,minute
echo_datetime()
{
	d=$1
	h=$2
	m=$3
	str=""
	if test $d -ne 0 ; then
		str="$d day"
		if test $d -ne 1 ; then
			str="${str}s"
		fi
	fi
	if test $h -ne 0 ; then
		if test -z "$str" ; then
			str="$h hour"
		else
			str="$str $h hour"
		fi
		if test $h -ne 1 ; then
			str="${str}s"
		fi
	fi
	if test $m -ne 0 ; then
		if test -z "$str" ; then
			str="$m minute"
		else
			str="$str $m minute" 
		fi
		if test $m -ne 1 ; then
			str="${str}s"
		fi
	fi
	echo $str
}


### Echos seconds in the form of days,hours,minutes and seconds
function echo_seconds_to_time_str()
{
	seconds=$1

	s=$seconds	
	minutes=0
	hours=0
	days=`echo "$seconds / 86400" | bc`
	if test $days -gt 0 ; then
		s=`echo "$s - $days * 86400" | bc`
		hours=`echo "$s / 3600" | bc`
		if test $hours -gt 0 ; then
			s=`echo "$s - $hours * 3600" | bc`
			minutes=`echo "$s / 60" | bc`
			if test $minutes -gt 0 ; then
				s=`echo "$s - $minutes * 60" | bc`
			fi
		else
			minutes=`echo "$s / 60" | bc`
			if test $minutes -gt 0 ; then
				s=`echo "$s - $minutes * 60" | bc`
			fi
		fi
	else
		hours=`echo "$s / 3600" | bc`
		if test $hours -gt 0 ; then
			s=`echo "$s - $hours * 3600" | bc`
			minutes=`echo "$s / 60" | bc`
			if test $minutes -gt 0 ; then
				s=`echo "$s - $minutes * 60" | bc`
			fi
		else
			minutes=`echo "$s / 60" | bc`
			if test $minutes -gt 0 ; then
				s=`echo "$s - $minutes * 60" | bc`
			fi
		fi

	fi
	#echo "s=$s"
	#echo "minutes=$minutes"
	#echo "hours=$hours"
	#echo "days=$days"
	#echo "days=$days hours=$hours minutes=$minutes seconds=$s"
	str=""
	if test $days -gt 0 ; then
		str="$days day"
		if test $days -gt 1 ; then
			str="${str}s"
		fi
	fi
	if test $hours -gt 0 ; then
		str="$str $hours hour"
		if test $hours -gt 1 ; then
			str="${str}s"
		fi
	fi
	if test $minutes -gt 0 ; then
		str="$str $minutes minute"
		if test $minutes -gt 1 ; then
			str="${str}s"
		fi
	fi
	if test $s -gt 0 ; then
		str="$str $s second"
		if test $s -gt 1 ; then
			str="${str}s"
		fi
	fi
	echo $str
}


### Extracts and echoes days, hours and minutes
### The format of the argumnet is
### 1) If the value is a number, then it is the number of days.
### 2) If the value is of the form hh:mm, then it is hh hours mm minutes.
### 3) If the value is of the form d:hh:mm, then it is d days hh hours mm minutes.
###   3:12pm  up 18:55,  1 user,  load average: 0.01, 0.03, 0.04
extract_datetime()
{
	days=0
	hours=0
	minutes=0
	str=$1
	count=`echo $str | tr -s ":" "\n" | wc -l`
	if test $count -eq 1 ; then
		days=$str
	elif test $count -eq 2 ; then
		hours=`echo $str 	| cut -d ":" -f 1`
		minutes=`echo $str 	| cut -d ":" -f 2`
	else
		days=`echo $str 	| cut -d ":" -f 1`
		hours=`echo $str 	| cut -d ":" -f 2`
		minutes=`echo $str 	| cut -d ":" -f 3`
	fi

	if test $minutes -ge 60 ; then
		t=`(echo "$minutes / 60") | bc`
		minutes=`(echo "$minutes - $t * 60") | bc`
		hours=`(echo "$hours + $t") | bc`
	fi
	if test $hours -ge 24 ; then
		t=`(echo "$hours / 24") | bc`
		hours=`(echo "$hours - $t * 24") | bc`
		days=`(echo "$days + $t") | bc`
	fi
	#echo "$days $hours $minutes" 1>&2
	echo "$days $hours $minutes"
}

### Extract etime (elapsed time from the ps command) in days, hours and minutes
extract_etime()
{
	str=`echo $1 | grep "-"`
	if test -z "$str" ; then
		edays=0
		count=`echo $1 | tr -s ":" "\n" | wc -l`
		if test $count -eq 2 ; then
			ehours=0
			eminutes=`echo $1	| awk -F: '{print $1}'`
		else
			ehours=`echo $1		| awk -F: '{print $1}'`
			eminutes=`echo $1	| awk -F: '{print $2}'`
		fi
	else
		edays=`echo $1		| awk -F- '{print $1}'`
		str=`echo $1		| awk -F- '{print $2}'`
		ehours=`echo $str	| awk -F: '{print $1}'`
		eminutes=`echo $str	| awk -F: '{print $2}'`
	fi
	first_digit=${ehours:0:1}
	if test $first_digit -eq 0 && test $ehours -ne 0; then
		ehours=${ehours:1:1}
	fi
	first_digit=${eminutes:0:1}
	if test $first_digit -eq 0 && test $eminutes -ne 0; then
		eminutes=${eminutes:1:1}
	fi

	echo "$edays $ehours $eminutes"
}

### Get uptime in days, hours and minutes
get_uptime()
{
	uptime_str=`uptime`
	###uptime_str="$1"
	str=`echo $uptime_str | grep day`
	str2=`echo $uptime_str | awk '{print $3}'`
	str3=`echo $str2 |awk -F, '{print $1}'`
	###echo "str=[$str] str2=[$str2] str3=[$str3]" 1>&2
	if test -n "$str3" ; then
		str2=$str3
	fi
	###echo "str2=[$str2]" 1>&2
	if test -z "$str" ; then
		up_days=0
		str=`echo $uptime_str | awk -F, '{print $1}' | awk -Fp '{print $2}' | grep ":"`
		###echo "in if str=[$str]" 1>&2
		if test -z "$str" ; then
			up_hours=0
			up_minutes=`echo $uptime_str | awk -F, '{print $1}' | awk -Fp '{print $2}' | awk '{print $1}'`
			if test "$up_minutes" = "m" ; then
				up_minutes=`echo $uptime_str | awk -F, '{print $1}' | awk '{print $3}'`
				str=`echo $up_minutes | grep ":"`
				if test -n "$str" ; then
					up_hours=`echo $up_minutes	| awk -F: '{print $1}'`
					up_minutes=`echo $up_minutes	| awk -F: '{print $2}'`
				fi
			fi
		else
			up_hours=`echo $str | awk -F: '{print $1}'`
			up_minutes=`echo $str | awk -F: '{print $2}'`
		fi
	else
		up_days=$str2
		time_str=`echo $str             | awk -F, '{print $2}'`
		str=`echo $time_str | grep ":"`
		###echo "else time_str=[$time_str] str=[$str]" 1>&2
		if test -z "$str" ; then
			str=`echo $time_str | grep "min"`
			if test -z "$str" ; then
				up_hours=`echo $time_str        | awk '{print $1}'`
				up_minutes=0
			else
				up_hours=0
				up_minutes=`echo $time_str        | awk '{print $1}'`
			fi
		else
			up_hours=`echo $time_str        | awk -F: '{print $1}'`
			up_minutes=`echo $time_str      | awk -F: '{print $2}'`
		fi
	fi
	echo "$up_days $up_hours $up_minutes"
}
### 
print_formated_size()
{
	result=`(echo "$1 / $2") | bc`
	rest=`(echo "($1 % $2)") | bc`
	rest=`(echo "scale=2; $rest / $2") | bc`
	if test "$rest" = "0" || test "$rest" = "0.00" ; then
		echo "${result}$3" 
	else
		echo "${result}${rest}$3" 
	fi
}

### Usage : str=`print_size_k 153` the argument is given in KB
print_size_k()
{
	if test $1 -eq 0 ; then
		echo "0"
	elif test $1 -lt 1024 ; then
		echo "${1}KB"
	elif test $1 -lt 1048576 ; then
		print_formated_size $1 1024 MB
	elif test $1 -lt 1073741824 ; then
		print_formated_size $1 1048576 GB
	elif test $1 -lt 1099511627776 ; then
		print_formated_size $1 1073741824 TB
	elif test $1 -lt 1125899906842624 ; then
		print_formated_size $1 1099511627776 PB
	elif test $1 -lt 1152921504606846976 ; then
		print_formated_size $1 1125899906842624 EB
	else
		print_formated_size $1 1125899906842624 EB
	fi
}
### This function expects time in yyyymmddhhmm.
### Return values: 1 expired, 0 not expired
is_expired()
{
	time_str=$1
	year=${time_str:0:4}
	month=${time_str:4:2}
	day=${time_str:6:2}
	hour=${time_str:8:2}
	min=${time_str:10:2}
	#echo "$day.$month.$year $hour:$min:$sec"
	### for now
	time_str=`date '+%Y%m%d%H%M'`
	now_year=${time_str:0:4}
	now_month=${time_str:4:2}
	now_day=${time_str:6:2}
	now_hour=${time_str:8:2}
	now_min=${time_str:10:2}
	max_diff=$2
	time_str=`(echo "$hour * 60 + $min")|bc`
	now_time_str=`(echo "$now_hour * 60 + $now_min")|bc`
	date_str="$year$month$day"
	now_date_str="$now_year$now_month$now_day"
	date_in_seconds=`date -d $date_str '+%s'`
	now_date_in_seconds=`date -d $now_date_str '+%s'`
	diff1=`(echo "($now_date_in_seconds - $date_in_seconds) /  60") | bc`
	diff2=`(echo "$now_time_str - $time_str") | bc`
	total_diff=`(echo "$diff1 + $diff2") | bc`
	if test $total_diff -gt $max_diff ; then
		echo 1
	else
		echo 0
	fi 
}


### Echoes a date format used in the SisIYA message.
echo_sisiya_date()
{
	#echo `date '+%Y-%m-%d %H:%M:%S'`
	echo `date '+%Y%m%d%H%M%S'`
}

### Creates a temp file
maketemp()
{
        case "$sisiya_osname" in
		"AIX")
			str=$1
			touch $str
		;;
		"HP-UX")
                	str=`mktemp -c $1`
		;;
        	*)
                	str=`mktemp $1`
		;;
	esac
        echo $str
}

