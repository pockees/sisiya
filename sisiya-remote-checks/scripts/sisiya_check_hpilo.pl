#!/usr/bin/perl -w 
#
#	This script uses HP's locfg.pl script, a copy of which is included
#	in the utils directory of the SisIYA remote checks package under the name
#	hp_locfg.pl. This hp_locfg.pl script in turn needs perl-TermKey and perl-Socket6
#	Perl packages.
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
use SisIYA_Remote_Config;
use XML::Simple;
use Data::Dumper;
require File::Temp;
use File::Temp();
#use Data::Dumper;

my $check_name = 'hpilo';

if ( $#ARGV != 1 ) {
	print "Usage : $0 ".$check_name."_systems.xml expire\n";
	print "The expire parameter must be given in minutes.\n";
	exit 1;
}
if (-f $SisIYA_Remote_Config::local_conf) {
	require $SisIYA_Remote_Config::local_conf;
}
#if (-f $SisIYA_Remote_Config::client_conf) {
#	require $SisIYA_Remote_Config::client_conf;
#}
if (-f $SisIYA_Remote_Config::client_local_conf) {
	require $SisIYA_Remote_Config::client_local_conf;
}
if (-f $SisIYA_Config::functions) {
	require $SisIYA_Config::functions;
}
if (-f $SisIYA_Remote_Config::functions) {
	require $SisIYA_Remote_Config::functions;
}

sub check_hpilo2_fans
{
	my ($expire, $r) = @_;
	my $serviceid = get_serviceid('fanspeed');
	my $statusid = $SisIYA_Config::statusids{'ok'};
	my $ok_str = '';
	my $error_str = '';
	my $s = '';
	
	my $status_str = $r->{'HEALTH_AT_A_GLANCE'}->{'FANS'}[0]{'STATUS'};
	if ($status_str eq 'Ok') {
		$ok_str = " OK: Fans status is $status_str.";
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$error_str = " ERROR: Fans status is $status_str (!= Ok)!";
	}
	$status_str = $r->{'HEALTH_AT_A_GLANCE'}->{'FANS'}[1]{'REDUNDANCY'};
	if ($status_str eq 'Fully Redundant') {
		$ok_str .= " OK: Fans redundancy is $status_str.";
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$error_str .= " ERROR: Fans redundancy is $status_str (!= Fully Redundant)!";
	}
	my $total_fans = 0;
	my $failed_fans = 0;
	foreach my $h (@{$r->{'FANS'}->{'FAN'}}) {
		$total_fans++;
		$s = "speed: $h->{'SPEED'}{'VALUE'} $h->{'SPEED'}{'UNIT'}, zone: $h->{'ZONE'}{'VALUE'}";
		if ($h->{'STATUS'}{'VALUE'} eq 'Ok') {
			$ok_str .= "OK: Fan $h->{'LABEL'}{'VALUE'} ($s) status is OK.";
		} else {
			$failed_fans++;
			$error_str .= "ERROR: Fans $h->{'LABEL'}{'VALUE'} ($s) has status $h->{'STATUS'}{'VALUE'} (!Ok)!";
		}
	}
	if ($failed_fans == 0) {
		$ok_str .= "OK: All $total_fans fans are OK."
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$error_str .= "ERROR: $failed_fans / $total_fans fans failed!";
	}

	$s = $error_str.$ok_str;

	return "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message>";
}


sub check_hpilo4_fans
{
	my ($expire, $r) = @_;
	my $serviceid = get_serviceid('fanspeed');
	my $statusid = $SisIYA_Config::statusids{'ok'};
	my $ok_str = '';
	my $error_str = '';
	my $s = '';
	
	my $status_str = $r->{'HEALTH_AT_A_GLANCE'}->{'FANS'}[0]{'STATUS'};
	if ($status_str eq 'OK') {
		$ok_str = " OK: Fans status is $status_str.";
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$error_str = " ERROR: Fans status is $status_str (!= OK)!";
	}
	$status_str = $r->{'HEALTH_AT_A_GLANCE'}->{'FANS'}[1]{'REDUNDANCY'};
	if ($status_str eq 'Redundant') {
		$ok_str .= " OK: Fans redundancy is $status_str.";
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$error_str .= " ERROR: Fans redundancy is $status_str (!= Redundndant)!";
	}

	my $total_fans = 0;
	my $failed_fans = 0;
	foreach my $h (@{$r->{'FANS'}->{'FAN'}}) {
		$total_fans++;
		$s = "speed: $h->{'SPEED'}{'VALUE'} $h->{'SPEED'}{'UNIT'}, zone: $h->{'ZONE'}{'VALUE'}";
		if ($h->{'STATUS'}{'VALUE'} eq 'OK') {
			$ok_str .= "OK: Fan $h->{'LABEL'}{'VALUE'} ($s) status is OK.";
		} else {
			$failed_fans++;
			$error_str .= "ERROR: Fans $h->{'LABEL'}{'VALUE'} ($s) has status $h->{'STATUS'}{'VALUE'} (!OK)!";
		}
	}
	if ($failed_fans == 0) {
		$ok_str .= "OK: All $total_fans fans are OK."
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$error_str .= "ERROR: $failed_fans / $total_fans fans failed!";
	}
	$s = "$error_str $ok_str";

	return "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message>";
}

sub check_hpilo2_powersupply
{
	my ($expire, $r) = @_;
	my $serviceid = get_serviceid('powersupply');
	my $statusid = $SisIYA_Config::statusids{'ok'};
	my $ok_str = '';
	my $error_str = '';
	my $s = '';
	
	my $status_str = $r->{'HEALTH_AT_A_GLANCE'}->{'POWER_SUPPLIES'}[0]{'STATUS'};
	if ($status_str eq 'Ok') {
		$ok_str = " OK: Power supply status is $status_str.";
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$error_str = " ERROR: Power supply status is $status_str (!= Ok)!";
	}
	$status_str = $r->{'HEALTH_AT_A_GLANCE'}->{'POWER_SUPPLIES'}[1]{'REDUNDANCY'};
	if ($status_str eq 'Fully Redundant') {
		$ok_str .= " OK: Power supply redundancy is $status_str.";
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$error_str .= " ERROR: Power supply redundancy is $status_str (!= Fully Redundant)!";
	}

	my $total_power_supplies = 0;
	my $failed_power_supplies = 0;
	foreach my $h (@{$r->{'POWER_SUPPLIES'}->{'SUPPLY'}}) {
		$total_power_supplies++;
		if ($h->{'STATUS'}{'VALUE'} eq 'Ok') {
			$ok_str .= "OK: Power supply $h->{'LABEL'}{'VALUE'} status is OK.";
		} else {
			$failed_power_supplies++;
			$error_str .= "ERROR: Power supply $h->{'LABEL'}{'VALUE'} has status $h->{'STATUS'}{'VALUE'} (!Ok)!";
		}
	}
	if ($failed_power_supplies == 0) {
		$ok_str .= "OK: All $total_power_supplies power supplies are OK."
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$error_str .= "ERROR: $failed_power_supplies / $total_power_supplies power supplies failed!";
		# add the failed drive list
		$error_str .= $s;
	}
	$s = "$error_str $ok_str";

	$s = $error_str.$ok_str;

	return "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message>";
}


sub check_hpilo4_powersupply
{
	my ($expire, $r) = @_;
	my $serviceid = get_serviceid('powersupply');
	my $statusid = $SisIYA_Config::statusids{'ok'};
	my $ok_str = '';
	my $info_str = '';
	my $error_str = '';
	my $s = '';

	# strange, but this is an array
	###############	
	# 'POWER_SUPPLIES' => [
	#                    {
	#                     'STATUS' => 'OK'
	#                    },
	#                    {
	#                     'REDUNDANCY' => 'Redundant'
	#                    }
	#                   ],
	###############	
	my $status_str = $r->{'HEALTH_AT_A_GLANCE'}->{'POWER_SUPPLIES'}[0]{'STATUS'};
	if ($status_str eq 'OK') {
		$ok_str .= " OK: Power supply status is $status_str.";
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$error_str .= " ERROR: Power supply status is $status_str (!= OK)!";
	}
	$status_str = $r->{'HEALTH_AT_A_GLANCE'}->{'POWER_SUPPLIES'}[1]{'REDUNDANCY'};
	if ($status_str eq 'Redundant') {
		$ok_str .= " OK: Power supply redundancy is $status_str.";
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$error_str .= " ERROR: Power supply redundancy is $status_str (!= Redundndant)!";
	}
	$info_str = "INFO: Power reading: $r->{'POWER_SUPPLIES'}->{'POWER_SUPPLY_SUMMARY'}->{'PRESENT_POWER_READING'}{'VALUE'}";
	$info_str .= ", Firmware version: $r->{'POWER_SUPPLIES'}->{'POWER_SUPPLY_SUMMARY'}->{'POWER_MANAGEMENT_CONTROLLER_FIRMWARE_VERSION'}{'VALUE'}";
	$info_str .= ", High efficiency mode: $r->{'POWER_SUPPLIES'}->{'POWER_SUPPLY_SUMMARY'}->{'HIGH_EFFICIENCY_MODE'}{'VALUE'}";
	$info_str .= ", HP power discovery services redundancy status: $r->{'POWER_SUPPLIES'}->{'POWER_SUPPLY_SUMMARY'}->{'HP_POWER_DISCOVERY_SERVICES_REDUNDANCY_STATUS'}{'VALUE'}";

	my $total_power_supplies = 0;
	my $failed_power_supplies = 0;
	foreach my $h (@{$r->{'POWER_SUPPLIES'}->{'SUPPLY'}}) {
		if ($h->{'PRESENT'}{'VALUE'} eq 'Yes') {
			$total_power_supplies++;
			$s = "capacity: $h->{'CAPACITY'}{'VALUE'}, serial number: $h->{'SERIAL_NUMBER'}{'VALUE'}, hotplugable: $h->{'HOTPLUG_CAPABLE'}{'VALUE'}, model: $h->{'MODEL'}{'VALUE'}, firmware version: $h->{'FIRMWARE_VERSION'}{'VALUE'}, pds: $h->{'PDS'}{'VALUE'}, spare: $h->{'SPARE'}{'VALUE'}";
			if ($h->{'STATUS'}{'VALUE'} eq 'Good, In Use') {
				$ok_str .= "OK: Power supply $h->{'LABEL'}{'VALUE'} ($s) status is good and in use.";
			} else {
				$failed_power_supplies++;
				$error_str .= "ERROR: Power supply $h->{'LABEL'}{'VALUE'} ($s) has status $h->{'STATUS'}{'VALUE'} (!Good, In Use)!";
			}
		}
	}
	if ($failed_power_supplies == 0) {
		$ok_str .= "OK: All $total_power_supplies power supplies are OK."
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$error_str .= "ERROR: $failed_power_supplies / $total_power_supplies power supplies failed!";
	}
	$s = "$error_str $ok_str $info_str";

	return "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message>";
}

sub check_hpilo4_ram
{
	my ($expire, $r) = @_;
	my $serviceid = get_serviceid('ram');
	my $statusid = $SisIYA_Config::statusids{'ok'};
	my $ok_str = '';
	my $info_str = '';
	my $error_str = '';
	my $s = '';

	my $status_str = $r->{'HEALTH_AT_A_GLANCE'}->{'MEMORY'}{'STATUS'}; 
	if ($status_str eq 'OK') {
		$ok_str = " OK: RAM status is $status_str.";
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$error_str = " ERROR: RAM status is $status_str (!= OK)!";
	}

	my $i = 1;
	my @a;
	my $index_str = 'CPU_'.$i;
	while (ref($r->{'MEMORY'}->{'MEMORY_DETAILS'}->{$index_str}) eq 'ARRAY') {
		###print STDERR "\nA: $r->{'MEMORY'}->{'MEMORY_DETAILS'}->{$index_str}[0]{'STATUS'}{'VALUE'}\n";
		@a = @{$r->{'MEMORY'}->{'MEMORY_DETAILS'}->{$index_str}};
		foreach my $k (@a) {
			###print STDERR "\n RAM: status: $k->{'STATUS'}{'VALUE'} size: $k->{'SIZE'}{'VALUE'}\n";
			$status_str = $k->{'STATUS'}{'VALUE'};
			if ($status_str eq 'Not Present') {
				next;
			}
			$s = "size: $k->{'SIZE'}{'VALUE'}, ranks: $k->{'RANKS'}{'VALUE'}, part: $k->{'PART'}{'NUMBER'}, type: $k->{'TYPE'}{'VALUE'}";
			$s .= ", frequency: $k->{'FREQUENCY'}{'VALUE'}, technology: $k->{'TECHNOLOGY'}{'VALUE'},  min voltage: $k->{'MINIMUM_VOLTAGE'}{'VALUE'}, HP smart memory: $k->{'HP_SMART_MEMORY'}{'VALUE'}";
			if ($status_str eq 'Good, In Use') {
				$ok_str .= "OK: RAM for CPU $i in socket: $k->{'SOCKET'}{'VALUE'} ($s) is OK.";
			} else {
				$statusid = $SisIYA_Config::statusids{'error'};
				$error_str .= "ERROR: RAM for CPU $i in socket: $k->{'SOCKET'}{'VALUE'} ($s) has status $status_str (!=Good, In Use)!";
			}
		}
		$i++;
		$index_str = 'CPU_'.$i;
	}
	my $h;
	$i = 1;
	$index_str = 'CPU_'.$i;
	while (ref($r->{'MEMORY'}->{'MEMORY_DETAILS_SUMMARY'}->{$index_str}) eq 'HASH') {
		$h = $r->{'MEMORY'}->{'MEMORY_DETAILS_SUMMARY'}->{$index_str};
		$info_str .= "INFO: CPU $i total RAM $h->{'TOTAL_MEMORY_SIZE'}{'VALUE'}, operating frequency: $h->{'OPERATING_FREQUENCY'}{'VALUE'}";
		$info_str .= ", number of sockets: $h->{'NUMBER_OF_SOCKETS'}{'VALUE'}, operating voltage: $h->{'OPERATING_VOLTAGE'}{'VALUE'}.";
		$i++;
		$index_str = 'CPU_'.$i;
	}
	$h = $r->{'MEMORY'}->{'ADVANCED_MEMORY_PROTECTION'};
	$info_str .= "INFO: Advanced Memory Protection: configured mode: $h->{'CONFIGURED_AMP_MODE'}{'VALUE'}, available modes: $h->{'AVAILABLE_AMP_MODES'}{'VALUE'}, status: $h->{'AMP_MODE_STATUS'}{'VALUE'}";
	$s = $error_str.$ok_str.$info_str;
	return "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message>";
}

sub check_hpilo4_cpu
{
	my ($expire, $r) = @_;
	my $serviceid = get_serviceid('cpu');
	my $statusid = $SisIYA_Config::statusids{'ok'};
	my $ok_str = '';
	my $error_str = '';
	my $s = '';

	my $status_str = $r->{'HEALTH_AT_A_GLANCE'}->{'PROCESSOR'}{'STATUS'}; 
	if ($status_str eq 'OK') {
		$ok_str = " OK: CPU status is $status_str.";
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$error_str = " ERROR: CPU status is $status_str (!= OK)!";
	}
	my $total_cpus = 0;
	my $failed_cpus = 0;
	foreach my $h (@{$r->{'PROCESSORS'}->{'PROCESSOR'}}) {
		$total_cpus++;
		$status_str = $h->{'STATUS'}{'VALUE'};
		$s = "$h->{'NAME'}{'VALUE'}, speed: $h->{'SPEED'}{'VALUE'}, execution technology: $h->{'EXECUTION_TECHNOLOGY'}{'VALUE'}, memory technology: $h->{'MEMORY_TECHNOLOGY'}{'VALUE'}";
		$s .= ", L1 cache: $h->{'INTERNAL_L1_CACHE'}{'VALUE'}, L2 cache: $h->{'INTERNAL_L2_CACHE'}{'VALUE'}, L3 cache: $h->{'INTERNAL_L3_CACHE'}{'VALUE'}";
		if ($status_str eq 'OK') {
			$ok_str .= "OK: $h->{'LABEL'}{'VALUE'} ($s) is OK.";
		} else {
			$failed_cpus++;
			$statusid = $SisIYA_Config::statusids{'error'};
			$error_str .= "ERROR: $h->{'LABEL'}{'VALUE'} ($s) has status $status_str (!=OK)!";
		}
	}
	if ($failed_cpus == 0) {
		$ok_str .= "OK: All $total_cpus CPUs are OK.";
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$error_str .= "ERROR: $failed_cpus / $total_cpus failed!";
	}
	$s = "$error_str $ok_str";
	return "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message>";
}

sub check_hpilo2_temperature
{
	my ($expire, $r) = @_;
	my $serviceid = get_serviceid('temperature');
	my $statusid = $SisIYA_Config::statusids{'ok'};
	my $ok_str = '';
	my $warning_str = '';
	my $error_str = '';
	my $s = '';

	my $status_str = $r->{'HEALTH_AT_A_GLANCE'}->{'TEMPERATURE'}{'STATUS'}; 
	if ($status_str eq 'Ok') {
		$ok_str = " OK: Temperature status is $status_str.";
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$error_str = " ERROR: Temperature status is $status_str (!= Ok)!";
	}
	my $i = 0;
	foreach my $h (@{$r->{'TEMPERATURE'}->{'TEMP'}}) {
		$i++;
		$status_str = $h->{'STATUS'}{'VALUE'};
		if ($status_str eq 'n/a' || $status_str eq 'Not Installed') {
			next;
		}
		$s = "$h->{'LABEL'}{'VALUE'}, location: $h->{'LOCATION'}{'VALUE'}";
		if ($status_str eq 'Ok') {
			$ok_str .= "OK: Temperature sensor #$i is OK.";
		} else {
			$statusid = $SisIYA_Config::statusids{'error'};
			$error_str .= "ERROR: Temperature sensor #$i has status $status_str (!=Ok)!";
		}
		if ($h->{'CRITICAL'}{'VALUE'} ne 'n/a' && int($h->{'CURRENTREADING'}{'VALUE'}) >= int($h->{'CRITICAL'}{'VALUE'})) {
			$statusid = $SisIYA_Config::statusids{'error'};
			$error_str .= "ERROR: Temperature of the #$i sensor is $h->{'CURRENTREADING'}{'VALUE'} >= $h->{'CRITICAL'}{'VALUE'} $h->{'CURRENTREADING'}{'UNIT'}!";
		} elsif ($h->{'CAUTION'}{'VALUE'} ne 'n/a' && int($h->{'CURRENTREADING'}{'VALUE'}) >= int($h->{'CAUTION'}{'VALUE'})) {
			if ($statusid < $SisIYA_Config::statusids{'warning'}) {
				$statusid = $SisIYA_Config::statusids{'warning'};
			}
			$warning_str .= "WARNING: Temperature of the #$i sensor is $h->{'CURRENTREADING'}{'VALUE'} >= $h->{'CAUTION'}{'VALUE'} $h->{'CURRENTREADING'}{'UNIT'}!";
		} else {
			$ok_str .= "OK: Temperature of the #$i sensor ($s) is $h->{'CURRENTREADING'}{'VALUE'} $h->{'CURRENTREADING'}{'UNIT'}.";
		}
	}
	$s = "$error_str $warning_str $ok_str";

	return "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message>";
}

sub check_hpilo4_temperature
{
	my ($expire, $r) = @_;
	my $serviceid = get_serviceid('temperature');
	my $statusid = $SisIYA_Config::statusids{'ok'};
	my $ok_str = '';
	my $error_str = '';
	my $warning_str = '';
	my $s = '';

	my $status_str = $r->{'HEALTH_AT_A_GLANCE'}->{'TEMPERATURE'}{'STATUS'}; 
	if ($status_str eq 'OK') {
		$ok_str = " OK: Temperature status is $status_str.";
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$error_str = " ERROR: Temperature status is $status_str (!= OK)!";
	}
	my $i = 0;
	foreach my $h (@{$r->{'TEMPERATURE'}->{'TEMP'}}) {
		$i++;
		$status_str = $h->{'STATUS'}{'VALUE'};
		if ($status_str eq 'N/A' || $status_str eq 'Not Installed') {
			next;
		}
		$s = "$h->{'LABEL'}{'VALUE'}, location: $h->{'LOCATION'}{'VALUE'}";
		if ($status_str eq 'OK') {
			$ok_str .= "OK: Temperature sensor #$i is OK.";
		} else {
			$statusid = $SisIYA_Config::statusids{'error'};
			$error_str .= "ERROR: Temperature sensor #$i has status $status_str (!=OK)!";
		}
		if ($h->{'CRITICAL'}{'VALUE'} ne 'N/A' && int($h->{'CURRENTREADING'}{'VALUE'}) >= int($h->{'CRITICAL'}{'VALUE'})) {
			$statusid = $SisIYA_Config::statusids{'error'};
			$error_str .= "ERROR: Temperature of the #$i sensor is $h->{'CURRENTREADING'}{'VALUE'} >= $h->{'CRITICAL'}{'VALUE'} $h->{'CURRENTREADING'}{'UNIT'}!";
		} elsif ($h->{'CAUTION'}{'VALUE'} ne 'N/A' && int($h->{'CURRENTREADING'}{'VALUE'}) >= int($h->{'CAUTION'}{'VALUE'})) {
			if ($statusid < $SisIYA_Config::statusids{'warning'}) {
				$statusid = $SisIYA_Config::statusids{'warning'};
			}
			$warning_str .= "WARNING: Temperature of the #$i sensor is $h->{'CURRENTREADING'}{'VALUE'} >= $h->{'CAUTION'}{'VALUE'} $h->{'CURRENTREADING'}{'UNIT'}!";
		} else {
			$ok_str .= "OK: Temperature of the #$i sensor ($s) is $h->{'CURRENTREADING'}{'VALUE'} $h->{'CURRENTREADING'}{'UNIT'}.";
		}
	}
	$s = "$error_str $warning_str $ok_str";
	return "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message>";
}


sub check_hpilo4_raid
{
	my ($expire, $r) = @_;
	my $serviceid = get_serviceid('raid');
	my $statusid = $SisIYA_Config::statusids{'ok'};
	my $ok_str = '';
	my $error_str = '';
	my $info_str = '';
	my $s = '';

	my $status_str = $r->{'STORAGE'}->{'CONTROLLER'}->{'STATUS'}{'VALUE'};
	if ($status_str eq 'OK') {
		$ok_str = " OK: RAID status is $status_str.";
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$error_str = " ERROR: RAID status is $status_str (!= OK)!";
	}

	# check controller status
	$status_str = $r->{'STORAGE'}->{'CONTROLLER'}->{'CONTROLLER_STATUS'}{'VALUE'};
	if ($status_str eq 'OK') {
		$ok_str .= " OK: Controller status is OK.";
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$error_str .= " ERROR: Controller status is $status_str (!=OK)!";
	}
	my $controller_str = "Name: $r->{'STORAGE'}->{'CONTROLLER'}->{'LABEL'}{'VALUE'}";
	$controller_str .= ", Serial No: $r->{'STORAGE'}->{'CONTROLLER'}->{'SERIAL_NUMBER'}{'VALUE'}";
	$controller_str .= ", Model: $r->{'STORAGE'}->{'CONTROLLER'}->{'MODEL'}{'VALUE'}";
	$controller_str .= ", Firmware Version: $r->{'STORAGE'}->{'CONTROLLER'}->{'FW_VERSION'}{'VALUE'}";

	$info_str = "INFO: $controller_str";

	# check cache module status
	$status_str = $r->{'STORAGE'}->{'CONTROLLER'}->{'CACHE_MODULE_STATUS'}{'VALUE'};
	if ($status_str eq 'OK') {
		$ok_str .= " OK: Cache module status is OK.";
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$error_str .= " ERROR: Cache module status is $status_str (!=OK)!";
	}
	$info_str .= ", Cache memory: $r->{'STORAGE'}->{'CONTROLLER'}->{'CACHE_MODULE_MEMORY'}{'VALUE'}";

	# check logical drive status
	$status_str = $r->{'STORAGE'}->{'CONTROLLER'}->{'LOGICAL_DRIVE'}->{'STATUS'}{'VALUE'};
	my $drive_str .= "$r->{'STORAGE'}->{'CONTROLLER'}->{'LOGICAL_DRIVE'}->{'LABEL'}{'VALUE'}";
	$drive_str .= " (capacity: $r->{'STORAGE'}->{'CONTROLLER'}->{'LOGICAL_DRIVE'}->{'CAPACITY'}{'VALUE'}";
	$drive_str .= ", fault tolerance: $r->{'STORAGE'}->{'CONTROLLER'}->{'LOGICAL_DRIVE'}->{'FAULT_TOLERANCE'}{'VALUE'})";
	if ($status_str eq 'OK') {
		$ok_str .= " OK: Logical drive $drive_str status is OK.";
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$error_str .= " ERROR: Logical drive $drive_str status is $status_str (!=OK)!";
	}

	my $total_physical_drives = 0;
	my $failed_physical_drives = 0;
	$s = '';
	foreach my $h (@{$r->{'STORAGE'}->{'CONTROLLER'}->{'LOGICAL_DRIVE'}->{'PHYSICAL_DRIVE'}}) {
		$total_physical_drives++;
		$status_str = $h->{'STATUS'}{'VALUE'};
		$s = "capacity: $h->{'CAPACITY'}{'VALUE'}, location : $h->{'LOCATION'}{'VALUE'}, serial number: $h->{'SERIAL_NUMBER'}{'VALUE'}, model: $h->{'MODEL'}{'VALUE'}";
		$s .= ", encryption status: $h->{'ENCRYPTION_STATUS'}{'VALUE'}, firmware version: $h->{'FW_VERSION'}{'VALUE'}, drive configuration: $h->{'DRIVE_CONFIGURATION'}{'VALUE'}";
		if ($status_str eq 'OK') {
			$ok_str .= "OK: $h->{'LABEL'}{'VALUE'} drive ($s) is OK.";
		} else {
			$failed_physical_drives++;
			$error_str .= "ERROR: $h->{'LABEL'}{'VALUE'} drive ($s) has status $status_str (!=OK)!";
		}
	}
	if ($failed_physical_drives == 0) {
		$ok_str .= "OK: All $total_physical_drives physical drives are OK."
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$error_str .= "ERROR: $failed_physical_drives / $total_physical_drives physical drives failed!";
		# add the failed drive list
		$error_str .= $s;
	}

	$s = "$error_str $ok_str $info_str";
	return "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message>";
}


sub check_hpilo4_system
{
	my ($expire, $r) = @_;
	my $serviceid = get_serviceid('system');
	my $statusid = $SisIYA_Config::statusids{'ok'};
	my $ok_str = '';
	my $error_str = '';
	my $info_str = '';
	my $s = '';

	my $status_str = $r->{'HEALTH_AT_A_GLANCE'}->{'BIOS_HARDWARE'}{'STATUS'};
	if ($status_str eq 'OK') {
		$ok_str = " OK: BIOS hardware status is $status_str.";
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$error_str = " ERROR: BIOS hardware status is $status_str (!= OK)!";
	}
	$status_str = $r->{'HEALTH_AT_A_GLANCE'}->{'NETWORK'}{'STATUS'};
	if ($status_str eq 'OK') {
		$ok_str .= " OK: Network status is $status_str.";
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$error_str .= " ERROR: Network status is $status_str (!= OK)!";
	}
	my $i = 1;
	my $index_str = 'INDEX_'.$i;
	while (ref($r->{'FIRMWARE_INFORMATION'}->{$index_str}) eq 'HASH') {
		$info_str .= "INFO: $r->{'FIRMWARE_INFORMATION'}->{$index_str}->{'FIRMWARE_NAME'}{'VALUE'}: $r->{'FIRMWARE_INFORMATION'}->{$index_str}->{'FIRMWARE_VERSION'}{'VALUE'}";
		$i++;
		$index_str = 'INDEX_'.$i;
	}

	$s = $error_str.$ok_str.$info_str;

	return "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message>";
}

sub check_hpilo
{
	my ($isactive, $serviceid, $expire, $system_name, $hostname, $username, $password, $version) = @_;

	if ($isactive eq 'f' ) {
		return '';
	}

	#print STDERR "Checking system_name=[$system_name] hostname=[$hostname] isactive=[$isactive] username=[$username] ...\n";
	my $statusid = $SisIYA_Config::statusids{'ok'};

	# read the template
	my $hp_xml_file = $SisIYA_Remote_Config::misc_dir.'/hp_locfg_get_embedded_health.xml';
	my $hp_xml_str = '';
	if ($version >= 3) {
		$hp_xml_str = '<RIBCL VERSION="2.22"><LOGIN USER_LOGIN="__USERNAME__" PASSWORD="__PASSWORD__"><SERVER_INFO MODE="read"><GET_EMBEDDED_HEALTH><GET_ALL_FANS/><GET_ALL_TEMPERATURES/><GET_ALL_POWER_SUPPLIES/><GET_ALL_VRM/><GET_ALL_PROCESSORS/><GET_ALL_MEMORY/><GET_ALL_NICS/><GET_ALL_STORAGE/><GET_ALL_HEALTH_STATUS/><GET_ALL_FIRMWARE_VERSIONS/></GET_EMBEDDED_HEALTH></SERVER_INFO></LOGIN></RIBCL>'; 
	} else {
		$hp_xml_str = '<RIBCL VERSION="2.21"><LOGIN USER_LOGIN="__USERNAME__" PASSWORD="__PASSWORD__"><SERVER_INFO MODE="read"><GET_EMBEDDED_HEALTH /></SERVER_INFO></LOGIN></RIBCL>'; 
	}

	#if (open(my $file, '<', $hp_xml_file)) {
	#		$hp_xml_str = <$file>;
	#		close($file);
	#}
	# substitute credatials
	$hp_xml_str =~ s/__USERNAME__/$username/; 
	$hp_xml_str =~ s/__PASSWORD__/$password/; 

	my $template = $check_name.'XXXXXX'; # trailing Xs are changed
	my $hp_input_file = File::Temp->new(TEMPLATE => $template, DIR => $SisIYA_Remote_Config::tmp_dir, UNLINK => 1, SUFFIX => '.dat' );
	
	print { $hp_input_file } $hp_xml_str;
	$hp_input_file->close;

	#if (open(my $file, '<', $hp_input_file)) {
	#	while (<$file>) { print STDERR $_; }
	#	close($file);
	#}	
	#print STDERR "Temp file :".$hp_input_file->filename ."\n"; 	# or just $hp_input_file 
	#print STDERR "xml string : ".$hp_xml_str."\n\n";	

	chomp(my @result_str = `"$SisIYA_Remote_Config::utils_dir/hp_locfg.pl" -s $hostname -f $hp_input_file`);

#	my @result_str;
#	if ($system_name ne 'sanal08-ue-9') {
#		chomp(@result_str = `"$SisIYA_Remote_Config::utils_dir/hp_locfg.pl" -s $hostname -f $hp_input_file`);
#	} else {
#		open(my $file, '<', '/root/hp/sample_scripts/a2_6_disk_cikarildi.xml');
#		@result_str = <$file>;
#		close($file);
#	}

	# parse the result XML
	my $a = (split('GET_EMBEDDED_HEALTH_DATA', join(' ', @result_str)))[1];
	$a =~ s/\r|\n//g;
	$a = '<?xml version="1.0"?><GET_EMBEDDED_HEALTH_DATA'.$a."GET_EMBEDDED_HEALTH_DATA>";
	my $x = new XML::Simple;
	my $r = $x->XMLin($a);
	### print STDERR Dumper($r);
	
	my $s = '';
	if ($version >= 3) {
		$s = check_hpilo4_system($expire, $r);
		$s .= check_hpilo4_raid($expire, $r);
		$s .= check_hpilo4_powersupply($expire, $r);
		$s .= check_hpilo4_fans($expire, $r);
		$s .= check_hpilo4_temperature($expire, $r);
		$s .= check_hpilo4_ram($expire, $r);
		$s .= check_hpilo4_cpu($expire, $r);
	} else {
		$s .= check_hpilo2_powersupply($expire, $r);
		$s .= check_hpilo2_fans($expire, $r);
		$s .= check_hpilo2_temperature($expire, $r);
	}
	return "<system><name>$system_name</name>$s</system>";
}

if (lock_check($check_name) == 0) {
	print STDERR "Could not get lock for $check_name! The script must be running!\n";
	exit 1;
}
my ($systems_file, $expire) = @ARGV;
my $serviceid = get_serviceid('raid');
my $xml = new XML::Simple;
my $data = $xml->XMLin($systems_file);
my $xml_str = '';

if( ref($data->{'record'}) eq 'ARRAY' ) {
	foreach my $h (@{$data->{'record'}}) {
		$xml_str .= check_hpilo($h->{'isactive'}, $serviceid, $expire, $h->{'system_name'}, $h->{'hostname'}, $h->{'username'}, $h->{'password'}, $h->{'version'});
	}
}
else {
	$xml_str = check_hpilo($data->{'record'}->{'isactive'}, $serviceid, $expire, $data->{'record'}->{'system_name'}, 
				$data->{'record'}->{'hostname'}, $data->{'record'}->{'username'}, $data->{'record'}->{'password'}, $data->{'record'}->{'version'});
}

unlock_check($check_name);
print $xml_str;
