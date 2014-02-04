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

if (-f $SisIYA_Config::local_conf) {
	require $SisIYA_Config::local_conf;
}
if (-f $SisIYA_Config::functions) {
	require $SisIYA_Config::functions;
}
#######################################################################################
###############################################################################
#### the default values
our $lpstat_prog = 'lpstat';
#### end of the default values
################################################################################
## override defaults if there is a corresponfing conf file
my $module_conf_file = "$SisIYA_Config::systems_conf_dir/".`basename $0`;
chomp($module_conf_file);
if (-f $module_conf_file) {
	require $module_conf_file;
}

################################################################################
my $message_str = '';
my $data_str = '';
my $statusid = $SisIYA_Config::statusids{'ok'};
my $service_name = 'lpstat';
my $ok_str = '';
my $error_str = '';
my @a = `$lpstat_prog -p 2>/dev/null`;
my @b;
my $retcode = $? >>=8;
my $device_name;
my $device_status;

@a = grep(/^printer/, @a);
foreach (@a) {
	#print STDERR "$_";
	chomp($_ = $_);
	@b = split(/ /, $_);
	$device_name = $b[1];
	if (index($_, 'idle.') != -1) {
		$ok_str .= "OK: $device_name is idle.";
	}
	else {
		if (index($_, 'now printing') != -1) {
			$ok_str .= "OK: $device_name is printing.";
		}
		else {
			@b = split(/ /, $_);
			$device_status = $b[2];
			$error_str .= "ERROR: $device_name is $device_status. line=[$_]";
		}
	}

}
if ($error_str ne '') {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = $error_str;
}
#if ($warning_str ne '') {
#	if ($statusid < $SisIYA_Config::statusids{'warning'}) {
#		$statusid = $SisIYA_Config::statusids{'warning'};
#	}	
#	$message_str .= $warning_str;
#}
if ($ok_str ne '') {
	$message_str .= $ok_str;
}
###################################################################################
print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
###################################################################################
