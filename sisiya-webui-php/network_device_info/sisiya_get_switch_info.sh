#!/bin/sh
#
#    Copyright (C) 2003 - __YEAR__  Erdal Mutlu
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
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
#
#
#################################################################################
if test $# -ne 2 ; then
	echo "Usage : $0 switch_systems.conf host_info"
	echo "host_info file has records of the form: hostaname ip mac"
	exit 1
fi

file=$1
host_info_file=$2

sisiya_db="sisiya_new"
db_user="sisiyauser"
db_password="sisiyauser1"

mysql_server="localhost"

print_mac()
{
	s_str="SNMPv2-SMI::mib-2.17.4.3.1.2.0"
	count=`snmpwalk -v 2c $switch -c $comm_name $s_str| grep -G ".*INTEGER: $port\$" | wc  -l`
	#echo "Count=$count"
	if test "$count" = "1" ; then
		str=`snmpwalk -v 2c $switch -c $comm_name $s_str| grep -G ".*INTEGER: $port\$"`
	
		g_port=`echo $str | cut -d ":" -f 4 | cut -d " " -f 2 `
		#echo "g_port=[$g_port]"
		#echo "str=[$str]"
		length=${#s_str}
		total_length=${#str}
		diff_length=`(echo "$total_length - $length - 1")|bc`
		#echo "diff_length=$diff_length"
		start=`(echo "$length + 1") | bc`
		nchars=`(echo "$total_length - $length - 1") | bc`
		#echo "start=$start nchars=$nchars"
		rest_s_str=${str:$start:$nchars}
		rest_s_str=`echo $rest_s_str | cut -d "=" -f 1`
		#echo "totoal_length=$total_length length=$length"
		#echo "rest_s_str=[$rest_s_str]"
		s_str="SNMPv2-SMI::mib-2.17.4.3.1.1.0.$rest_s_str"
		str=`snmpwalk -v 2c $switch -c $comm_name $s_str`
		mac_str=`echo $str|cut -d ":" -f 4`
		#echo "str=$str"
		#echo "MAC=$mac_str"
		m1=`echo $mac_str | cut -d " " -f 1`
		m2=`echo $mac_str | cut -d " " -f 2`
		m3=`echo $mac_str | cut -d " " -f 3`
		m4=`echo $mac_str | cut -d " " -f 4`
		m5=`echo $mac_str | cut -d " " -f 5`
		m6=`echo $mac_str | cut -d " " -f 6`
		echo "${m1}:${m2}:${m3}:${m4}:${m5}:${m6}"
	else
		echo "UPLINK ($count)"
	fi
}

insert_or_update_systeminfo()
{
	switchid=$1
	info_id=$2
	language_id=$3
	str=$4
	mysql -h $mysql_server  -u $db_user -p$db_password $sisiya_db -e "insert into systeminfo values($switchid,$info_id,$language_id,'$str');" 2>/dev/null
	if test $? -ne 0 ; then
		mysql -h $mysql_server  -u $db_user -p$db_password $sisiya_db -e "update systeminfo set str='$str' where systemid=$switchid and infoid=$info_id and languageid=$language_id;"
	fi
}

for f in $file $host_info_file
do
	if test ! -f $f ; then
		echo "File $f dows not exist! Exiting..."
		exit 1
	fi
done

cat $file | grep -v "#" | while read -r line
do
	s="~"
	switchid=`echo $line 	| awk '{print $1}'`
	switch=`echo $line 	| awk '{print $2}'`
	comm_name=`echo $line 	| awk '{print $3}'`
	str=`snmpwalk -v 2c $switch -c $comm_name IF-MIB::ifNumber.0 | cut -d: -f 4`
	ports=`(echo $str -2) | bc`
	location=`snmpwalk -v 2c $switch -c $comm_name system.sysLocation	| sed -e "s/: /:/g" | cut -d ":" -f 4`
	description=`snmpwalk -v 2c $switch -c $comm_name system.sysDescr	| sed -e "s/: /:/g" | cut -d ":" -f 4`
	contact=`snmpwalk -v 2c $switch -c $comm_name system.sysContact		| sed -e "s/: /:/g" | cut -d ":" -f 4`
	echo "<switch>";
	echo "<name>$switch</name>";
	echo "<ip>$ip</ip>";
	echo "<description>$description</description>";
	echo "<location>$location</location>";
	echo "<contact>$contact</contact>";
	echo "<ports>$ports</ports>";

	language_id=1

	# insert or update systeminfo for contact info
	info_id=23
	str=$contact
	insert_or_update_systeminfo $switchid $info_id $language_id "$str"

	# insert or update systeminfo for location info
	info_id=24
	str=$location
	insert_or_update_systeminfo $switchid $info_id $language_id "$str"



	# insert or update systeminfo for the number of ports
	info_id=22
	str=$ports
	insert_or_update_systeminfo $switchid $info_id $language_id "$str"


	# insert or update systeminfo for description
	info_id=1
	str=$description
	insert_or_update_systeminfo $switchid $info_id $language_id "$str"



	mysql -h $mysql_server  -u $db_user -p$db_password $sisiya_db -e "delete from systemswitch where switchid=$switchid"
	declare -i port=1
	vlan=1
	while test $port -le $ports
	do
		str=`snmpwalk -v 2c $switch -c $comm_name IF-MIB::ifOperStatus.$port | cut -d: -f 4|grep -i up`
		if test -n "$str" ; then
			status_flag="t"
			#speed=`snmpwalk -v 2c $switch -c $comm_name IF-MIB::ifHighSpeed.$port | cut -d ":" -f 4`
			speed=`snmpwalk -v 2c $switch -c $comm_name IF-MIB::ifSpeed.$port | cut -d ":" -f 4`
			# get this from the switch
			duplex="t"
	
			#echo "$port${s}$speed"

			mac_str=`print_mac`
			str=`grep -i "$mac_str" $host_info_file`
			if test -n "$str" ; then
				isknown="t"
				isuplink="f"
				system_id=`echo $str	| awk '{print $1}'` 
				system_name=`echo $str	| awk '{print $2}'` 
				system_ip=`echo $str	| awk '{print $3}'` 
				system_mac=`echo $str	| awk '{print $4}'` 
				sql_str="insert into systemswitch value($switchid,$port,'$status_flag','$isknown','$isuplink',$system_id,'$speed','$duplex',$vlan);"
				echo "Port $port is up. $system_name $system_ip $system_mac"
				echo "sql_str=$sql_str"
				
			else
				# unknown system
				system_id=$switchid
				isknown="f"
				isuplink="f"
				str=`echo $mac_str | grep "UPLINK"`
				if test -n "$str" ; then
					isuplink="t"
				fi
				status_flag="t"
				# get this from the switch
				duplex="t"
				echo "Port $port is up. The system on this port is not known to SisIYA! mac=$mac_str"
				sql_str="insert into systemswitch value($switchid,$port,'$status_flag','$isknown','$isuplink',$system_id,'$speed','$duplex',$vlan);"
				echo "sql_str=$sql_str"
			fi
			### get the MAC address
			#snmpwalk -v 2c $switch -c $comm_name mib-2.17.4.3.1.2.0 
		else
			system_id=$switchid
			isknown="f"
			isuplink="f"
			status_flag="f"
			# get this from the switch
			duplex="f"
			echo "The port $port is down!"
			sql_str="insert into systemswitch value($switchid,$port,'$status_flag','$isknown','$isuplink',$system_id,'$speed','$duplex',$vlan);"
			echo "sql_str=$sql_str"
		fi
		mysql -h $mysql_server  -u $db_user -p$db_password $sisiya_db -e "$sql_str"
		port=port+1
	done
	echo "</switch>";
done
