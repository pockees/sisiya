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
our $smartctl_prog = '/usr/sbin/smartctl';
our @disks;
#push @disks , { 'device' => '/dev/sda', 'warning' => 31, 'error' => 35 };
#push @disks , { 'device' => '/dev/sdb', 'warning' => 30, 'error' => 34 };
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
my $service_name = 'smart';
my $error_str = '';
my $ok_str = '';
my $warning_str = '';
my @a;
my $retcode;
if ($#disks > -1) {
	`$smartctl_prog -h >/dev/null`;
	$retcode = $? >>=8;
	if ($retcode != 0) {
		$statusid = $SisIYA_Config::statusids{'error'};
		$message_str = "ERROR: Error executing the smartctl command! retcode=$retcode";
		print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
	}
}
my $temp;
my $s;
my $i;
for $i (0..$#disks) {
	#@a = `$smartctl_prog -a -d ata  $disks[$i]{'device'} 2>/dev/null`;
	@a = `$smartctl_prog -a -d auto  $disks[$i]{'device'} 2>/dev/null`;
	$retcode = $? >>=8;
	if ($retcode == 2) {
		$error_str .= " ERROR: Could not get info about $disks[$i]{'device'}! retcode=$retcode";
	}
	else {
		chomp(@a = @a);
		$temp = (split(/\s+/, (grep(/Temperature_Celsius/, @a))[0]))[9];
		$s = (grep(/^Device Model:/, @a))[0];
		$s .= ' '.(grep(/^Serial Number:/, @a))[0];
		$s .= ' '.(grep(/^Firmware Version:/, @a))[0];
		$s .= ' '.(grep(/^User Capacity:/, @a))[0];
		#print STDERR "model=[$s]\n";
		if ($temp >= $disks[$i]{'error'}) {
			$error_str .= " ERROR: $temp C (>= $disks[$i]{'error'}) on $disks[$i]{'device'} $s!";
		}	
		elsif ($temp >= $disks[$i]{'warning'}) {
			$warning_str .= " WARNING: $temp C (>= $disks[$i]{'warning'}) on $disks[$i]{'device'} $s!";
		}
		else {
			$ok_str .= " OK: $temp C on $disks[$i]{'device'} $s.";
		}
		if ($retcode != 0) {
			$warning_str .= " WARNING: $disks[$i]{'device'} smartctl return code=$retcode (<> 0)!";
		}
	}
}

if ($error_str ne '') {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = "$error_str";
}
if ($warning_str ne '') {
	if ($statusid < $SisIYA_Config::statusids{'warning'}) {
		$statusid = $SisIYA_Config::statusids{'warning'};
	}	
	$message_str .= "$warning_str";
}
if ($ok_str ne '') {
	$message_str .= "$ok_str";
}
###################################################################################
print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
###################################################################################
#smartctl -H -d ata /dev/sda
#
#smartctl 5.43 2012-06-30 r3573 [i686-linux-2.6.32-358.23.2.el6.i686] (local build)
#Copyright (C) 2002-12 by Bruce Allen, http://smartmontools.sourceforge.net
#
#=== START OF READ SMART DATA SECTION ===
#SMART overall-health self-assessment test result: PASSED
#Please note the following marginal Attributes:
#ID# ATTRIBUTE_NAME          FLAG     VALUE WORST THRESH TYPE      UPDATED  WHEN_FAILED RAW_VALUE
#190 Airflow_Temperature_Cel 0x0022   058   030   045    Old_age   Always   In_the_past 42 (2 162 48 41 0)
#
#
# smartctl -a -d ata /dev/sda
#
#smartctl 5.43 2012-06-30 r3573 [i686-linux-2.6.32-358.23.2.el6.i686] (local build)
#Copyright (C) 2002-12 by Bruce Allen, http://smartmontools.sourceforge.net
#
#=== START OF INFORMATION SECTION ===
#Model Family:     Seagate Barracuda 7200.11
#Device Model:     ST31500341AS
#Serial Number:    9VS19SZE
#LU WWN Device Id: 5 000c50 0110d23c7
#Firmware Version: CC1H
#User Capacity:    1,500,301,910,016 bytes [1.50 TB]
#Sector Size:      512 bytes logical/physical
#Device is:        In smartctl database [for details use: -P show]
#ATA Version is:   8
#ATA Standard is:  ATA-8-ACS revision 4
#Local Time is:    Thu Oct 24 10:05:31 2013 EEST
#SMART support is: Available - device has SMART capability.
#SMART support is: Enabled
#
