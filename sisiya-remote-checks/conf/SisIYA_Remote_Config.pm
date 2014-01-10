#!/usr/bin/perl -w
#
#
## This file is the config for SisIYA remote check programs.
##
##    Copyright (C) Erdal Mutlu
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

package SisIYA_Remote_Config;

##################################################################################
#### PLEASE DO NOT EDIT THIS FILE! EDIT THE SisIYA_Remote_local.pl ###############
##################################################################################


our $client_conf 		= '/opt/sisiya-client-checks/SisIYA_Config.pm';
our $client_local_conf	 	= '/opt/sisiya-client-checks/SisIYA_Config_local.pl';
our $base_dir		 	= '/opt/sisiya-remote-checks';
our $conf_dir 			= "$base_dir/conf";
our $lib_dir			= "$base_dir/lib";
our $local_conf			= "$conf_dir/SisIYA_Remote_Config_local.pl";
our $misc_dir 			= "$base_dir/misc";
our $scripts_dir	 	= "$base_dir/scripts";
our $utils_dir	 		= "$base_dir/utils";
our $functions	 		= "$utils_dir/sisiya_functions.pl";

our %external_progs = (
		'bash'		=> '/bin/bash',
		'dig'		=> '/usr/bin/dig',
		'curl'		=> '/usr/bin/curl',
		'java'		=> '/usr/bin/java',
		'perl'		=> '/usr/bin/perl',
		'ping'		=> '/bin/ping',
		'snmpget'	=> '/usr/bin/snmpget',
		'snmpwalk'	=> '/usr/bin/snmpwalk',
		'smbclient'	=> '/usr/bin/smbclient',
		'wget'		=> '/usr/bin/wget',
		'vicfg-hostops'	=> '/usr/bin/vicfg-hostops'
	);
# the XML configuration files are located in the conf_dir
our %checks = (
		'dbs' 		=> { 'auto' => 1, 'conf' => 'dbs_systems.xml', 		'script' => 'sisiya_check_dbs.pl' 		},
		'dns' 		=> { 'auto' => 1, 'conf' => 'dns_systems.xml', 		'script' => 'sisiya_check_dns.pl' 		},
		'ftp'		=> { 'auto' => 1, 'conf' => 'ftp_systems.xml', 		'script' => 'sisiya_check_ftp.pl' 		},
		'hpilo2'	=> { 'auto' => 1, 'conf' => 'hpilo2_systems.xml',	'script' => 'sisiya_check_hpilo2.pl' 		},
		'http'		=> { 'auto' => 1, 'conf' => 'http_systems.xml',		'script' => 'sisiya_check_http.pl' 		},
		'https'		=> { 'auto' => 1, 'conf' => 'https_systems.xml',	'script' => 'sisiya_check_https.pl' 		},
		'imap'		=> { 'auto' => 1, 'conf' => 'imap_systems.xml',		'script' => 'sisiya_check_imap.pl' 		},
		'ping'		=> { 'auto' => 1, 'conf' => 'ping_systems.xml',		'script' => 'sisiya_check_ping.pl' 		},
		'pop3'		=> { 'auto' => 1, 'conf' => 'pop3_systems.xml',		'script' => 'sisiya_check_pop3.pl' 		},
		'printer'	=> { 'auto' => 1, 'conf' => 'printer_systems.xml',	'script' => 'sisiya_check_printer.pl' 		},
		'qnap'		=> { 'auto' => 1, 'conf' => 'qnap_systems.xml',		'script' => 'sisiya_check_qnap.pl' 		},
		'sensor'	=> { 'auto' => 1, 'conf' => 'sensor_systems.xml',	'script' => 'sisiya_check_sensor.pl' 		},
		'smb'		=> { 'auto' => 1, 'conf' => 'smb_systems.xml',		'script' => 'sisiya_check_smb.pl' 		},
		'smtp'		=> { 'auto' => 1, 'conf' => 'smtp_systems.xml',		'script' => 'sisiya_check_smtp.pl' 		},
		'ssh'		=> { 'auto' => 1, 'conf' => 'ssh_systems.xml',		'script' => 'sisiya_check_ssh.pl' 		},
		'switch'	=> { 'auto' => 1, 'conf' => 'switch_systems.xml',	'script' => 'sisiya_check_switch.pl' 		},
		'telekutu'	=> { 'auto' => 1, 'conf' => 'telekutu_systems.xml',	'script' => 'sisiya_check_telekutu.pl'	 	},
		'telnet'	=> { 'auto' => 1, 'conf' => 'telnet_systems.xml',	'script' => 'sisiya_check_telnet.pl' 		},
		'ups_cs121'	=> { 'auto' => 1, 'conf' => 'ups_cs121_systems.xml',	'script' => 'sisiya_check_ups_cs121.pl' 	},
		'ups_netagent'	=> { 'auto' => 1, 'conf' => 'ups_netagent_systems.xml',	'script' => 'sisiya_check_ups_netagent.pl' 	},
		'ups'		=> { 'auto' => 1, 'conf' => 'ups_systems.xml',		'script' => 'sisiya_check_ups.pl' 		},
		'vmware'	=> { 'auto' => 1, 'conf' => 'vmware_systems.xml',	'script' => 'sisiya_check_vmware.pl' 		}
	);
# Environment variables
our %env = (
	'CLASSPATH'	=> "$conf_dir:$lib_dir:/opt/java/jre:/usr/lib/jdbc/mysql-connector-java-3.1.11-bin.jar:/usr/lib/jdbc/pg74.216.jdbc2.jar:/usr/lib/jdbc/ojdbc14.jar:/usr/lib/jdbc/jtds-1.3.1.jar"
);
1;
