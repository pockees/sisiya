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
use SisIYA_Remote_Config;
use XML::Simple;
#use Data::Dumper;

my $check_name = 'ups_netagent';

if( $#ARGV != 1 ) {
	print "Usage : $0 ".$check_name."_systems.xml expire\n";
	print "The expire parameter must be given in minutes.\n";
	exit 1;
}

if(-f $SisIYA_Remote_Config::local_conf) {
	require $SisIYA_Remote_Config::local_conf;
}
#if(-f $SisIYA_Remote_Config::client_conf) {
#	require $SisIYA_Remote_Config::client_conf;
#}
if(-f $SisIYA_Remote_Config::client_local_conf) {
	require $SisIYA_Remote_Config::client_local_conf;
}
if(-f $SisIYA_Config::functions) {
	require $SisIYA_Config::functions;
}
if(-f $SisIYA_Remote_Config::functions) {
	require $SisIYA_Remote_Config::functions;
}

###########################################################################################################
# default values
our %uptimes = ('error' => 1440, 'warning' => 4320);
our %mibs = (
	'battery_capacity'		=> 'SNMPv2-SMI::enterprises.935.1.1.1.2.2.1.0',
	'battery_replacement_status'	=> '1.3.6.1.4.1.318.1.1.1.2.2.4.0',
	'battery_status'		=> 'SNMPv2-SMI::mib-2.33.1.2.1.0',
	'estimated_time_on_battery'	=> 'SNMPv2-SMI::enterprises.935.1.1.1.2.2.4.0',
	'firmware' 			=> 'SNMPv2-SMI::enterprises.935.1.1.1.1.2.4.0',
	'time_spend_on_battery'		=> 'SNMPv2-SMI::enterprises.935.1.1.1.2.1.2.0',
	'ups_input_ac_status'		=> 'SNMPv2-SMI::enterprises.935.1.1.1.3.1.1.0',
	'ups_input_frequency'		=> 'SNMPv2-SMI::enterprises.935.1.1.1.4.2.2.0',
	'ups_input_voltage'		=> 'SNMPv2-SMI::enterprises.935.1.1.1.3.2.1.0',
	'ups_output_frequency'		=> 'SNMPv2-SMI::enterprises.935.1.1.1.4.2.2.0',
	'ups_output_load'		=> 'SNMPv2-SMI::enterprises.935.1.1.1.4.2.3.0',
	'ups_output_status'		=> 'SNMPv2-SMI::enterprises.935.1.1.1.4.1.1.0',
	'ups_output_voltage'		=> 'SNMPv2-SMI::enterprises.935.1.1.1.4.2.1.0',
	'ups_status'			=> 'SNMPv2-SMI::enterprises.935.1.1.1.4.1.1.0'
);
our @tsensors = (
	{ 'name' => 'internal', 'warning' => 30, 'error' => 35, 'mib' => 'SNMPv2-SMI::enterprises.935.1.1.1.2.1.2.0' },
	{ 'name' => 'external', 'warning' => 30, 'error' => 35, 'mib' => 'SNMPv2-SMI::enterprises.318.1.1.10.2.3.2.1.4.1' }
);
our %thresholds = (
	'battery_capacity' 		=> { 'warning' => 90,	'error' => 85 },	# in capacity
	'input_frequency_lower'		=> { 'warning' => 47,	'error' => 40 },	# in Hz
	'input_frequency_upper'		=> { 'warning' => 53,	'error' => 60 },	# in Hz
	'output_frequency_lower'	=> { 'warning' => 47,	'error' => 40 },	# in Hz
	'output_frequency_upper'	=> { 'warning' => 53,	'error' => 60 },	# in Hz
	'output_load' 			=> { 'warning' => 45,	'error' => 50 },	# in %
	'input_voltage_lower'		=> { 'warning' => 205,	'error' => 200 },	# in voltage
	'input_voltage_upper'		=> { 'warning' => 235,	'error' => 240 },	# in volatge
	'output_voltage_lower'		=> { 'warning' => 205,	'error' => 200 },	# in voltage
	'output_voltage_upper'		=> { 'warning' => 235,	'error' => 240 },	# in voltage
	'estimated_time_on_battery'	=> { 'warning' => 600,	'error' => 300 },	# in minutes
	'time_spend_on_battery' 	=> { 'warning' => 600,	'error' => 300 }	# in minutes
);
# One can override there default values in the $SisIYA_RemoteConfig::conf_dir/printer_system_$system_name.pl
# end of default values
############################################################################################################
sub check_ups_battery_capacity
{
	my ($statusid_ref, $error_str_ref, $warning_str_ref, $ok_str_ref, $hostname, $snmp_version, $community, $username, $password) = @_;

	my $s = get_snmp_value('-OvQ', $hostname, $snmp_version, $community, $mibs{'battery_capacity'}, $username, $password);
	if ($s eq '') {
		return;
	}
	
	my $capacity = $s;
	if ($capacity <= $thresholds{'battery_capacity'}{'error'}) {
		$$statusid_ref = $SisIYA_Config::statusids{'error'};
		$$error_str_ref .= " ERROR: The total battery capacity is $capacity (<= $thresholds{'battery_capacity'}{'error'})!";
	} elsif ($capacity <= $thresholds{'battery_capacity'}{'warning'}) {
		if ($$statusid_ref < $SisIYA_Config::statusids{'warning'}) {
			$$statusid_ref = $SisIYA_Config::statusids{'warning'};
		}
		$$warning_str_ref .= " WARNING: The total battery capacity is $capacity (<= $thresholds{'battery_capacity'}{'warning'})!";
	} else {
		$$ok_str_ref .= " OK: The total battery capacity is $capacity.";
	}
}

sub check_ups_battery_status
{
	my ($statusid_ref, $error_str_ref, $warning_str_ref, $ok_str_ref, $hostname, $snmp_version, $community, $username, $password) = @_;

	my $s = get_snmp_value('-OvQ', $hostname, $snmp_version, $community, $mibs{'battery_status'}, $username, $password);
	if ($s eq '') {
		return '';
	}
	my $status = $s;
	if ($status == 1) {
		$$statusid_ref = $SisIYA_Config::statusids{'error'};
		$$error_str_ref .= " ERROR: The battery status is unknown!";
	} elsif ($status == 2) {
		$$ok_str_ref .= " OK: The battery status is normal.";
	} elsif ($status == 3) {
		if ($$statusid_ref < $SisIYA_Config::statusids{'warning'}) {
			$$statusid_ref = $SisIYA_Config::statusids{'warning'};
		}
		$$warning_str_ref .= " WARNING: The battery status is low!";
	} else {
		$$statusid_ref = $SisIYA_Config::statusids{'error'};
		$$error_str_ref .= " ERROR: Unknown battery status = $status!";
	}
}

sub check_ups_battery_replacement_status
{
	my ($statusid_ref, $error_str_ref, $warning_str_ref, $ok_str_ref, $hostname, $snmp_version, $community, $username, $password) = @_;

	my $s = get_snmp_value('-OvQ', $hostname, $snmp_version, $community, $mibs{'battery_replacement_status'}, $username, $password);
	if ($s eq '') {
		return '';
	}
	my $status = $s;
	if  (grep(/No such object available/i, $s)) {
		return '';
	}
	if ($status == 1) {
		$$ok_str_ref .= " OK: The battery does not need replacement.";
	} elsif ($status == 3) {
		if ($$statusid_ref < $SisIYA_Config::statusids{'warning'}) {
			$$statusid_ref = $SisIYA_Config::statusids{'warning'};
		}
		$$warning_str_ref .= " WARNING: The battery needs replacement!";
	} else {
		$$statusid_ref = $SisIYA_Config::statusids{'error'};
		$$error_str_ref .= " ERROR: Unknown battery replacement status = $status!";
	}
}

sub check_ups_estimated_time_on_battery
{
	my ($statusid_ref, $error_str_ref, $warning_str_ref, $ok_str_ref, $hostname, $snmp_version, $community, $username, $password) = @_;

	my $s = get_snmp_value('-OvQ', $hostname, $snmp_version, $community, $mibs{'estimated_time_on_battery'}, $username, $password);
	if ($s eq '') {
		return;
	}
	my $time = $s;
	if ($time == 0) {
		$$ok_str_ref .= 'OK: The estimated time on battery is 0. The UPS must be online.';
	} else {
		if ($time <= $thresholds{'estimated_time_on_battery'}{'error'}) {
			$$statusid_ref = $SisIYA_Config::statusids{'error'};
			$$error_str_ref .= "ERROR: The estimated time on battery is $time (<= $thresholds{'estimated_time_on_battery'}{'error'})!";
		} elsif ($time <= $thresholds{'estimated_time_on_battery'}{'warning'}) {
			if ($$statusid_ref < $SisIYA_Config::statusids{'warning'}) {
				$$statusid_ref = $SisIYA_Config::statusids{'warning'};
			}
			$$warning_str_ref .= "WARNING: The estimated time on battery is $time (<= $thresholds{'estimated_time_on_battery'}{'warning'})!";
		} else {
			$$ok_str_ref .= "OK: The estimated time on battery is $time.";
		}
	}
}

sub check_ups_time_spend_on_battery
{
	my ($statusid_ref, $error_str_ref, $warning_str_ref, $ok_str_ref, $hostname, $snmp_version, $community, $username, $password) = @_;

	my $s = get_snmp_value('-OvQ', $hostname, $snmp_version, $community, $mibs{'time_spend_on_battery'}, $username, $password);
	if ($s eq '') {
		return;
	}
	my $time = $s;
	if ($time == 0) {
		$$ok_str_ref .= ' OK: The time spend on battery is 0. The UPS must be online.';
	} else {
		if ($time <= $thresholds{'time_spend_on_battery'}{'error'}) {
			$$statusid_ref = $SisIYA_Config::statusids{'error'};
			$$error_str_ref .= " ERROR: The time spend on battery is $time (<= $thresholds{'time_spend_on_battery'}{'error'})!";
		} elsif ($time <= $thresholds{'time_spend_on_battery'}{'warning'}) {
			if ($$statusid_ref < $SisIYA_Config::statusids{'warning'}) {
				$$statusid_ref = $SisIYA_Config::statusids{'warning'};
			}
			$$warning_str_ref .= " WARNING: The time spend on battery is $time (<= $thresholds{'time_spend_on_battery'}{'warning'})!";
		} else {
			$$ok_str_ref .= " OK: The time spend on battery is $time.";
		}
	}
}


sub check_ups_battery
{
	my ($expire, $hostname, $snmp_version, $community, $username, $password) = @_;
	my $error_str = '';
	my $warning_str = '';
	my $ok_str = '';
	my $serviceid = get_serviceid('ups_battery');
	my $statusid = $SisIYA_Config::statusids{'ok'};

	check_ups_battery_capacity(\$statusid, \$error_str, \$warning_str, \$ok_str, $hostname, $snmp_version, $community, $username, $password);
	check_ups_battery_status(\$statusid, \$error_str, \$warning_str, \$ok_str, $hostname, $snmp_version, $community, $username, $password);
	check_ups_battery_replacement_status(\$statusid, \$error_str, \$warning_str, \$ok_str, $hostname, $snmp_version, $community, $username, $password);

	return "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$error_str$warning_str$ok_str</msg><datamsg></datamsg></data></message>";
}

sub check_ups_battery_times
{
	my ($expire, $hostname, $snmp_version, $community, $username, $password) = @_;
	my $error_str = '';
	my $warning_str = '';
	my $ok_str = '';
	my $serviceid = get_serviceid('ups_timeonbattery');
	my $statusid = $SisIYA_Config::statusids{'ok'};

	check_ups_estimated_time_on_battery(\$statusid, \$error_str, \$warning_str, \$ok_str, $hostname, $snmp_version, $community, $username, $password);
	check_ups_time_spend_on_battery(\$statusid, \$error_str, \$warning_str, \$ok_str, $hostname, $snmp_version, $community, $username, $password);

	return "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$error_str$warning_str$ok_str</msg><datamsg></datamsg></data></message>";
}

sub check_ups_status
{
	my ($expire, $hostname, $snmp_version, $community, $username, $password) = @_;
	my $serviceid = get_serviceid('ups_status');
	my $statusid = $SisIYA_Config::statusids{'error'};

	my $s = get_snmp_value('-OvQ', $hostname, $snmp_version, $community, $mibs{'ups_status'}, $username, $password);
	if ($s eq '') {
		return;
	}
	my $status = $s;
	if ($status == 1) {
		$s = "ERROR: The UPS status is unknown!";
	} elsif ($status == 2) {
		$statusid = $SisIYA_Config::statusids{'ok'};
		$s = "OK: The UPS is online.";
	} elsif ($status == 3) {
		$statusid = $SisIYA_Config::statusids{'warning'};
		$s = "WARNING: The UPS status is battery!";
	} elsif ($status == 4) {
		$s = "ERROR: The UPS is on smart boost!";
	} elsif ($status == 5) {
		$s = "ERROR: The UPS is timed sleeping!";
	} elsif ($status == 6) {
		$s = "ERROR: The UPS is on software bypass!";
	} elsif ($status == 7) {
		$s = "ERROR: The UPS is rebooting!";
	} elsif ($status == 8) {
		$s = "ERROR: The UPS is standby!";
	} elsif ($status == 9) {
		$s = "ERROR: The UPS is on buck!";
	} else {
		$s = "ERROR: The UPS status=$status is unknown!";
	}

	return "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message>";
}

sub check_ups_input_ac_status
{
	my ($statusid_ref, $error_str_ref, $warning_str_ref, $ok_str_ref, $hostname, $snmp_version, $community, $username, $password) = @_;

	my $s = get_snmp_value('-OvQ', $hostname, $snmp_version, $community, $mibs{'ups_input_ac_status'}, $username, $password);
	if ($s eq '') {
		return '';
	}
	if ($s == 1) {
		$$ok_str_ref .= "OK: The AC status in normal.";
	} else {
		$$statusid_ref = $SisIYA_Config::statusids{'error'};
		$$error_str_ref .= "ERROR: Unknown AC status = $s!";
	}
}

sub check_ups_input_voltage
{
	my ($statusid_ref, $error_str_ref, $warning_str_ref, $ok_str_ref, $hostname, $snmp_version, $community, $username, $password) = @_;

	my $s = get_snmp_value('-OvQ', $hostname, $snmp_version, $community, $mibs{'ups_input_voltage'}, $username, $password);
	if ($s eq '') {
		return '';
	}
	my $v = $s / 10;
	if ($v >= $thresholds{'input_voltage_upper'}{'error'}) {
		$$statusid_ref = $SisIYA_Config::statusids{'error'};
		$$error_str_ref .= "ERROR: The input voltage is ".$v."V (>= $thresholds{'input_voltage_upper'}{'error'})!";
	} elsif ($v <= $thresholds{'input_voltage_lower'}{'error'}) {
		$$statusid_ref = $SisIYA_Config::statusids{'error'};
		$$error_str_ref .= "ERROR: The input voltage is ".$v."V (<= $thresholds{'input_voltage_lower'}{'error'})!";
	} elsif ($v >= $thresholds{'input_voltage_upper'}{'warning'}) {
		if ($$statusid_ref < $SisIYA_Config::statusids{'warning'}) {
			$$statusid_ref = $SisIYA_Config::statusids{'warning'};
		}
		$$warning_str_ref .= "WARNING: The input voltage is ".$v."V (>= $thresholds{'input_voltage_upper'}{'warning'})!";
	} elsif ($v <= $thresholds{'input_voltage_lower'}{'warning'}) {
		if ($$statusid_ref < $SisIYA_Config::statusids{'warning'}) {
			$$statusid_ref = $SisIYA_Config::statusids{'warning'};
		}
		$$warning_str_ref .= "WARNING: The input voltage is ".$v."V (<= $thresholds{'input_voltage_lower'}{'warning'})!";
	} else {
		$$ok_str_ref .= "OK: The input voltage is ".$v."V.";
	}
}

sub check_ups_input_frequency
{
	my ($statusid_ref, $error_str_ref, $warning_str_ref, $ok_str_ref, $hostname, $snmp_version, $community, $username, $password) = @_;

	my $s = get_snmp_value('-OvQ', $hostname, $snmp_version, $community, $mibs{'ups_input_frequency'}, $username, $password);
	if ($s eq '') {
		return '';
	}
	my $v = $s / 10;
	if ($v >= $thresholds{'input_frequency_upper'}{'error'}) {
		$$statusid_ref = $SisIYA_Config::statusids{'error'};
		$$error_str_ref .= "ERROR: The input frequency is ".$v."Hz (>= $thresholds{'input_frequency_upper'}{'error'})!";
	} elsif ($v <= $thresholds{'input_frequency_lower'}{'error'}) {
		$$statusid_ref = $SisIYA_Config::statusids{'error'};
		$$error_str_ref .= "ERROR: The input frequency is ".$v."Hz (<= $thresholds{'input_frequency_lower'}{'error'})!";
	} elsif ($v >= $thresholds{'input_frequency_upper'}{'warning'}) {
		if ($$statusid_ref < $SisIYA_Config::statusids{'warning'}) {
			$$statusid_ref = $SisIYA_Config::statusids{'warning'};
		}
		$$warning_str_ref .= "WARNING: The input frequency is ".$v."Hz (>= $thresholds{'input_frequency_upper'}{'warning'})!";
	} elsif ($v <= $thresholds{'input_frequency_lower'}{'warning'}) {
		if ($$statusid_ref < $SisIYA_Config::statusids{'warning'}) {
			$$statusid_ref = $SisIYA_Config::statusids{'warning'};
		}
		$$warning_str_ref .= "WARNING: The input frequency is ".$v."Hz (<= $thresholds{'input_frequency_lower'}{'warning'})!";
	} else {
		$$ok_str_ref .= "OK: The input frequency is ".$v."Hz.";
	}
}


sub check_ups_input
{
	my ($expire, $hostname, $snmp_version, $community, $username, $password) = @_;
	my $error_str = '';
	my $warning_str = '';
	my $ok_str = '';
	my $serviceid = get_serviceid('ups_input');
	my $statusid = $SisIYA_Config::statusids{'ok'};

	check_ups_input_ac_status(\$statusid, \$error_str, \$warning_str, \$ok_str, $hostname, $snmp_version, $community, $username, $password);
	check_ups_input_voltage(\$statusid, \$error_str, \$warning_str, \$ok_str, $hostname, $snmp_version, $community, $username, $password);
	check_ups_input_frequency(\$statusid, \$error_str, \$warning_str, \$ok_str, $hostname, $snmp_version, $community, $username, $password);

	return "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$error_str$warning_str$ok_str</msg><datamsg></datamsg></data></message>";
}

sub check_ups_output_load
{
	my ($statusid_ref, $error_str_ref, $warning_str_ref, $ok_str_ref, $hostname, $snmp_version, $community, $username, $password) = @_;

	my $s = get_snmp_value('-OvQ', $hostname, $snmp_version, $community, $mibs{'ups_output_load'}, $username, $password);
	if ($s eq '') {
		return '';
	}
	my $v = $s;
	if ($v >= $thresholds{'output_load'}{'error'}) {
		$$statusid_ref = $SisIYA_Config::statusids{'error'};
		$$error_str_ref .= "ERROR: The output load is ".$v."% (>= $thresholds{'output_load'}{'error'})!";
	} elsif ($v >= $thresholds{'output_load'}{'warning'}) {
		if ($$statusid_ref < $SisIYA_Config::statusids{'warning'}) {
			$$statusid_ref = $SisIYA_Config::statusids{'warning'};
		}
		$$warning_str_ref .= "WARNING: The load is ".$v."% (>= $thresholds{'output_load'}{'warning'})!";
	} else {
		$$ok_str_ref .= "OK: The output load is ".$v."%.";
	}
}

sub check_ups_output_voltage
{
	my ($statusid_ref, $error_str_ref, $warning_str_ref, $ok_str_ref, $hostname, $snmp_version, $community, $username, $password) = @_;

	my $s = get_snmp_value('-OvQ', $hostname, $snmp_version, $community, $mibs{'ups_output_voltage'}, $username, $password);
	if ($s eq '') {
		return '';
	}
	my $v = $s / 10;
	if ($v >= $thresholds{'output_voltage_upper'}{'error'}) {
		$$statusid_ref = $SisIYA_Config::statusids{'error'};
		$$error_str_ref .= "ERROR: The output voltage is ".$v."V (>= $thresholds{'output_voltage_upper'}{'error'})!";
	} elsif ($v <= $thresholds{'output_voltage_lower'}{'error'}) {
		$$statusid_ref = $SisIYA_Config::statusids{'error'};
		$$error_str_ref .= "ERROR: The output voltage is ".$v."V (<= $thresholds{'output_voltage_lower'}{'error'})!";
	} elsif ($v >= $thresholds{'output_voltage_upper'}{'warning'}) {
		if ($$statusid_ref < $SisIYA_Config::statusids{'warning'}) {
			$$statusid_ref = $SisIYA_Config::statusids{'warning'};
		}
		$$warning_str_ref .= "WARNING: The output voltage is ".$v."V (>= $thresholds{'output_voltage_upper'}{'warning'})!";
	} elsif ($v <= $thresholds{'output_voltage_lower'}{'warning'}) {
		if ($$statusid_ref < $SisIYA_Config::statusids{'warning'}) {
			$$statusid_ref = $SisIYA_Config::statusids{'warning'};
		}
		$$warning_str_ref .= "WARNING: The output voltage is ".$v."V (<= $thresholds{'output_voltage_lower'}{'warning'})!";
	} else {
		$$ok_str_ref .= "OK: The output voltage is ".$v."V.";
	}
}

sub check_ups_output_frequency
{
	my ($statusid_ref, $error_str_ref, $warning_str_ref, $ok_str_ref, $hostname, $snmp_version, $community, $username, $password) = @_;

	my $s = get_snmp_value('-OvQ', $hostname, $snmp_version, $community, $mibs{'ups_output_frequency'}, $username, $password);
	if ($s eq '') {
		return '';
	}
	my $v = $s / 10;
	if ($v >= $thresholds{'output_frequency_upper'}{'error'}) {
		$$statusid_ref = $SisIYA_Config::statusids{'error'};
		$$error_str_ref .= "ERROR: The output frequency is ".$v."Hz (>= $thresholds{'output_frequency_upper'}{'error'})!";
	} elsif ($v <= $thresholds{'output_frequency_lower'}{'error'}) {
		$$statusid_ref = $SisIYA_Config::statusids{'error'};
		$$error_str_ref .= "ERROR: The output frequency is ".$v."Hz (<= $thresholds{'output_frequency_lower'}{'error'})!";
	} elsif ($v >= $thresholds{'output_frequency_upper'}{'warning'}) {
		if ($$statusid_ref < $SisIYA_Config::statusids{'warning'}) {
			$$statusid_ref = $SisIYA_Config::statusids{'warning'};
		}
		$$warning_str_ref .= "WARNING: The output frequency is ".$v."Hz (>= $thresholds{'output_frequency_upper'}{'warning'})!";
	} elsif ($v <= $thresholds{'output_frequency_lower'}{'warning'}) {
		if ($$statusid_ref < $SisIYA_Config::statusids{'warning'}) {
			$$statusid_ref = $SisIYA_Config::statusids{'warning'};
		}
		$$warning_str_ref .= "WARNING: The output frequency is ".$v."Hz (<= $thresholds{'output_frequency_lower'}{'warning'})!";
	} else {
		$$ok_str_ref .= "OK: The output frequency is ".$v."Hz.";
	}
}



sub check_ups_output
{
	my ($expire, $hostname, $snmp_version, $community, $username, $password) = @_;
	my $error_str = '';
	my $warning_str = '';
	my $ok_str = '';
	my $serviceid = get_serviceid('ups_output');
	my $statusid = $SisIYA_Config::statusids{'ok'};

	check_ups_output_load(\$statusid, \$error_str, \$warning_str, \$ok_str, $hostname, $snmp_version, $community, $username, $password);
	check_ups_output_voltage(\$statusid, \$error_str, \$warning_str, \$ok_str, $hostname, $snmp_version, $community, $username, $password);
	check_ups_output_frequency(\$statusid, \$error_str, \$warning_str, \$ok_str, $hostname, $snmp_version, $community, $username, $password);

	return "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$error_str$warning_str$ok_str</msg><datamsg></datamsg></data></message>";
}


sub check_ups_netagent
{
	my ($isactive, $expire, $system_name, $hostname, $snmp_version, $community, $username, $password) = @_;

	if ($isactive eq 'f' ) {
		return '';
	}

	#print STDERR "Checking system_name=[$system_name] hostname=[$hostname] isactive=[$isactive] snmp_version=[$snmp_version] community=[$community] username=[$username] password=[$password]...\n";
	my $s = check_snmp_system($expire, $hostname, $snmp_version, $community, $username, $password);
	if ($s eq '') {
		return '';
	}
	$s .= check_ups_battery($expire, $hostname, $snmp_version, $community, $username, $password);
	$s .= check_ups_battery_times($expire, $hostname, $snmp_version, $community, $username, $password);
	$s .= check_ups_status($expire, $hostname, $snmp_version, $community, $username, $password);
	$s .= check_ups_input($expire, $hostname, $snmp_version, $community, $username, $password);
	$s .= check_ups_output($expire, $hostname, $snmp_version, $community, $username, $password);
	return "<system><name>$system_name</name>$s</system>";
}

my ($systems_file, $expire) = @ARGV;
my $xml = new XML::Simple;
my $data = $xml->XMLin($systems_file);
my $xml_str = '';
#print STDERR Dumper($data);
if (lock_check($check_name) == 0) {
	print STDERR "Could not get lock for $check_name! The script must be running!\n";
	exit 1;
}
if( ref($data->{'record'}) eq 'ARRAY' ) {
	foreach my $h (@{$data->{'record'}}) {
		$xml_str .= check_ups_netagent($h->{'isactive'}, $expire, $h->{'system_name'}, $h->{'hostname'}, 
					$h->{'snmp_version'}, $h->{'community'}, $h->{'username'}, $h->{'password'});
	}
}
else {
	$xml_str = check_ups_netagent($data->{'record'}->{'isactive'}, $expire, $data->{'record'}->{'system_name'}, 
				$data->{'record'}->{'hostname'}, $data->{'record'}->{'snmp_version'}, $data->{'record'}->{'community'},
				$data->{'record'}->{'username'}, $data->{'record'}->{'password'});
}
unlock_check($check_name);
print $xml_str;
