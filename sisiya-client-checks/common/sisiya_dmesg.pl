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
#######################################################################################
###############################################################################
#### the default values
our @error_strings = ('error', 'fail', 'down', 'crit', 'fault', 'timed out', 'promiscuous', 'crash');
our @warning_strings = ('warn', 'notice', 'not responding', 'NIC Link i Up');
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
my $service_name = 'dmesg';
my $error_messages = '';
my $warning_messages = '';
my $ok_messages = '';
my $x;
foreach (@error_strings) {
	if ($SisIYA_Config::osname eq 'AIX') {
		### AIX does not have dmesg command. I use alog instead. alog -L lists log types.
		#str=`alog -o -t console | head -n 1`
		#use the following command to clear the log file : errclear -i /var/adm/ras/errlog 0
		#str=`errpt | head -n 1`
		chomp($x = `errpt | head -n 1`);
	}
	else {
		chomp($x = `dmesg | grep -i "$_" | head -n 1`);
	}
	if ($x ne '') {
		$error_messages .= " ERROR: [$x] contains [$_]!";
	}
	else {
		$ok_messages .= "[$_]";
	}
}

foreach (@warning_strings) {
	if ($SisIYA_Config::osname eq 'AIX') {
		### AIX does not have dmesg command. I use alog instead. alog -L lists log types.
		#str=`alog -o -t console | head -n 1`
		#use the following command to clear the log file : errclear -i /var/adm/ras/errlog 0
		#str=`errpt | head -n 1`
		chomp($x = `errpt | head -n 1`);
	}
	else {
		chomp($x = `dmesg | grep -i "$_" | head -n 1`);
	}
	if ($x ne '') {
		$warning_messages .= " WARNING: [$x] contains [$_]!";
	}
	else {
		$ok_messages .= "[$_]";
	}
}
if ($error_messages ne '') {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = $error_messages;
}
if ($warning_messages ne '') {
	if ($statusid < $SisIYA_Config::statusids{'warning'}) {
		$statusid = $SisIYA_Config::statusids{'warning'};
	}
	$message_str .= $warning_messages;
}
if ($ok_messages ne '') {
	$message_str .= " OK: dmesg does not contain any of $ok_messages";
}

################################################################################
print "dmesg$SisIYA_Config::FS<msg>$message_str</msg><datamsg></datamsg>\n";
exit $statusid;
################################################################################
