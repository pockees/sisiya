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
our $sensors_prog = '/usr/bin/sensors';
our $acpi_prog = '/usr/sbin/acpi';
our $proc_acpi_dir = '/proc/acpi/thermal_zone';
our %default_temperatures = ( 'warning' => 70, 'error' => 80 );
our %temperatures;
#$temperatures{'THM'} = { 'warning' => 10, 'error' => 30 };
#$temperatures{'0'} = { 'warning' => 24, 'error' => 25 };
#$temperatures{'1'} = { 'warning' => 22, 'error' => 38 };
#$temperatures{'2'} = { 'warning' => 19, 'error' => 20 };
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
my $data_str = '';
my $statusid = $SisIYA_Config::statusids{'ok'};
my $service_name = 'temperature';
my $error_str = '';
my $info_str = '';
my $ok_str = '';
my $warning_str = '';

################################################################################
sub use_acpi
{
	my @a_all = `$acpi_prog -ti`;
	my $retcode = $? >>=8;
	if($retcode != 0) {
		$statusid = $SisIYA_Config::statusids{'error'};
		$message_str = "ERROR: Error executing the acpi command! retcode=$retcode";
		sisiya_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
	}
	my @a = grep(!/trip point/, @a_all);
	#@a =(
	#	"Thermal 0: ok, 32.5 degrees C\n",
	#	"Thermal 0: trip point 0 switches to mode critical at temperature 107.0 degrees C\n",
	#	"Thermal 1: ok, 31.5 degrees C\n",
	#	"Thermal 1: trip point 0 switches to mode critical at temperature 107.0 degrees C\n",
	#	"Thermal 2: ok, 30.5 degrees C\n",
	#	"Thermal 2: trip point 0 switches to mode critical at temperature 107.0 degrees C\n"
	#);
	# acpi -ti
	#Thermal 0: ok, 49.0 degrees C
	#Thermal 0: trip point 0 switches to mode critical at temperature 110.0 degrees C
	#Thermal 0: trip point 1 switches to mode passive at temperature 107.0 degrees C
	#Thermal 0: trip point 2 switches to mode active at temperature 80.0 degrees C
	#Thermal 0: trip point 3 switches to mode active at temperature 72.0 degrees C
	#Thermal 0: trip point 4 switches to mode active at temperature 65.0 degrees C
	#Thermal 1: ok, 0.0 degrees C
	#Thermal 1: trip point 0 switches to mode critical at temperature 110.0 degrees C
	#Thermal 2: ok, 27.3 degrees C
	#Thermal 2: trip point 0 switches to mode critical at temperature 110.0 degrees C
	#Thermal 2: trip point 1 switches to mode passive at temperature 60.0 degrees C
	#Thermal 3: ok, 41.0 degrees C
	#Thermal 3: trip point 0 switches to mode critical at temperature 105.0 degrees C
	#Thermal 3: trip point 1 switches to mode passive at temperature 95.0 degrees C
	#
	#print STDERR @a_all;
	########################################################################## 

	########################################################################## 
	my $state;
	my $temperature;
	my $warning_temperature;
	my $error_temperature;
	my @trip_points;
	my $extra_info;
	chomp(@a = @a);
	for my $i (0..$#a) {
		# get trip points into trip_points array 
		@trip_points = grep(/Thermal $i: trip point/, @a_all);
		#print STDERR "trip_points = [@trip_points]\n";
		chomp(@trip_points = @trip_points);
		$state = trim((split(/,/, (split(/:/, $a[$i]))[1]))[0]);
		$temperature = (split(/\s+/,(split(/,/, (split(/:/, $a[$i]))[1]))[1]))[1];
		#print STDERR "Processing battery $i... state=[$state]\n";
		$extra_info = "@trip_points";
		$warning_temperature = $default_temperatures{'warning'};
		$error_temperature = $default_temperatures{'error'};
		if(defined $temperatures{"$i"}{'warning'}) {
			$warning_temperature = $temperatures{"$i"}{'warning'};
		}
		if(defined $temperatures{"$i"}{'error'}) {
			$error_temperature = $temperatures{"$i"}{'error'};
		}
		if(($state eq 'ok') || ($state eq 'active')) {
			$ok_str .= " OK: $a[$i]. $extra_info";
		}
		else {
			$warning_str .= " WARNING: $a[$i]!. $extra_info";
		}
		if($temperature >= $error_temperature) {
			$error_str .= " ERROR: Temperature is $temperature C (>= $error_temperature) $a[$i]!";
		}
		elsif($temperature >= $warning_temperature) {
			$warning_str .= " WARNING: Temperature is $temperature C (>= $warning_temperature) $a[$i]!";
		}
		#$info_str .= "INFO: @trip_points";

	}

}

sub use_proc_dir
{
	my $state;
	my $s;
	my $retcode;
	my $temperature;
	my $warning_temperature;
	my $error_temperature;
	my $f;
	my $fh;
	my @trip_points;
	my $extra_info;
	if(opendir(my $dh, $proc_acpi_dir)) {
		my @thermal_dirs = grep{!/^\./} readdir($dh);
		closedir($dh);
		foreach my $d (@thermal_dirs) {
			$f = $proc_acpi_dir.'/'.$d.'/state';
			#print STDERR "$f\n";
			$retcode = open($fh, '<', $f);
			if(! $retcode) {
				next;
			}
			$s = <$fh>;
			close $fh;
			#print STDERR $s;
			$state = trim((split(/:/, $s))[1]);

			$f = $proc_acpi_dir.'/'.$d.'/temperature';
			#print STDERR "$f\n";
			$retcode = open($fh, '<', $f);
			if(! $retcode) {
				next;
			}
			$s = <$fh>;
			close $fh;
			#print STDERR $s;
			$f = $proc_acpi_dir.'/'.$d.'/trip_points';
			#print STDERR "$f\n";
			$retcode = open($fh, '<', $f);
			if(! $retcode) {
				next;
			}
			@trip_points = <$fh>;
			close $fh;
			#print STDERR @trip_points;
			$extra_info = "@trip_points";

			$warning_temperature = $default_temperatures{'warning'};
			$error_temperature = $default_temperatures{'error'};
			if(defined $temperatures{"$d"}{'warning'}) {
				$warning_temperature = $temperatures{"$d"}{'warning'};
			}
			if(defined $temperatures{"$d"}{'error'}) {
				$error_temperature = $temperatures{"$d"}{'error'};
			}

			$temperature = (split(/\s+/, (split(/:/, $s))[1]))[1];
			if(($state eq 'ok') || ($state eq 'active')) {
				$ok_str .= " OK: Thermal : $d $temperature C. $extra_info";
			}
			if($temperature >= $error_temperature) {
				$error_str .= " ERROR: Thermal $d: Temperature is $temperature C (>= $error_temperature)!";
			}
			elsif($temperature >= $warning_temperature) {
				$warning_str .= " WARNING: Thermal $d:Temperature is $temperature C (>= $warning_temperature)!";
			}
		}
	}
}

sub use_sensors
{
	my @a = `$sensors_prog -A`;
	my $retcode = $? >>=8;
	if($retcode != 0) {
		$statusid = $SisIYA_Config::statusids{'error'};
		$message_str = "ERROR: Error executing the acpi command! retcode=$retcode";
		sisiya_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
	}
#	@a = (
#		"i5k_amb-isa-0000\n",
#		"Ch. 0 DIMM 0: +48.0°C  (low  = +127.5°C, high = +127.5°C)\n",  
#		"Ch. 0 DIMM 1: +57.0°C  (low  = +127.5°C, high = +127.5°C)\n",
#		"Ch. 1 DIMM 0: +53.0°C  (low  = +127.5°C, high = +127.5°C)\n",
#		"Ch. 1 DIMM 1: +58.5°C  (low  = +127.5°C, high = +127.5°C)\n",
#		"\n",
#		"coretemp-isa-0000\n",
#		"Core 0:      +40.0°C  (high = +80.0°C, crit = +100.0°C)\n",  
#		"Core 1:      +44.0°C  (high = +80.0°C, crit = +100.0°C)\n",  
#		"\n",
#		"coretemp-isa-0001\n",
#		"Core 0:      +42.0°C  (high = +80.0°C, crit = +100.0°C)\n",
#		"Core 1:      +45.0°C  (high = +80.0°C, crit = +100.0°C)\n",
#		"cpitz-virtual-0\n",
#		"temp1:        +32.5°C  (crit = +107.0°C)\n",
#		"\n",
#		"coretemp-isa-0000\n",
#		"Physical id 0:  +53.0°C  (high = +87.0°C, crit = +105.0°C)\n",
#		"Core 0:         +53.0°C  (high = +87.0°C, crit = +105.0°C)\n",
#		"Core 1:         +53.0°C  (high = +87.0°C, crit = +105.0°C)\n",
#		"\n",
#		"pkg-temp-0-virtual-0\n",
#		"temp1:        +53.0°C\n"
#	);
	########################################################################## 
	my $state;
	my $temperature;
	my $warning_temperature;
	my $error_temperature;
	my @trip_points;
	my $extra_info;
	my $sensor;
	my ($crit, $high);
	chomp(@a = @a);
	@a = grep(/C /, grep(/[°|\+]/, @a));
	#print STDERR "@a\n";
	for my $i (0..$#a) {
		$sensor = (split(/:/, $a[$i]))[0];
		$temperature = trim((split(/[°|C]/, (split(/\+/, (split(/:/, $a[$i]))[1]))[1]))[0]);
		#print STDERR "sensor=[$sensor] temperature=[$temperature]\n";
		$extra_info = "";
		$crit = 0;
		$high = 0;
		if(index($a[$i], '(') != -1) {
			# get critical and/or high temperature values
			#print STDERR "Getting crit and/or high temperature values from : $a[$i]\n"; 
			if(index($a[$i], 'high') == -1) {
				$crit = trim((split(/[°|C]/, (split(/\+/, (split(/=/, $a[$i]))[1]))[1]))[0]);
			}
			else {
				$high = trim((split(/[°|C]/, (split(/\+/, (split(/=/, $a[$i]))[1]))[1]))[0]);
				$crit = trim((split(/[°|C]/, (split(/\+/, (split(/=/, $a[$i]))[2]))[1]))[0]);
			}
		}
		#print STDERR "high=[$high] crit=[$crit]\n";
		$warning_temperature = $default_temperatures{'warning'};
		$error_temperature = $default_temperatures{'error'};
		# set crit and high values instead of the overall defaults
		if($high != 0) {
			$warning_temperature = $high;
		}
		if($crit != 0) {
			$error_temperature = $crit;
		}
		if(defined $temperatures{$sensor}{'warning'}) {
			$warning_temperature = $temperatures{$sensor}{'warning'};
		}
		if(defined $temperatures{$sensor}{'error'}) {
			$error_temperature = $temperatures{$sensor}{'error'};
		}
		if($temperature >= $error_temperature) {
			$error_str .= " ERROR: $sensor temperature is $temperature C (>= $error_temperature) $a[$i]!";
		}
		elsif($temperature >= $warning_temperature) {
			$warning_str .= " WARNING: $sensor temperature is $temperature C (>= $warning_temperature) $a[$i]!";
		}
		else {
			$ok_str .= " OK: $sensor temperature is $temperature C.";
		}
	}
}
################################################################################
if( -f $sensors_prog) {
	use_sensors();
}
else {
	if(! -d $proc_acpi_dir) {
		if(! -f $acpi_prog) {
			$statusid = $SisIYA_Config::statusids{'error'};
			$message_str = "ERROR: Directory $proc_acpi_dir, $acpi_prog and $sensors_prog programs does not exist!";
			sisiya_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
		}
		else {
			use_acpi();
		}
	}
	else {
		use_proc_dir();
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
sisiya_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
###################################################################################
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

#########################################################################
#### sensors -A
#########################################################################
#i5k_amb-isa-0000
#Ch. 0 DIMM 0: +48.0°C  (low  = +127.5°C, high = +127.5°C)  
#Ch. 0 DIMM 1: +57.0°C  (low  = +127.5°C, high = +127.5°C)  
#Ch. 1 DIMM 0: +53.0°C  (low  = +127.5°C, high = +127.5°C)  
#Ch. 1 DIMM 1: +58.5°C  (low  = +127.5°C, high = +127.5°C)  
#
#coretemp-isa-0000
#Core 0:      +40.0°C  (high = +80.0°C, crit = +100.0°C)  
#Core 1:      +44.0°C  (high = +80.0°C, crit = +100.0°C)  
#                                                                                                                                                                                                                            
#coretemp-isa-0001
#Core 0:      +42.0°C  (high = +80.0°C, crit = +100.0°C)
#Core 1:      +45.0°C  (high = +80.0°C, crit = +100.0°C) 
#########################################################################
#cpitz-virtual-0
#temp1:        +32.5°C  (crit = +107.0°C)
#
#coretemp-isa-0000
#Physical id 0:  +53.0°C  (high = +87.0°C, crit = +105.0°C)
#Core 0:         +53.0°C  (high = +87.0°C, crit = +105.0°C)
#Core 1:         +53.0°C  (high = +87.0°C, crit = +105.0°C)
#
#pkg-temp-0-virtual-0
#temp1:        +53.0°C
