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

my $check_name = 'qnap';

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
	'storage'		=> '1.3.6.1.4.1.24681',			# whole storage tree
	'system_hd_table'	=> '1.3.6.1.4.1.24681.1.2.11',		# whole hd tree
	'hd_number'		=> '1.3.6.1.4.1.24681.1.2.10.0',	# number of hard disks
	'hd_index'		=> '1.3.6.1.4.1.24681.1.2.11.1.1.',	# add the disk number to get the index for hd_status, hd_model, hd_capacity ...
	'hd_status'		=> '1.3.6.1.4.1.24681.1.2.11.1.4.',	# add the disk number at the end
	'hd_descr'		=> '1.3.6.1.4.1.24681.1.2.11.1.2.',	# add the disk index
	'hd_capacity'		=> '1.3.6.1.4.1.24681.1.2.11.1.6.',	# add the disk index
	'hd_model'		=> '1.3.6.1.4.1.24681.1.2.11.1.5.',	# add the disk index
	'hd_temperature'	=> '1.3.6.1.4.1.24681.1.2.11.1.3.',	# add the disk index
	'hd_smart_info'		=> '1.3.6.1.4.1.24681.1.2.11.1.7.',	# add the disk index
);

# end of default values
############################################################################################################
sub get_snmp_value_from_array
{
	my ($search_str, @a) = @_;
	
	print STDERR "search str: $search_str\n";
	my $s = (grep(/$search_str/, @a))[0];
	print STDERR "1 s=$s\n";
	if ($s) {
		$s = trim((split(/=/, $s))[1]);
	}
	print STDERR "2 s=$s\n";
	return $s;
}

sub check_qnap_smart
{
	my ($expire, $system_name, $hostname, $snmp_version, $community, $username, $password) = @_;
	my $error_str = '';
	my $warning_str = '';
	my $ok_str = '';
	my $serviceid = get_serviceid('smart');
	my $statusid = $SisIYA_Config::statusids{'ok'};

	#print STDERR "@a\n";
	my $s = get_snmp_value('-OvQ', $hostname, $snmp_version, $community, $mibs{'hd_number'}, $username, $password);
	if ($s eq '') {
		return;
	}
	my $hd_number = $s;
	print STDERR "Number of disks: $hd_number\n";
	if ($hd_number == 0) {
		return;
	}
	# get the system hd table in an array
        my @a = `$SisIYA_Remote_Config::external_progs{'snmpwalk'} -OnQ -v $snmp_version -c $community $hostname $mibs{'system_hd_table'} 2>&1`;
        my $retcode = $? >>=8;
        if ($retcode != 0) {
                return '';
        }
	my ($hd_smart_info, $hd_model, $hd_descr, $hd_capacity, $hd_status, $hd_temperature, $index);
	for (my $i = 1; $i <= $hd_number; $i++) {
		$index = get_snmp_value_from_array($mibs{'hd_index'}.$i, @a);
		$hd_capacity = get_snmp_value_from_array($mibs{'hd_capacity'}.$i, @a);
		$hd_capacity =~ s/"//g;
		$hd_descr = get_snmp_value_from_array($mibs{'hd_descr'}.$i, @a);
		$hd_descr =~ s/"//g;
		$hd_model = get_snmp_value_from_array($mibs{'hd_model'}.$i, @a);
		$hd_model =~ s/"//g;
		$hd_status = get_snmp_value_from_array($mibs{'hd_status'}.$i, @a);
		$hd_temperature = get_snmp_value_from_array($mibs{'hd_temperature'}.$i, @a);
		$hd_temperature =~ s/"//g;
		$hd_temperature = (split(/\//, $hd_temperature))[0];
		
		$hd_smart_info = get_snmp_value_from_array($mibs{'hd_smart_info'}.$i, @a);
		$hd_smart_info =~ s/"//g;
		print STDERR "index: $index hd_status=[$hd_status] hd_capacity=[$hd_capacity] hd_model=[$hd_model] hd_descr=[$hd_descr] \n";
		$s = "$hd_temperature $hd_descr Device Model: $hd_model Capacity: $hd_capacity status: $hd_status";
		if ($hd_smart_info eq 'GOOD') {
			$ok_str .= " OK: Disk $index is OK. $s";
		} else {
			$statusid = $SisIYA_Config::statusids{'error'};
			$error_str .= " ERROR: Disk $index has status = $hd_smart_info (!= GOOD)! $s";
		}
	}

	return "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$error_str$warning_str$ok_str</msg><datamsg></datamsg></data></message>";
}

sub check_qnap
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
	$s .= check_qnap_smart($expire, $system_name, $hostname, $snmp_version, $community, $username, $password);
	return "<system><name>$system_name</name>$s</system>";
}

my ($systems_file, $expire) = @ARGV;
my $serviceid = get_serviceid($check_name);
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
		$xml_str .= check_qnap($h->{'isactive'}, $expire, $h->{'system_name'}, $h->{'hostname'}, 
					$h->{'snmp_version'}, $h->{'community'}, $h->{'username'}, $h->{'password'});
	}
}
else {
	$xml_str = check_qnap($data->{'record'}->{'isactive'}, $expire, $data->{'record'}->{'system_name'}, 
				$data->{'record'}->{'hostname'}, $data->{'record'}->{'snmp_version'}, $data->{'record'}->{'community'},
				$data->{'record'}->{'username'}, $data->{'record'}->{'password'});
}
unlock_check($check_name);
print $xml_str;
