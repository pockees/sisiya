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
use SisIYA_Remote_Config;
use XML::Simple;
#use Data::Dumper;

if( $#ARGV != 1 ) {
	print "Usage : $0 ups_netagent_systems.xml expire\n";
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
	'firmware' 			=> 'SNMPv2-SMI::enterprises.935.1.1.1.1.2.4.0'
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
	'input_voltage_lower'		=> { 'warning' => 205,	'error' => 200 },	# in voltage
	'input_voltage_upper'		=> { 'warning' => 235,	'error' => 240 },	# in volatge
	'output_voltage_lower'		=> { 'warning' => 205,	'error' => 200 },	# in voltage
	'output_voltage_upper'		=> { 'warning' => 235,	'error' => 240 },	# in voltage
	'estimated_time_on_battery'	=> { 'warning' => 600,	'error' => 300 },	# in minutes
	'time_on_battery' 		=> { 'warning' => 600,	'error' => 300 }	# in minutes
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

	return "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$error_str $warning_str $ok_str</msg><datamsg></datamsg></data></message>";
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
	return "<system><name>$system_name</name>$s</system>";
}

my ($systems_file, $expire) = @ARGV;
my $xml = new XML::Simple;
my $data = $xml->XMLin($systems_file);
my $xml_str = '';
#print STDERR Dumper($data);
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
#print STDERR $xml_str;
print $xml_str;
