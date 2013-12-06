##!/usr/bin/perl -w
#
#
## This file is the config for SisIYA check programs.
##
##    Copyright (C) 2003 - 2013  Erdal Mutlu
##
##    This program is free software; you can redistribute it and/or modify
##    it under the terms of the GNU General Public License as published by
##    the Free Software Foundation; either version 2 of the License, or
##    (at your option) any later version.
##
##    This program is distributed in the hope that it will be useful,
##    but WITHOUT ANY WARRANTY; without even the implied warranty of
##    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##    GNU General Public License for more details.
##
##    You should have received a copy of the GNU General Public License
##    along with this program; if not, write to the Free Software
##    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
##
##
##################################################################################
#use strict;
#use warnings;

package SisIYA_Config;

# This switch is used for sending the check results to the SisIYA server.
# When disabled (set to 0) then the rusults are not send. This way
# you can use SisIYA only to check your system and export to the results to a XML
# file (see below the export_ variables).
our $send_to_server = 1;
### SisIYA Server's name or IP address
our $sisiya_server = '127.0.0.1';
#### SisIYA server port on which the SisIYA daemon is listenening 
our $sisiya_port = 8888;

our $sisiya_hostname;
chomp($sisiya_hostname = `hostname`);

our $sisiya_osname;
chomp($sisiya_osname = `uname -s`);

our $sisiya_osrelease;
chomp($sisiya_osrelease = `uname -r`);

# field seperator
our $FS = '~';

our $sisiya_base_dir		= '/opt/sisiya-client-checks';
our $sisiya_local_conf		= "$sisiya_base_dir/SisIYA_Config_local.pl";
our $sisiya_common_dir		= "$sisiya_base_dir/common";
our $sisiya_misc_dir 		= "$sisiya_base_dir/misc";
our $sisiya_special_dir		= "$sisiya_base_dir/special";
our $sisiya_utils_dir 		= "$sisiya_base_dir/utils";
our $sisiya_systems_dir		= "$sisiya_base_dir/systems/$sisiya_hostname";
our $sisiya_systems_conf_dir 	= "$sisiya_systems_dir/conf";
our $send_message_prog 		= "$sisiya_utils_dir/sisiya_send_message_xml.pl";
our $send_message2_prog		= "$sisiya_utils_dir/sisiya_send_message2_xml.pl";
our $sisiyac_prog 		= "$sisiya_utils_dir/sisiyac_xml.pl";
our $sisiya_functions 		= "$sisiya_utils_dir/sisiya_functions.pl";
# This option enables exporting of the check results into a XML file. 
# In order to enable this feuture set export_to_xml to 1 in the SisIYA_Config_local.pl
# and adjust the rest of export_ variables as well according to your needs.
our $export_to_xml		= 0;
our $export_xml_file		= '/tmp/sisiya-client-checks.xml';
our $export_xml_owner		= 'erdalmutlu:users';
our $export_xml_permissions	= '640';

our %statusids = (
	'info' 		=> 1,	# 2^0 
	'ok' 		=> 2,	# 2^1
	'warning' 	=> 4,	# 2^2
	'error' 	=> 8,	# 2^3
	'noreport' 	=> 16,	# 2^4
	'unavailable' 	=> 32,	# 2^5
	'mwarning' 	=> 64,	# 2^6
	'merror' 	=> 128,	# 2^7
	'mnoreport' 	=> 256,	# 2^8
	'munavailable' 	=> 512	# 2^9
);

our %serviceids = (
	'system'			=> 0,
	'filesystem'			=> 1,
	'cpu'				=> 2,
	'swap'				=> 3,
	'load'				=> 4,
	'smtp'				=> 5,
	'smb'				=> 6,
	'nmb'				=> 7,
	'postgresql'			=> 8,
	'mysql'				=> 9,
	'oracle'			=> 10,
	'imap'				=> 11,
	'pop3'				=> 12,
	'lotus'				=> 13,
	'printer'			=> 14,
	'ftp'				=> 15,
	'squid'				=> 16,
	'dns'				=> 17,
	'nfs'				=> 18,
	'dhcpd'				=> 19,
	'http'				=> 20,
	'https'				=> 21,
	'ping'				=> 22,
	'telnet'			=> 23,
	'postfix'			=> 24,
	'xinetd'			=> 25,
	'sshd'				=> 26,
	'xfs'				=> 27,
	'kdm'				=> 28,
	'portmap'			=> 29,
	'atalkd'			=> 30,
	'afpd'				=> 31,
	'papd'				=> 32,
	'ram'				=> 33,
	'nmbd'				=> 34,
	'solstice_disksuite'		=> 35,
	'rpcstatd'			=> 36,
	'rpcrquotad'			=> 37,
	'rpcmountd'			=> 38,
	'nfsd'				=> 39,
	'lockd'				=> 40,
	'rpciod'			=> 41 ,
	'slapd'				=> 42,
	'sun_cluster'			=> 43,
	'inetd'				=> 44,
	'users'				=> 45,
	'veritas_volume_manager'	=> 46,
	'netstat'			=> 47,
	'progs'				=> 48,
	'progs_count'			=> 49,
	'ssh_attack'			=> 50,
	'oracle_tablespace'		=> 51,
	'domino_webaccount'		=> 52,
	'netbackup_jobs'		=> 53,
	'netbackup_debug'		=> 54,
	'netbackup_drives'		=> 55,
	'netbackup_clients'		=> 56,
	'netbackup_library'		=> 57,
	'oracle_hitratios'		=> 58,
	'netbackup_robots'		=> 59,
	'ups_battery'			=> 60,
	'temperature'			=> 61,
	'ups_status'			=> 62,
	'ups_output'			=> 63,
	'ups_timeonbattery'		=> 64,
	'pdu_output'			=> 65,
	'battery'			=> 66,
	'netbackup_scratch'		=> 67,
	'netbackup_notify'		=> 68,
	'printer_pagecounts'		=> 69,
	'batchjob_notify'		=> 70,
	'netbackup_media'		=> 71,
	'daemon_children'		=> 72,
	'dmesg'				=> 73,
	'test'				=> 74,
	'listening_socket'		=> 75,
	'ntpstat'			=> 76,
	'ipconntrack'			=> 77,
	'mysql_table_status'		=> 78,
	'established_connections'	=> 79,
	'hddtemp'			=> 80,
	'raid'				=> 81,
	'fanspeed'			=> 82,
	'baan_jobs'			=> 83,
	'baan_warehouse'		=> 84,
	'lpstat'			=> 85,
	'smart'				=> 90,
	'mssql'				=> 91,
	'linestatus'			=> 92,
	'portstatus'			=> 93,
	'snmptrap'			=> 94,
	'softraid'			=> 95,
	'mailq'				=> 96,
	'powersupply'			=> 97,
	'vmware'			=> 98,
	'mswindows_eventlog'		=> 99,
	'isuptodate'			=> 100,
	'antivirus'			=> 101,
	'services'			=> 102,
	'brightstore_jobs'		=> 103,
	'brightstore_devices'		=> 104,
	'brightstore_scratch'		=> 105,
	'process_count'			=> 106,
	'ups_input'			=> 107,
	'msexchange_servicehealth'	=> 120,
	'msexchange_mapiconnectivity'	=> 121,
	'msexchange_mailflow'		=> 122,
	'msexchange_mailqueue'		=> 123,
	'baan_users'			=> 5000,
	'baan_edi'			=> 5001,
	'baan_message'			=> 5002,
	'baan_jobs_status'		=> 5003,
	'baan_slm'			=> 5004
);

1;
