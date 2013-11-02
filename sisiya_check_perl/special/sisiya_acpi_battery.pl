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
our $acpi_prog = '/usr/sbin/acpi';
our $proc_acpi_battery_dir = '/proc/acpi/battery';
our $proc_acpi_ac_adapter_dir = '/proc/acpi/ac_adapter/AC';
our @charged_percents;
our %default_charged_percents = ( 'warning' => 25, 'error' => 15 );
#our @charged_percents = ( 
#	0 = { 'warning' => 20, 'error' => 10},
#	1 = { 'warning' => 20, 'error' => 10},
#	2 = { 'warning' => 90, 'error' => 95}
#);
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
my $service_name = 'battery';
my $error_str = '';
my $info_str = '';
my $ok_str = '';
my $warning_str = '';

################################################################################
sub use_acpi
{
	my @a = `$acpi_prog -bi`;
	my $retcode = $? >>=8;
	if($retcode != 0) {
		$statusid = $SisIYA_Config::statusids{'error'};
		$message_str = "ERROR: Error executing the acpi command! retcode=$retcode";
		sisiya_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str);
	}
	#@a =(
	#	"Battery 0: Charging, 99%, 00:02:24 until charged\n",
	#	"Battery 0: design capacity 8739 mAh, last full capacity 8485 mAh = 97%\n",
	#	"Battery 1: Discharging, 26%, 07:51:31 remaining\n",
	#	"Battery 1: design capacity 8739 mAh, last full capacity 8485 mAh = 97%\n",
	#	"Battery 2: Discharging, 20%, 00:02:24 until charged\n",
	#	"Battery 2: design capacity 8739 mAh, last full capacity 8485 mAh = 97%\n",
	#);
	#print STDERR @a;
	my $n = ($#a + 1) / 2;
	#print STDERR "number of batteries = $n\n";
	########################################################################## 
	#Battery 0: Charging, 99%, 00:02:24 until charged
	#Battery 0: design capacity 8739 mAh, last full capacity 8485 mAh = 97%
	#
	#Battery 0: Discharging, 100%, 07:51:31 remaining
	#Battery 0: design capacity 8739 mAh, last full capacity 8485 mAh = 97%

	########################################################################## 
	my $status;
	my $charged_percent;
	my $warning_percent;
	my $error_percent;
	my $j;
	chomp(@a = @a);
	for my $i (0..($n-1)) {
		$j = 2 * $i;
		$status = trim((split(/,/, (split(/:/, $a[$j]))[1]))[0]);
		#print STDERR "Processing battery $i... status=[$status]\n";
		$warning_percent = $default_charged_percents{'warning'};
		$error_percent = $default_charged_percents{'error'};
		if(defined $charged_percents[$j]{'warning'}) {
			$warning_percent = $charged_percents[$j]{'warning'};
		}
		if(defined $charged_percents[$j]{'error'}) {
			$error_percent = $charged_percents[$j]{'error'};
		}
		if($status eq 'Full') {
			$ok_str .= " OK: $a[$j]. $a[$j + 1].";
		}
		elsif($status eq 'Charging') {
			$ok_str .= " OK: $a[$j]. $a[$j + 1].";
		}
		elsif($status eq 'Discharging') {
			$charged_percent = trim((split(/%/, (split(/,/, (split(/:/, $a[$j]))[1]))[1]))[0]);
			#print STDERR "$j: charged percent = [$charged_percent]\n";
			if($charged_percent <= $error_percent) {
				$error_str .= " ERROR: $charged_percent\% (<= $error_percent\%)! $a[$j]! $a[$j + 1].";
			}
			elsif($charged_percent <= $warning_percent) {
				$warning_str .= " WARNING: $charged_percent\% (<= $warning_percent\%)! $a[$j]! $a[$j + 1].";
			}
			else {
				$ok_str .= " OK: $a[$j]. $a[$j + 1].";
			}
		}
		else {
			$warning_str .= " WARNING: $a[$j]! $a[$j + 1].";
		}

	}

}

sub use_proc_dir
{
	my $status;
	my @a_info;
	my @a_state;
	my $retcode;
	my $capacity_state;
	my $charging_state;
	my $design_capacity;
	my $remaining_capacity;
	my $charged_percent;
	my $design_capacity_low;
	my $design_capacity_warning;
	my $unit;
	my $f;
	my $fh;
	if(opendir(my $dh, $proc_acpi_battery_dir)) {
		my @battery_dirs = grep{!/^\./} readdir($dh);
		closedir($dh);
		foreach my $d (@battery_dirs) {
			$f = $proc_acpi_battery_dir.'/'.$d.'/info';
			#print STDERR "$f\n";
			$retcode = open($fh, '<', $f);
			if(! $retcode) {
				next;
			}
			@a_info = <$fh>;
			close $fh;
			$f = $proc_acpi_battery_dir.'/'.$d.'/state';
			#print STDERR "$f\n";
			$retcode = open($fh, '<', $f);
			if(! $retcode) {
				next;
			}
			@a_state = <$fh>;
			close $fh;
			#print STDERR @a_info;
			$status = trim((split(/:/, (grep(/^present/, @a_info))[0]))[1]);
			if($status eq 'no') {
				next;
			}
			$design_capacity = trim((split(/\s+/, (split(/:/, (grep(/^design capacity:/, @a_info))[0]))[1]))[1]);
			#print STDERR (grep(/^design capacity:/, @a_info))[0]."\n";
			$capacity_state = trim((split(/\s+/, (split(/:/, (grep(/^capacity state:/, @a_state))[0]))[1]))[1]);
			$charging_state = trim((split(/:/, (grep(/^charging state:/, @a_state))[0]))[1]);
			$remaining_capacity = trim((split(/\s+/, (split(/:/, (grep(/^remaining capacity:/, @a_state))[0]))[1]))[1]);
			$charged_percent = 100 * $remaining_capacity / $design_capacity;
			#print STDERR "status=[$status] capacity_state=[$capacity_state] charging_state=[$charging_state] design capacity=[$design_capacity] remaining_capacity=[$remaining_capacity] charged_percent=[$charged_percent]\n";
			if($capacity_state eq 'ok') {
				$ok_str .= " OK: The capacity state of the battery $d is ok.";
			}
			else {
				$error_str .= " ERROR: The capacity state of the battery $d is $capacity_state!";
			}
			if($charging_state eq 'charging') {
				$ok_str .= " OK: The charging state of the battery $d is charging ($charged_percent\%). Running on AC power.";
			}
			elsif($charging_state eq 'charged') {
				$ok_str .= " OK: The charging state of the battery $d is charged ($charged_percent\%). Running on AC power.";
			}
			elsif($charging_state eq 'discharging') {
				$design_capacity_low = trim((split(/\s+/, (split(/:/, (grep(/^design capacity low:/, @a_info))[0]))[1]))[1]);
				$design_capacity_warning = trim((split(/\s+/, (split(/:/, (grep(/^design capacity warning:/, @a_info))[0]))[1]))[1]);
				$unit = trim((split(/\s+/, (split(/:/, (grep(/^remaining capacity:/, @a_state))[0]))[1]))[2]);
				#print STDERR "design_capacity_low=[$design_capacity_low] design_capacity_warning=[$design_capacity_warning]\n";
				if($remaining_capacity <= $design_capacity_low) {
					$error_str .= " ERROR: Running out of batter $d ($charged_percent\%) (Ramining capacity is $remaining_capacity $unit <= $design_capacity_low)!";
				}
				elsif($remaining_capacity <= $design_capacity_warning) {
					$warning_str .= " WARNING: Running out of batter $d ($charged_percent\%) (Ramining capacity is $remaining_capacity $unit <= $design_capacity_warning)!";
				}
				else {
					$ok_str .= " OK: Running out of batter $d ($charged_percent\%) (Ramining capacity is $remaining_capacity $unit).";
				}
			}
			else {
				$error_str .= " ERROR: The charging state of the battery $d ($charged_percent\%) is $charging_state (!= charging)!";
			}
			chomp(@a_info = @a_info);
			$info_str .= " INFO: $d battery details: @a_info"; 
		}
		}
	if(opendir(my $dh, $proc_acpi_ac_adapter_dir)) {
		$f = $proc_acpi_ac_adapter_dir.'/state';
		#print STDERR "$f\n";
		$retcode = open($fh, '<', $f);
		if($retcode) {
			@a_state = <$fh>;
			close $fh;
			$status = trim((split(/:/, (grep(/^state/, @a_state))[0]))[1]);
			$info_str .= " INFO: AC adapter state is $status."; 
		}
	}
}
################################################################################
if(! -d $proc_acpi_battery_dir) {
	if(! -f $acpi_prog) {
		$statusid = $SisIYA_Config::statusids{'error'};
		$message_str = "ERROR: Both directory $proc_acpi_battery_dir and acpi program $acpi_prog does not exist!";
		sisiya_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str);
	}
	else {
		use_acpi();
	}
}
else {
	use_proc_dir();
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
##################################################################
### cat /proc/acpi/battery/C1BE/info
### or cat /proc/acpi/battery/BAT0/info
#present:                 yes
#design capacity:         2086 mAh
#last full capacity:      2086 mAh
#battery technology:      rechargeable
#design voltage:          14400 mV
#design capacity warning: 105 mAh
#design capacity low:     21 mAh
#capacity granularity 1:  100 mAh
#capacity granularity 2:  100 mAh
#model number:            Primary
#serial number:           45119 2007/05/09
#battery type:            LIon
#OEM info:                Hewlett-Packard
##########################################################################
### cat /proc/acpi/battery/C1BE/state
#present:                 yes
#capacity state:          ok
#charging state:          discharging
#present rate:            2264 mA
#remaining capacity:      1965 mAh
#present voltage:         15344 mV
##########################################################################

##########################################################################
# Since kernel 2.6.20.7, ACPI modules are all modularized to avoid ACPI issues that were reported on some machines.
# https://wiki.archlinux.org/index.php/ACPI_modules
# acpi -i
# Battery 0: Full, 100%
# Battery 0: design capacity 5405 mAh, last full capacity 5441 mAh = 100%
#
# acpi -i
# Battery 0: Discharging, 97%, 04:11:04 remaining
# Battery 0: design capacity 5405 mAh, last full capacity 5441 mAh = 100%
#
#########
# acpi -V
#
# Battery 0: Full, 100%
# Battery 0: design capacity 5405 mAh, last full capacity 5441 mAh = 100%
# Adapter 0: on-line
# Thermal 0: ok, 25.0 degrees C
# Thermal 0: trip point 0 switches to mode critical at temperature 107.0 degrees C
# Cooling 0: LCD 15 of 15
# Cooling 1: Processor 0 of 10
# Cooling 2: Processor 0 of 10
# Cooling 3: Processor 0 of 10
# Cooling 4: Processor 0 of 10

