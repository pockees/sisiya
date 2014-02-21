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

my $check_name = 'printer';

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
	'device_status' 	=> 'iso.3.6.1.2.1.25.3.2.1.5.1',	# HOST-RESOURCES-MIB::hrDeviceStatus 
	'printer_status'	=> 'iso.3.6.1.2.1.25.3.5.1.1.1',	# HOST-RESOURCES-MIB::hrPrinterStatus 
	'printer_state' 	=> 'iso.3.6.1.2.1.25.3.5.1.2.1'		# HOST-RESOURCES-MIB::hrPrinterDetectedERRORState 
);
our @pages = (
	{'name' => 'engine',		'mib' => '1.3.6.1.4.1.11.2.3.9.4.2.1.4.1.2.5.0'},
	{'name' => 'duplex',		'mib' => '1.3.6.1.4.1.11.2.3.9.4.2.1.4.1.2.22'},
	{'name' => 'pcl', 		'mib' => '1.3.6.1.4.1.11.2.3.9.4.2.1.3.3.3.5'},
	{'name' => 'postscript',	'mib' => '1.3.6.1.4.1.11.2.3.9.4.2.1.3.3.4.5'},
	{'name' => 'color',		'mib' => '1.3.6.1.4.1.11.2.3.9.4.2.1.4.1.2.7.0'},
	{'name' => 'mono',		'mib' => '1.3.6.1.4.1.11.2.3.9.4.2.1.4.1.2.6.0'},
	{'name' => 'pagecount',		'mib' => '1.3.6.1.2.1.43.10.2.1.4.1.1'}
);
# push @pages, {'name' => 'engine',            'mib' => '1.3.6.1.4.1.11.2.3.9.4.2.1.4.1.2.5.0'}; 
# One can override there default values in the $SisIYA_RemoteConfig::conf_dir/printer_system_$system_name.pl
# end of default values
############################################################################################################
sub check_printer_device
{
	my ($expire, $hostname, $snmp_version, $community, $username, $password) = @_;
	my $serviceid = get_serviceid('printer');
	my $statusid = $SisIYA_Config::statusids{'ok'};
	my $s = '';
	my $device_status = get_snmp_value('-OvQe', $hostname, $snmp_version, $community, $mibs{'device_status'});
	if ($device_status eq '') {
		return '';
	}
	my $printer_status = get_snmp_value('-OvQe', $hostname, $snmp_version, $community, $mibs{'printer_status'});
	my $printer_state = get_snmp_value('-OvQe', $hostname, $snmp_version, $community, $mibs{'printer_state'});
	#print STDERR "device_status=[$device_status] printer_status=[$printer_status] printer_state=[$printer_state]\n";
	if ($device_status == 1) { # unknown
		$statusid = $SisIYA_Config::statusids{'warning'};
		$s = 'WARNING: Device status is unknown!';
	} elsif ($device_status == 2) { # running
		if ($printer_status == 1) {
			$s = 'OK: The device is in standby state.';
		} elsif ($printer_status == 3) {
			$s = 'OK: The device is idle.';
		} elsif ($printer_status == 4) {
			$s = 'OK: The device is printing.';
		} else {
			$statusid = $SisIYA_Config::statusids{'warning'};
			$s = "WARNING: Unknown device status! device_status=[$device_status] printer_status=[$printer_status] printer_state=[$printer_state]";
		}
	} elsif ($device_status == 3) { # warning
		$statusid = $SisIYA_Config::statusids{'warning'};
		if ($printer_state eq '" "') { 
			$s = 'WARNING: Low toner!';
		} elsif ($printer_state eq ' 80 ') { 
			$s = 'WARNING: No paper!';
		} elsif ($printer_state eq ' A0 ') { 
			$s = 'WARNING: No paper!';
		} else {
			$s = "WARNING: Unknown state = [$printer_state]!";
		}
		$s .= ' Device status is ';
		if ($printer_status == 1) {
			$s .= 'other.';
		} elsif ($printer_status == 2) {
			$s .= 'unknown.';
		} elsif ($printer_status == 3) {
			$s .= 'idle.';
		} elsif ($printer_status == 4) {
			$s .= 'printing.';
		} elsif ($printer_status == 5) {
			$s .= 'warmup.';
		} else {
			$s = "WARNING: Unknown device status! device_status=[$device_status] printer_status=[$printer_status] printer_state=[$printer_state]";
		}
	} elsif ($device_status == 4) { # testing
		$statusid = $SisIYA_Config::statusids{'warning'};
		$s = "WARNING: The device is testing! device_status=[$device_status] printer_status=[$printer_status] printer_state=[$printer_state]";
	} elsif ($device_status == 5) { # down
		$statusid = $SisIYA_Config::statusids{'error'};
		if (($printer_state eq ' "@"') || ($printer_state eq '"@"')) { 
			$s = 'ERROR: No paper!';
		} elsif ($printer_state eq ' 01 ') { 
			$s = 'ERROR: Warming up!';
		} elsif ($printer_state eq ' 08 ') { 
			$s = 'ERROR: Cover or door is open!';
		} elsif ($printer_state eq ' """') { 
			$s = 'ERROR: Toner is almost empty?!';
		} else {
			$s = "ERROR: Unknown device state! device_status=[$device_status] printer_status=[$printer_status] printer_state=[$printer_state]";
		}
		$s .= ' Device status is ';
		if ($printer_status == 1) {
			$s .= 'other.';
		} elsif ($printer_status == 2) {
			$s .= 'unknown.';
		} elsif ($printer_status == 3) {
			$s .= 'idle.';
		} elsif ($printer_status == 4) {
			$s .= 'printing.';
		} elsif ($printer_status == 5) {
			$s .= 'warmup.';
		} else {
			$s = "WARNING: Unknown device status! device_status=[$device_status] printer_status=[$printer_status] printer_state=[$printer_state]";
		}
	} else {
		$statusid = $SisIYA_Config::statusids{'warning'};
		$s = "WARNING: Undermined device status! device_status=[$device_status] printer_status=[$printer_status] printer_state=[$printer_state]";
	}
	return "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message>";
}

sub check_printer_page_counts
{
	my ($expire, $hostname, $snmp_version, $community, $username, $password) = @_;
	my $serviceid = get_serviceid('printer_pagecounts');
	my $statusid = $SisIYA_Config::statusids{'info'};
	my $s = '';
	my $n;

	if ($#pages == -1) {
		return '';
	}
	for my $i (0..$#pages) {
		#print STDERR "Checking $pages[$i]{'name'} $pages[$i]{'mib'} ...\n";
		$n = get_snmp_value('-OvQe', $hostname, $snmp_version, $community, $pages[$i]{'mib'});
		#print STDERR "$pages[$i]{'name'} = [$s]\n";
		if ($n ne '') {
			$s .= "Total number of $pages[$i]{'name'} pages is $n."; 
		}
	}
	if ($s eq '') {
		return '';
	}
	return "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message>";
}


sub check_printer
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
	$s .= check_printer_device($expire, $hostname, $snmp_version, $community, $username, $password);
	$s .= check_printer_page_counts($expire, $hostname, $snmp_version, $community, $username, $password);

	if ($s eq '') {
		return '';
	}
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
if (ref($data->{'record'}) eq 'ARRAY' ) {
	foreach my $h (@{$data->{'record'}}) {
		$xml_str .= check_printer($h->{'isactive'}, $expire, $h->{'system_name'}, $h->{'hostname'}, 
					$h->{'snmp_version'}, $h->{'community'}, $h->{'username'}, $h->{'password'});
	}
} else {
	$xml_str = check_printer($data->{'record'}->{'isactive'}, $expire, $data->{'record'}->{'system_name'}, 
				$data->{'record'}->{'hostname'}, $data->{'record'}->{'snmp_version'}, $data->{'record'}->{'community'},
				$data->{'record'}->{'username'}, $data->{'record'}->{'password'});
}
unlock_check($check_name);
print $xml_str;
