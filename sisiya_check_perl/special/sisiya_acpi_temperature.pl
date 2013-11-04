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
our $proc_acpi_dir = '/proc/acpi/thermal_zone';
our %default_temperatures = ( 'warning' => 60, 'error' => 70 );
our @temperatures;
#$temperatures[0] = ({ 'warning' => 24, 'error' => 25 });
#$temperatures[1] = ({ 'warning' => 22, 'error' => 38 });
#$temperatures[2] = ({ 'warning' => 19, 'error' => 20 });
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
sub use_acpi
{
	my @a_all = `$acpi_prog -ti`;
	my $retcode = $? >>=8;
	if($retcode != 0) {
		$statusid = $SisIYA_Config::statusids{'error'};
		$message_str = "ERROR: Error executing the acpi command! retcode=$retcode";
		sisiya_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str);
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
	my @a_trip_points;
	my $extra_info;
	chomp(@a = @a);
	for my $i (0..$#a) {
		# get trip points into a_trip_points array 
		@a_trip_points = grep(/Thermal $i: trip point/, @a_all);
		#print STDERR "a_trip_points = [@a_trip_points]\n";
		chomp(@a_trip_points = @a_trip_points);
		$state = trim((split(/,/, (split(/:/, $a[$i]))[1]))[0]);
		$temperature = (split(/\s+/,(split(/,/, (split(/:/, $a[$i]))[1]))[1]))[1];
		#print STDERR "Processing battery $i... state=[$state]\n";
		$warning_temperature = $default_temperatures{'warning'};
		$error_temperature = $default_temperatures{'error'};
		$extra_info = "@a_trip_points";
		if(defined $temperatures[$i]{'warning'}) {
			$warning_temperature = $temperatures[$i]{'warning'};
		}
		if(defined $temperatures[$i]{'error'}) {
			$error_temperature = $temperatures[$i]{'error'};
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
		#$info_str .= "INFO: @a_trip_points";

	}

}

sub use_proc_dir
{
	my $state;
	my $s;
	my $retcode;
	my $temperature;
	my $f;
	my $fh;
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
			print STDERR $s;
			$state = trim((split(/:/, $s))[1]);

			$f = $proc_acpi_dir.'/'.$d.'/temperature';
			#print STDERR "$f\n";
			$retcode = open($fh, '<', $f);
			if(! $retcode) {
				next;
			}
			$s = <$fh>;
			close $fh;
			print STDERR $s;
			$temperature = trim((split(/:/, $s))[1]);
			if(($state eq 'ok') || ($state eq 'active')) {
				$ok_str .= " OK: $d $temperature";
			}
		}
	}
}
################################################################################
if(! -d $proc_acpi_dir) {
	if(! -f $acpi_prog) {
		$statusid = $SisIYA_Config::statusids{'error'};
		$message_str = "ERROR: Both directory $proc_acpi_dir and acpi program $acpi_prog does not exist!";
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

