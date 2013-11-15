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
my $service_name = 'temperature';
my $error_str = '';
my $info_str = '';
my $ok_str = '';
my $warning_str = '';

################################################################################
my @a = `$hpasmcli_prog -s "show temp"`;
my $retcode = $? >>=8;
if($retcode == 0) {
	chomp(@a = @a);
	my $s = "@a";
	$s =~ s/\s+/ /g;
	$info_str = "INFO: $s"; 
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
#print "listening_socket$SisIYA_Config::FS<msg>$message_str</msg><datamsg></datamsg>\n";
#exit $statusid;
sisiya_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str);
################################################################################
### Sample output of the hpasmcli -s "show temp" command :
#	Sensor   Location              Temp       Threshold
#	------   --------              ----       ---------
#	#1        I/O_ZONE             40C/104F   70C/158F
#	#2        AMBIENT              17C/62F    39C/102F
#	#3        CPU#1                30C/86F    127C/260F
#	#4        CPU#1                30C/86F    127C/260F
#	#5        POWER_SUPPLY_BAY     43C/109F   77C/170F
#	#6        CPU#2                30C/86F    127C/260F
#	#7        CPU#2                30C/86F    127C/260F
#
##########################################################################
#	Sensor   Location              Temp       Threshold
#	------   --------              ----       ---------
#	#1        AMBIENT              27C/80F    40C/104F
#	#2        MEMORY_BD            53C/127F   110C/230F
#	#3        CPU#1                30C/86F    100C/212F
#	#4        CPU#1                30C/86F    100C/212F
#	#5        I/O_ZONE             48C/118F   63C/145F
#	#6        CPU#2                 -         100C/212F
#	#7        CPU#2                 -         100C/212F
##############################################################################################
