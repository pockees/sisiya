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
#######################################################################################
###############################################################################
#### the default values
our $lpstat_prog = 'lpstat';
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
my $statusid;
my $ok_str = '';
my $error_str = '';
#my @a = `$lpstat_prog -p 2>/dev/null`;
my @a;
$a[0] = 'printer elan01-yz is now printing.  enabled since Prş 03 Eki 2013 16:45:50 EEST';
$a[1] = 'printer elan02-yz is idle.  enabled since Prş 03 Eki 2013 16:45:50 EEST';
$a[2] = 'printer elan03-yz out of paper.  enabled since Prş 03 Eki 2013 16:45:50 EEST';
my @b;
my $retcode = $? >>=8;
my $device_name;
my $device_status;

@a = grep(/^printer/, @a);
foreach(@a) {
	print STDERR "$_";
	chomp($_ = $_);
	@b = split(/ /, $_);
	$device_name = $b[1];
	if(index($_, 'idle.') != -1) {
		$ok_str .= "OK: $device_name is idle.";
	}
	else {
		if(index($_, 'now printing') != -1) {
			$ok_str .= "OK: $device_name is printing.";
		}
		else {
			@b = split(/ /, $_);
			$device_status = $b[2];
			$error_str .= "ERROR: $device_name is $device_status. line=[$_]";
		}
	}

}
$statusid = $SisIYA_Config::statusids{'ok'};
if($error_str ne '') {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = $error_str;
}
#elsif($warning_str ne '') {
#	if($statusid < $SisIYA_Config::statusids{'warning'}) {
#		$statusid = $SisIYA_Config::statusids{'warning'};
#	}	
#	$message_str .= $warning_str;
#}
if($ok_str ne '') {
	$message_str .= $ok_str;
}
################################################################################
print "lpstat$SisIYA_Config::FS<msg>$message_str</msg><datamsg></datamsg>\n";
exit $statusid;
################################################################################
