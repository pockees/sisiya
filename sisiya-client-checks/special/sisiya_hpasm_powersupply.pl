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

if(-f $SisIYA_Config::local_conf) {
	require $SisIYA_Config::local_conf;
}
if(-f $SisIYA_Config::functions) {
	require $SisIYA_Config::functions;
}
#######################################################################################
###############################################################################
#### the default values
our $hpasmcli_prog = '/sbin/hpasmcli';
#### end of the default values
################################################################################
## override defaults if there is a corresponfing conf file
my $module_conf_file = "$SisIYA_Config::systems_conf_dir/".`basename $0`;
chomp($module_conf_file);
if(-f $module_conf_file) {
	require $module_conf_file;
}
################################################################################
my $message_str = '';
my $data_str = '';
my $statusid = $SisIYA_Config::statusids{'ok'};
my $service_name = 'powersupply';
my $error_str = '';
my $info_str = '';
my $ok_str = '';
my $warning_str = '';

################################################################################
my @a = `$hpasmcli_prog -s "show powermeter"`;
my $retcode = $? >>=8;
if($retcode == 0) {
	chomp(@a = @a);
	my $s = "@a";
	$s =~ s/\s+/ /g;
	$ok_str = "OK: $s"; 
}
@a = `$hpasmcli_prog -s "show powersupply"`;
$retcode = $? >>=8;
if($retcode == 0) {
	chomp(@a = @a);
	my $s = "@a";
	$s =~ s/\s+/ /g;
	$info_str = "INFO: $s"; 
	my @b = grep(/Condition/, @a);
	my $status;
	for my $i (0..$#b) {
		#print STDERR "$i $b[$i]\n";
		$status = trim((split(/:/, $b[$i]))[1]);
		#print STDERR "$i status=[$status]\n";
		if($status eq 'Ok') {
			$ok_str .= " OK: The condition of powersupply ".($i + 1)." is Ok.";
		}
		else {
			$error_str .= " ERROR: The condition of powersupply ".($i + 1)." is $status (!= Ok)!";
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
###################################################################################
print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
###################################################################################
#hpasmcli -s "show powermeter"
#
#Power Meter #1
#        Power Reading  : 284
################################################################################
### Sample output of the hpasmcli -s "show powersupply" command :
#Power supply #1
#        Present  : Yes
#        Redundant: Yes
#        Condition: Ok
#        Hotplug  : Supported
#Power supply #2
#        Present  : Yes
#        Redundant: Yes
#        Condition: Ok
#        Hotplug  : Supported
##############################################################################################
