#!/bin/bash
#
#	This program gets info about a given hwg_ste device.
#
#    Copyright (C) 2010  Erdal Mutlu
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
#################################################################################
if test $# -lt 1 ; then
	echo "Usage  : $0 device_ip[device_name] [snmp_community_name snmp_version]"
	echo "Example: $0 system1.example.org"
	echo "Example: $0 system1.example.org public 2c"
	echo "Default value for snmp_community_name is public."
	echo "Default value for snmp_version is 2c. Possible versions: 1, 2c and 3 "
	exit 1
fi

#################################################################################
#HWg-STE SNMP OID description
#-------------------------------------------------------------------------
#
#System Values:
#----------------------------------------------------
#.1.3.6.1.2.1.1.1.0             System Description   (string)
#.1.3.6.1.2.1.1.2.0             System ObjectID      (objid)
#.1.3.6.1.2.1.1.3.0             System UpTime        (timeticks)
#.1.3.6.1.2.1.1.4.0             System Contact       (string)
#.1.3.6.1.2.1.1.5.0             System Name          (string)
#.1.3.6.1.2.1.1.6.0             System Location      (string)
#.1.3.6.1.2.1.1.7.0             System Services      (integer)
#.1.3.6.1.4.1.21796.4.1.70.1.0  System MAC address   (string)
#
#Sensors Values, (n = 1..x)
#----------------------------------------------------
#.1.3.6.1.4.1.21796.4.1.3.1.1.n Sensor Index         (integer,  NUM  (1..x))
#.1.3.6.1.4.1.21796.4.1.3.1.2.n Sensor Name          (string,   SIZE (0..16))
#.1.3.6.1.4.1.21796.4.1.3.1.3.n Sensor State         (integer,  0=Invalid, 1=Normal, 2=OutOfRangeLo, 3=OutOfRangeHi, 4=AlarmLo, 5=AlarmHi)
#.1.3.6.1.4.1.21796.4.1.3.1.4.n Sensor String Value  (string,   SIZE (0..10))
#.1.3.6.1.4.1.21796.4.1.3.1.5.n Sensor Value         (integer,  current value *10)
#.1.3.6.1.4.1.21796.4.1.3.1.6.n Sensor SN            (string,   SIZE (0..16))
#.1.3.6.1.4.1.21796.4.1.3.1.7.n Sensor Unit          (integer,  0=unknown, 1=°C, 2=°F, 3=°K, 4=%)
#.1.3.6.1.4.1.21796.4.1.3.1.8.n Sensor ID            (integer,  NUM	(0..x))
#################################################################################
snmpget_prog=snmpget
snmpwalk_prog=snmpwalk

system=$1
snmp_community="public"
snmp_version="2c"

### get system info
sys_name=`$snmpwalk_prog -c $snmp_community -v $snmp_version $system system.sysDescr | sed -e "s/: /:/g" | cut -d ":" -f 4`
sys_location=`$snmpwalk_prog -c $snmp_community -v $snmp_version $system system.sysLocation | sed -e "s/: /:/g" | cut -d ":" -f 4`
sys_contact=`$snmpwalk_prog -c $snmp_community -v $snmp_version $system system.sysContact | cut -d "=" -f 2 | sed -e "s/ STRING://"`
sys_objectid=`$snmpwalk_prog -c $snmp_community -v $snmp_version $system "1.3.6.1.2.1.1.2.0" | sed -e "s/= /=/g" | cut -d "=" -f 2 | sed -e "s/OID: //"`

### get sensor count
### starting from 1
sensor_index_id="3.1.1"
sensor_name_id="3.1.2"
### 0=Invalid, 1=Normal, 2=OutOfRangeLo, 3=OutOfRangeHi, 4=AlarmLo, 5=AlarmHi
sensor_state_id="3.1.3"
sensor_string_value_id="3.1.4"
### current value * 10
sensor_value_id="3.1.5"
sensor_sn_id="3.1.6"
### 0=unknown, 1=°C, 2=°F, 3=°K, 4=%
sensor_unit_id="3.1.7"
sensor_id_id="3.1.8"
sensor_mac_id="70.1.0"

sensor_count=`$snmpwalk_prog -c $snmp_community -v $snmp_version $system "${sys_objectid}.${sensor_index_id}" | wc -l`

echo "sys_name=[$sys_name] sys_location=[$sys_location] sys_objectid=[$sys_objectid] sensor_count=[$sensor_count] sys_contact=[$sys_contact]"

### get sensor info
declare -i i
i=1
while test $i -le $sensor_count
do
	sensor_state=`$snmpwalk_prog -c $snmp_community -v $snmp_version $system "${sys_objectid}.${sensor_state_id}.$i" | sed -e "s/: /:/g" | cut -d ":" -f 4`
	case $sensor_state in
		0) sensor_state_desc="Invalid" ;;
		1) sensor_state_desc="Normal" ;;
		2) sensor_state_desc="OutOfRangeLo" ;;
		3) sensor_state_desc="OutOfRangeHi" ;;
		4) sensor_state_desc="AlarmLo" ;;
		5) sensor_state_desc="AlarmHi" ;;
		*) sensor_state_desc="Unknown" ;;
	esac		
	if test $sensor_state -ne 0 ; then
		sensor_name=`$snmpwalk_prog -c $snmp_community -v $snmp_version $system "${sys_objectid}.${sensor_name_id}.$i" | sed -e "s/: /:/g" | tr -d "\"" | cut -d ":" -f 4`
		sensor_value=`$snmpwalk_prog -c $snmp_community -v $snmp_version $system "${sys_objectid}.${sensor_value_id}.$i" | sed -e "s/: /:/g" | tr -d "\"" | cut -d ":" -f 4`
		sensor_string_value=`$snmpwalk_prog -c $snmp_community -v $snmp_version $system "${sys_objectid}.${sensor_string_value_id}.$i" | sed -e "s/: /:/g" | tr -d "\"" | cut -d ":" -f 4`
		sensor_unit=`$snmpwalk_prog -c $snmp_community -v $snmp_version $system "${sys_objectid}.${sensor_unit_id}.$i" | sed -e "s/: /:/g" | tr -d "\"" | cut -d ":" -f 4`
		sensor_sn=`$snmpwalk_prog -c $snmp_community -v $snmp_version $system "${sys_objectid}.${sensor_sn_id}.$i" | sed -e "s/: /:/g" | tr -d "\"" | cut -d ":" -f 4`
		sensor_id=`$snmpwalk_prog -c $snmp_community -v $snmp_version $system "${sys_objectid}.${sensor_id_id}.$i" | sed -e "s/: /:/g" | tr -d "\"" | cut -d ":" -f 4`
		case $sensor_unit in
			0) sensor_unit_desc="unknown" ;;
			1) sensor_unit_desc="Celsius" ;;
			2) sensor_unit_desc="Fahrenheit" ;;
			3) sensor_unit_desc="Kelvin" ;;
			4) sensor_unit_desc="%" ;;
			*) sensor_unit_desc="Unknown" ;;
		esac
		echo "sensor=$i sensor_state=[$sensor_state] sensor_state_desc=[$sensor_state_desc] sensor_name=[$sensor_name] sensor_value=[$sensor_value] sensor_string_value=[$sensor_string_value] sensor_unit=[$sensor_unit] sensor_unit_desc=[$sensor_unit_desc] sensor_sn=[$sensor_sn] sensor_id=[$sensor_id]"
	else
		echo "sensor=$i sensor_state=[$sensor_state] sensor_state_desc=[$sensor_state_desc]"
	fi
	i=i+1
done
