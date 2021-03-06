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
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
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
#### the default values
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
#######################################################################################
my $service_name = 'battery';
## override defaults if there is a corresponding conf file
my $module_conf_file = "$SisIYA_Config::conf_d_dir/sisiya_$service_name.conf";
if (-f $module_conf_file) {
	require $module_conf_file;
}
#######################################################################################
my $message_str = '';
my $data_str = '';
my $statusid = $SisIYA_Config::statusids{'ok'};
my $error_str = '';
my $info_str = '';
my $ok_str = '';
my $warning_str = '';
#######################################################################################

sub use_acpi
{
	my @a = `$SisIYA_Config::external_progs{'acpi'} -bi`;
	my $retcode = $? >>=8;
	if ($retcode != 0) {
		$statusid = $SisIYA_Config::statusids{'error'};
		$message_str = "ERROR: Error executing the acpi command! retcode=$retcode";
		print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
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
	my ($battery_name, $status, $charged_percent, $warning_percent, $error_percent, $j);
	chomp(@a = @a);
	$data_str = '<entries>';
	for my $i (0..($n-1)) {
		$j = 2 * $i;
		$status = trim((split(/,/, (split(/:/, $a[$j]))[1]))[0]);
		$battery_name = trim((split(/:/, $a[$j]))[0]);
		#print STDERR "Processing battery $i... status=[$status]\n";
		$warning_percent = $default_charged_percents{'warning'};
		$error_percent = $default_charged_percents{'error'};
		if (defined $charged_percents[$i]{'warning'}) {
			$warning_percent = $charged_percents[$j]{'warning'};
		}
		if (defined $charged_percents[$i]{'error'}) {
			$error_percent = $charged_percents[$j]{'error'};
		}
		$charged_percent = 100;
		if ($status eq 'Full') {
			$ok_str .= " OK: $a[$j]. $a[$j + 1].";
		}
		elsif ($status eq 'Charging') {
			$ok_str .= " OK: $a[$j]. $a[$j + 1].";
		}
		elsif ($status eq 'Discharging') {
			$charged_percent = trim((split(/%/, (split(/,/, (split(/:/, $a[$j]))[1]))[1]))[0]);
			#print STDERR "$j: charged percent = [$charged_percent]\n";
			if ($charged_percent <= $error_percent) {
				$error_str .= " ERROR: $charged_percent\% (<= $error_percent\%)! $a[$j]! $a[$j + 1].";
			}
			elsif ($charged_percent <= $warning_percent) {
				$warning_str .= " WARNING: $charged_percent\% (<= $warning_percent\%)! $a[$j]! $a[$j + 1].";
			}
			else {
				$ok_str .= " OK: $a[$j]. $a[$j + 1].";
			}
		}
		else {
			$warning_str .= " WARNING: $a[$j]! $a[$j + 1].";
		}
		$data_str .= '<entry name="'.$battery_name.'" type="percent">'.$charged_percent.'</entry>';
	}
	$data_str .= '</entries>';
	@a = `$SisIYA_Config::external_progs{'acpi'} -a`;
	$retcode = $? >>=8;
	if ($retcode == 0) {
		my $s = "@a";
		chomp($s = $s);
		$info_str = "INFO: $s."; 
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
	if (opendir(my $dh, $proc_acpi_battery_dir)) {
		my @battery_dirs = grep{!/^\./} readdir($dh);
		closedir($dh);
		$data_str = '<entries>';
		foreach my $d (@battery_dirs) {
			$f = $proc_acpi_battery_dir.'/'.$d.'/info';
			#print STDERR "$f\n";
			$retcode = open($fh, '<', $f);
			if (! $retcode) {
				next;
			}
			@a_info = <$fh>;
			close $fh;
			$f = $proc_acpi_battery_dir.'/'.$d.'/state';
			#print STDERR "$f\n";
			$retcode = open($fh, '<', $f);
			if (! $retcode) {
				next;
			}
			@a_state = <$fh>;
			close $fh;
			#print STDERR @a_info;
			$status = trim((split(/:/, (grep(/^present/, @a_info))[0]))[1]);
			if ($status eq 'no') {
				next;
			}
			$design_capacity = trim((split(/\s+/, (split(/:/, (grep(/^design capacity:/, @a_info))[0]))[1]))[1]);
			#print STDERR (grep(/^design capacity:/, @a_info))[0]."\n";
			$capacity_state = trim((split(/\s+/, (split(/:/, (grep(/^capacity state:/, @a_state))[0]))[1]))[1]);
			$charging_state = trim((split(/:/, (grep(/^charging state:/, @a_state))[0]))[1]);
			$remaining_capacity = trim((split(/\s+/, (split(/:/, (grep(/^remaining capacity:/, @a_state))[0]))[1]))[1]);
			$charged_percent = 100 * $remaining_capacity / $design_capacity;
			#print STDERR "status=[$status] capacity_state=[$capacity_state] charging_state=[$charging_state] design capacity=[$design_capacity] remaining_capacity=[$remaining_capacity] charged_percent=[$charged_percent]\n";
			if ($capacity_state eq 'ok') {
				$ok_str .= " OK: The capacity state of the battery $d is ok.";
			}
			else {
				$error_str .= " ERROR: The capacity state of the battery $d is $capacity_state!";
			}
			if ($charging_state eq 'charging') {
				$ok_str .= " OK: The charging state of the battery $d is charging ($charged_percent\%). Running on AC power.";
			}
			elsif ($charging_state eq 'charged') {
				$ok_str .= " OK: The charging state of the battery $d is charged ($charged_percent\%). Running on AC power.";
			}
			elsif ($charging_state eq 'discharging') {
				$design_capacity_low = trim((split(/\s+/, (split(/:/, (grep(/^design capacity low:/, @a_info))[0]))[1]))[1]);
				$design_capacity_warning = trim((split(/\s+/, (split(/:/, (grep(/^design capacity warning:/, @a_info))[0]))[1]))[1]);
				$unit = trim((split(/\s+/, (split(/:/, (grep(/^remaining capacity:/, @a_state))[0]))[1]))[2]);
				#print STDERR "design_capacity_low=[$design_capacity_low] design_capacity_warning=[$design_capacity_warning]\n";
				if ($remaining_capacity <= $design_capacity_low) {
					$error_str .= " ERROR: Running out of batter $d ($charged_percent\%) (Ramining capacity is $remaining_capacity $unit <= $design_capacity_low)!";
				}
				elsif ($remaining_capacity <= $design_capacity_warning) {
					$warning_str .= " WARNING: Running out of batter $d ($charged_percent\%) (Ramining capacity is $remaining_capacity $unit <= $design_capacity_warning)!";
				}
				else {
					$ok_str .= " OK: Running out of batter $d ($charged_percent\%) (Ramining capacity is $remaining_capacity $unit).";
				}
			}
			else {
				$error_str .= " ERROR: The charging state of the battery $d ($charged_percent\%) is $charging_state (!= charging)!";
			}
			$data_str .= '<entry name="'.$d.'" type="percent">'.$charged_percent.'</entry>';
			chomp(@a_info = @a_info);
			$info_str .= " INFO: $d battery details: @a_info"; 
		}
		$data_str .= '</entries>';
	}
	if (opendir(my $dh, $proc_acpi_ac_adapter_dir)) {
		$f = $proc_acpi_ac_adapter_dir.'/state';
		#print STDERR "$f\n";
		$retcode = open($fh, '<', $f);
		if ($retcode) {
			@a_state = <$fh>;
			close $fh;
			$status = trim((split(/:/, (grep(/^state/, @a_state))[0]))[1]);
			$info_str .= " INFO: AC adapter state is $status."; 
		}
	}
}
################################################################################
if (! -d $proc_acpi_battery_dir) {
	if (! -f $SisIYA_Config::external_progs{'acpi'}) {
		$statusid = $SisIYA_Config::statusids{'error'};
		$message_str = "ERROR: Both directory $proc_acpi_battery_dir and acpi program $SisIYA_Config::external_progs{'acpi'} does not exist!";
		print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
	}
	else {
		use_acpi();
	}
}
else {
	use_proc_dir();
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
if ($info_str ne '') {
	$message_str .= "$info_str";
}
###################################################################################
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

######################################################################################
print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
######################################################################################
