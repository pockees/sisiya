#!/usr/bin/perl -w
#
#    Copyright (C) Erdal Mutlu
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
#######################################################################################
#BEGIN {push @INC, '..'}
## or run : perl -I..
use strict;
use warnings;
use SisIYA_Config;

if(-f $SisIYA_Config::sisiya_local_conf) {
	require $SisIYA_Config::sisiya_local_conf;
}
if(-f $SisIYA_Config::sisiya_functions) {
	require $SisIYA_Config::sisiya_functions;
}
#######################################################################################
###############################################################################
#### the default values
our $hpasmcli_prog = '/sbin/hpasmcli';
#### end of the default values
################################################################################
## override defaults if there is a corresponfing conf file
my $module_conf_file = "$SisIYA_Config::sisiya_systems_conf_dir/".`basename $0`;
chomp($module_conf_file);
if(-f $module_conf_file) {
	require $module_conf_file;
}
################################################################################
my $message_str = '';
my $statusid = $SisIYA_Config::statusids{'ok'};
my $service_name = 'fanspeed';
my $error_str = '';
my $info_str = '';
my $ok_str = '';
my $warning_str = '';

################################################################################
my @a = `$hpasmcli_prog -s "show fans"`;
my $retcode = $? >>=8;
if($retcode == 0) {
	@a = grep(/#/, @a);
	chomp(@a = @a);
	my ($is_available, $fan_name, $fan_number, $fan_speed_status, $fan_value);
       	foreach(@a) {
		$is_available = (split(/\s+/, $_))[2];
		#print STDERR "[$is_available]\n";
		if($is_available eq 'Yes') {
			$fan_name = (split(/\s+/, $_))[1];
			$fan_number = (split(/\s+/, $_))[0];
			$fan_speed_status = (split(/\s+/, $_))[3];
			$fan_value = (split(/%/, (split(/\s+/, $_))[4]))[0];
			if($fan_speed_status eq 'NORMAL') {
				$ok_str .= "OK: The speed of the $fan_number $fan_name fan is $fan_value%.";
			}
			else {
				$error_str .= "ERROR: The speed of the $fan_number $fan_name fan is $fan_value% and $fan_speed_status != NORMAL!";
			}
		}
	}	

}

if($error_str ne '') {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = "$error_str";
}
if($warning_str ne '') {
	if($statusid < $SisIYA_Config::statusids{'warning'}) {
		$statusid = $SisIYA_Config::statusids{'warning'};
	}	
	$message_str .= "$warning_str";
}
if($ok_str ne '') {
	$message_str .= "$ok_str";
}
if($info_str ne '') {
	$message_str .= "$info_str";
}
################################################################################
sisiya_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str);
################################################################################
#hpasmcli -s "show powermeter"
#
#Power Meter #1
#        Power Reading  : 284
################################################################################
### Sample output of the hpasmcli -s "show fans" command :
#	  Fan  Location        Present Speed  of max  Redundant  Partner  Hot-pluggable
#	---  --------        ------- -----  ------  ---------  -------  -------------
#	#1   I/O_ZONE        Yes     NORMAL  45%     Yes        0        Yes
#	#2   I/O_ZONE        Yes     NORMAL  45%     Yes        0        Yes
#	#3   PROCESSOR_ZONE  Yes     NORMAL  41%     Yes        0        Yes
#	#4   PROCESSOR_ZONE  Yes     NORMAL  36%     Yes        0        Yes
#	#5   PROCESSOR_ZONE  Yes     NORMAL  36%     Yes        0        Yes
#	#6   PROCESSOR_ZONE  Yes     NORMAL  36%     Yes        0        Yes
#
##############################################################################################
### or another sample output with some fans which are not present
##############################################################################################
#	Fan  Location        Present Speed  of max  Redundant  Partner  Hot-pluggable
#	---  --------        ------- -----  ------  ---------  -------  -------------
#	#1   SYSTEM          Yes     NORMAL  35%     No         N/A      No
#	#2   SYSTEM          No      -       N/A     No         N/A      No
#	#3   SYSTEM          Yes     NORMAL  35%     No         N/A      No
#	#4   SYSTEM          No      -       N/A     No         N/A      No
#	#5   CPU#1           Yes     NORMAL  35%     N/A        N/A      No
#	#6   CPU#2           No      -       N/A     N/A        N/A      No
##############################################################################################
