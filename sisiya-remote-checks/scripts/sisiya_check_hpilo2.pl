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
require File::Temp;
use File::Temp();
#use Data::Dumper;

my $check_name = 'hpilo2';

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

sub check_hpilo_fans
{
	my ($expire, @a) = @_;
	my $serviceid = get_serviceid('fanspeed');
	my $statusid = $SisIYA_Config::statusids{'ok'};
	my $ok_str = '';
	my $error_str = '';
	my $s = '';
	
	my $status_str = trim((split(/"/, (grep(/FANS STATUS/, @a))[0]))[1]);
	if ($status_str eq 'OK') {
		$ok_str = " OK: Fans status is $status_str.";
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$error_str = " ERROR: Fans status is $status_str (!= OK)!";
	}
	$status_str = trim((split(/"/, (grep(/FANS REDUNDANCY/, @a))[0]))[1]);
	if ($status_str eq 'Redundant') {
		$ok_str .= " OK: Fans redundancy is $status_str.";
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$error_str .= " ERROR: Fans redundancy is $status_str (!= Redundndant)!";
	}
	$s = $error_str.$ok_str;

	return "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message>";
}

sub check_hpilo_powersupply
{
	my ($expire, @a) = @_;
	my $serviceid = get_serviceid('powersupply');
	my $statusid = $SisIYA_Config::statusids{'ok'};
	my $ok_str = '';
	my $error_str = '';
	my $s = '';
	
	my $status_str = trim((split(/"/, (grep(/POWER_SUPPLIES STATUS/, @a))[0]))[1]);
	if ($status_str eq 'OK') {
		$ok_str = " OK: Power supply status is $status_str.";
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$error_str = " ERROR: Power supply status is $status_str (!= OK)!";
	}
	$status_str = trim((split(/"/, (grep(/POWER_SUPPLIES REDUNDANCY/, @a))[0]))[1]);
	if ($status_str eq 'Redundant') {
		$ok_str .= " OK: Power supply redundancy is $status_str.";
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$error_str .= " ERROR: Power supply redundancy is $status_str (!= Redundndant)!";
	}
	$s = $error_str.$ok_str;

	return "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message>";
}

sub check_hpilo_ram
{
	my ($expire, @a) = @_;
	my $serviceid = get_serviceid('ram');
	my $statusid;
	my $s = '';

	my $status_str = trim((split(/"/, (grep(/MEMORY STATUS/, @a))[0]))[1]);
	if ($status_str eq 'OK') {
		$statusid = $SisIYA_Config::statusids{'ok'};
		$s = " OK: RAM status is $status_str.";
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$s = " ERROR: RAM status is $status_str (!= OK)!";
	}

	return "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message>";
}

sub check_hpilo_cpu
{
	my ($expire, @a) = @_;
	my $serviceid = get_serviceid('cpu');
	my $statusid;
	my $s = '';

	my $status_str = trim((split(/"/, (grep(/PROCESSOR STATUS/, @a))[0]))[1]);
	if ($status_str eq 'OK') {
		$statusid = $SisIYA_Config::statusids{'ok'};
		$s = " OK: CPU status is $status_str.";
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$s = " ERROR: CPU status is $status_str (!= OK)!";
	}

	return "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message>";
}

sub check_hpilo_temperature
{
	my ($expire, @a) = @_;
	my $serviceid = get_serviceid('temperature');
	my $statusid;
	my $s = '';

	my $status_str = trim((split(/"/, (grep(/TEMPERATURE STATUS/, @a))[0]))[1]);
	if ($status_str eq 'OK') {
		$statusid = $SisIYA_Config::statusids{'ok'};
		$s = " OK: Temperature status is $status_str.";
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$s = " ERROR: Temperature status is $status_str (!= OK)!";
	}

	return "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message>";
}


sub check_hpilo_raid
{
	my ($expire, @a) = @_;
	my $serviceid = get_serviceid('raid');
	my $statusid;
	my $s = '';

	my $status_str = trim((split(/"/, (grep(/STORAGE STATUS/, @a))[0]))[1]);
	if ($status_str eq 'OK') {
		$statusid = $SisIYA_Config::statusids{'ok'};
		$s = " OK: RAID status is $status_str.";
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$s = " ERROR: RAID status is $status_str (!= OK)!";
	}

	return "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message>";
}


sub check_hpilo_system
{
	my ($expire, @a) = @_;
	my $serviceid = get_serviceid('system');
	my $statusid = $SisIYA_Config::statusids{'ok'};
	my $ok_str = '';
	my $error_str = '';
	my $s = '';

	my $status_str = trim((split(/"/, (grep(/BIOS_HARDWARE STATUS/, @a))[0]))[1]);
	if ($status_str eq 'OK') {
		$ok_str = " OK: BIOS hardware status is $status_str.";
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$error_str = " ERROR: BIOS hardware status is $status_str (!= OK)!";
	}
	$status_str = trim((split(/"/, (grep(/NETWORK STATUS/, @a))[0]))[1]);
	if ($status_str eq 'OK') {
		$ok_str .= " OK: Network status is $status_str.";
	} else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$error_str .= " ERROR: Network status is $status_str (!= OK)!";
	}
	$s = $error_str.$ok_str;


	return "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message>";
}

sub check_hpilo
{
	my ($isactive, $serviceid, $expire, $system_name, $hostname, $username, $password) = @_;

	if ($isactive eq 'f' ) {
		return '';
	}

	print STDERR "Checking system_name=[$system_name] hostname=[$hostname] isactive=[$isactive] username=[$username] ...\n";
	my $statusid = $SisIYA_Config::statusids{'ok'};

	# read the template
	my $hp_xml_file = $SisIYA_Remote_Config::misc_dir.'/hp_locfg_get_embedded_health.xml';
	#my $hp_xml_str = '';
	my $hp_xml_str = '<RIBCL VERSION="2.22"><LOGIN USER_LOGIN="__USERNAME__" PASSWORD="__PASSWORD__"><SERVER_INFO MODE="read"><GET_EMBEDDED_HEALTH><GET_ALL_FANS/><GET_ALL_TEMPERATURES/><GET_ALL_POWER_SUPPLIES/><GET_ALL_VRM/><GET_ALL_PROCESSORS/><GET_ALL_MEMORY/><GET_ALL_NICS/><GET_ALL_STORAGE/><GET_ALL_HEALTH_STATUS/><GET_ALL_FIRMWARE_VERSIONS/></GET_EMBEDDED_HEALTH></SERVER_INFO></LOGIN></RIBCL>'; 

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

	if (open(my $file, '<', $hp_input_file)) {
		while (<$file>) { print STDERR $_; }
		close($file);
	}	
	print STDERR "Temp file :".$hp_input_file->filename ."\n"; 	# or just $hp_input_file 
	print STDERR "xml string : ".$hp_xml_str."\n\n";	

	chomp(my @result_str = `"$SisIYA_Remote_Config::utils_dir/hp_locfg.pl" -s $hostname -f $hp_input_file`);
	print STDERR "Result: ".@result_str."\n";

	my $s = check_hpilo_system($expire, @result_str);
	$s .= check_hpilo_raid($expire, @result_str);
	$s .= check_hpilo_powersupply($expire, @result_str);
	$s .= check_hpilo_fans($expire, @result_str);
	$s .= check_hpilo_temperature($expire, @result_str);
	$s .= check_hpilo_ram($expire, @result_str);
	$s .= check_hpilo_cpu($expire, @result_str);
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
		$xml_str .= check_hpilo($h->{'isactive'}, $serviceid, $expire, $h->{'system_name'}, $h->{'hostname'}, $h->{'username'}, $h->{'password'});
	}
}
else {
	$xml_str = check_hpilo($data->{'record'}->{'isactive'}, $serviceid, $expire, $data->{'record'}->{'system_name'}, 
				$data->{'record'}->{'hostname'}, $data->{'record'}->{'username'}, $data->{'record'}->{'password'});
}

unlock_check($check_name);
print $xml_str;
