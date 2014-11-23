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
our %loads = ('error' => 90, 'warning' => 80);
our %default_temperatures = ( 'warning' => 35, 'error' => 40 );
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
	'system_volume_table'	=> '1.3.6.1.4.1.24681.1.2.17',		# whole volume tree
	'sys_volume_number'	=> '1.3.6.1.4.1.24681.1.2.16.0',	# number of volumes
	'sys_volume_index'	=> '1.3.6.1.4.1.24681.1.2.17.1.1.',	# add the disk index
	'sys_volume_descr'	=> '1.3.6.1.4.1.24681.1.2.17.1.2.',	# add the disk index
	'sys_volume_fs'		=> '1.3.6.1.4.1.24681.1.2.17.1.3.',	# add the disk index
	'sys_volume_total_size'	=> '1.3.6.1.4.1.24681.1.2.17.1.4.',	# add the disk index
	'sys_volume_free_size'	=> '1.3.6.1.4.1.24681.1.2.17.1.5.',	# add the disk index
	'sys_volume_status'	=> '1.3.6.1.4.1.24681.1.2.17.1.6.',	# add the disk index
	'system_temperature'	=> '1.3.6.1.4.1.24681.1.2.6.0',		# system temperature
	'system_load'		=> '1.3.6.1.4.1.24681.1.2.1.0',		# system load
);

# end of default values
############################################################################################################
sub get_snmp_value_from_array
{
	my ($search_str, @a) = @_;
	
	#print STDERR "search str: $search_str\n";
	my $s = (grep(/$search_str/, @a))[0];
	#print STDERR "1 s=$s\n";
	if ($s) {
		$s = trim((split(/=/, $s))[1]);
	}
	#print STDERR "2 s=$s\n";
	return $s;
}

sub check_qnap_load
{
	my ($expire, $system_name, $hostname, $snmp_version, $community, $username, $password) = @_;
	my $serviceid = get_serviceid('load');
	my $statusid = $SisIYA_Config::statusids{'ok'};

	#print STDERR "@a\n";
	my $s = get_snmp_value('-OvQ', $hostname, $snmp_version, $community, $mibs{'system_load'}, $username, $password);
	if ($s eq '') {
		return;
	}
	my $system_load = $s;
	$system_load =~ s/"//g;
	$system_load = trim((split(/%/, $system_load))[0]);
	#print STDERR "System load: $system_load\n";
	if ($system_load == 0) {
		return;
	}
	if ($system_load >= $loads{'error'}) {
		$statusid = $SisIYA_Config::statusids{'error'};
		$s = "ERROR: System load is $system_load % (>= $loads{'error'})!";
	} elsif ($system_load >= $loads{'warning'}) {
		if ($statusid < $SisIYA_Config::statusids{'error'}) {
			$statusid = $SisIYA_Config::statusids{'warning'};
		}	 
		$s = "WARNING: System load is $system_load % (>= $loads{'warning'})!";
	} else {
		$s = "OK: System load is $system_load %.";
	}
	return "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message>";
}

sub check_qnap_temperature
{
	my ($expire, $system_name, $hostname, $snmp_version, $community, $username, $password) = @_;
	my $serviceid = get_serviceid('temperature');
	my $statusid = $SisIYA_Config::statusids{'ok'};

	#print STDERR "@a\n";
	my $s = get_snmp_value('-OvQ', $hostname, $snmp_version, $community, $mibs{'system_temperature'}, $username, $password);
	if ($s eq '') {
		return;
	}
	my $system_temperature = $s;
	$system_temperature =~ s/"//g;
	$system_temperature = trim((split(/C/, $system_temperature))[0]);
	#print STDERR "System temperature: $system_temperature\n";
	if ($system_temperature == 0) {
		return;
	}
	if ($system_temperature >= $default_temperatures{'error'}) {
		$statusid = $SisIYA_Config::statusids{'error'};
		$s = "ERROR: System temperature is $system_temperature C (>= $default_temperatures{'error'})!";
	} elsif ($system_temperature >= $default_temperatures{'warning'}) {
		if ($statusid < $SisIYA_Config::statusids{'error'}) {
			$statusid = $SisIYA_Config::statusids{'warning'};
		}	 
		$s = "WARNING: System temperature is $system_temperature C (>= $default_temperatures{'warning'})!";
	} else {
		$s = "OK: System temperature is $system_temperature C.";
	}
	return "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message>";
}

sub check_qnap_raid
{
	my ($expire, $system_name, $hostname, $snmp_version, $community, $username, $password) = @_;
	my $error_str = '';
	my $warning_str = '';
	my $ok_str = '';
	my $serviceid = get_serviceid('raid');
	my $statusid = $SisIYA_Config::statusids{'ok'};

	#print STDERR "@a\n";
	my $s = get_snmp_value('-OvQ', $hostname, $snmp_version, $community, $mibs{'sys_volume_number'}, $username, $password);
	if ($s eq '') {
		return;
	}
	my $sys_volume_number = $s;
	#print STDERR "Number of volumes: $sys_volume_number\n";
	if ($sys_volume_number == 0) {
		return;
	}
	# get the system volume table in an array
        my @a = `$SisIYA_Remote_Config::external_progs{'snmpwalk'} -OnQ -v $snmp_version -c $community $hostname $mibs{'system_volume_table'} 2>&1`;
        my $retcode = $? >>=8;
        if ($retcode != 0) {
                return '';
        }
	my ($sys_volume_fs, $sys_volume_total_size, $sys_volume_free_size, $sys_volume_descr, $sys_volume_status, $index);
	for (my $i = 1; $i <= $sys_volume_number; $i++) {
		$index = get_snmp_value_from_array($mibs{'sys_volume_index'}.$i, @a);
		$sys_volume_total_size = get_snmp_value_from_array($mibs{'sys_volume_total_size'}.$index, @a);
		$sys_volume_total_size =~ s/"//g;
		$sys_volume_free_size = get_snmp_value_from_array($mibs{'sys_volume_free_size'}.$index, @a);
		$sys_volume_free_size =~ s/"//g;
		$sys_volume_descr = get_snmp_value_from_array($mibs{'sys_volume_descr'}.$index, @a);
		$sys_volume_descr =~ s/"//g;
		$sys_volume_fs = get_snmp_value_from_array($mibs{'sys_volume_fs'}.$index, @a);
		$sys_volume_fs =~ s/"//g;
		$sys_volume_status = get_snmp_value_from_array($mibs{'sys_volume_status'}.$index, @a);
		$sys_volume_status =~ s/"//g;
		#print STDERR "index: $index sys_volume_status=[$sys_volume_status] sys_volume_total_size=[$sys_volume_total_size] sys_volume_free_size=[$sys_volume_free_size] sys_volume_descr=[$sys_volume_descr] sys_volume_fs=[$sys_volume_fs]\n";
		$s = "$sys_volume_descr File system: $sys_volume_fs Total size: $sys_volume_total_size Free Size: $sys_volume_free_size ";
		if ($sys_volume_status eq 'Ready') {
			$ok_str .= " OK: Volume $index is OK. $s";
		} else {
			$statusid = $SisIYA_Config::statusids{'error'};
			$error_str .= " ERROR: Volume $index has status = $sys_volume_status (!= Ready)! $s";
		}
	}
	return "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$error_str$warning_str$ok_str</msg><datamsg></datamsg></data></message>";
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
	#print STDERR "Number of disks: $hd_number\n";
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
		$hd_capacity = get_snmp_value_from_array($mibs{'hd_capacity'}.$index, @a);
		$hd_capacity =~ s/"//g;
		$hd_descr = get_snmp_value_from_array($mibs{'hd_descr'}.$index, @a);
		$hd_descr =~ s/"//g;
		$hd_model = get_snmp_value_from_array($mibs{'hd_model'}.$index, @a);
		$hd_model =~ s/"//g;
		$hd_status = get_snmp_value_from_array($mibs{'hd_status'}.$index, @a);
		$hd_temperature = get_snmp_value_from_array($mibs{'hd_temperature'}.$index, @a);
		$hd_temperature =~ s/"//g;
		$hd_temperature = trim((split(/C/, $hd_temperature))[0]);
		
		$hd_smart_info = get_snmp_value_from_array($mibs{'hd_smart_info'}.$index, @a);
		$hd_smart_info =~ s/"//g;
		#print STDERR "index: $index hd_status=[$hd_status] hd_capacity=[$hd_capacity] hd_model=[$hd_model] hd_descr=[$hd_descr] hd_temperature=[$hd_temperature]\n";
		$s = "$hd_descr Device Model: $hd_model Capacity: $hd_capacity Temperature: $hd_temperature C SMART info: $hd_smart_info";
		if ($hd_status == 0) {
			$ok_str .= " OK: Disk $index is OK. $s";
		} else {
			$statusid = $SisIYA_Config::statusids{'error'};
			$error_str .= " ERROR: Disk $index has status = $hd_status (!= 0)! $s";
		}
		if ($hd_temperature ne '--') {
			if ($hd_temperature >= $default_temperatures{'error'}) {
				$statusid = $SisIYA_Config::statusids{'error'};
				$error_str .= " ERROR: Disk $index temperature is $hd_temperature C (>= $default_temperatures{'error'})!";
			} elsif ($hd_temperature >= $default_temperatures{'warning'}) {
				if ($statusid < $SisIYA_Config::statusids{'error'}) {
					$statusid = $SisIYA_Config::statusids{'warning'};
				}	 
				$warning_str .= " WARNING: Disk $index temperature is $hd_temperature C (>= $default_temperatures{'warning'})!";
			}
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
	$s .= check_qnap_raid($expire, $system_name, $hostname, $snmp_version, $community, $username, $password);
	$s .= check_qnap_temperature($expire, $system_name, $hostname, $snmp_version, $community, $username, $password);
	$s .= check_qnap_load($expire, $system_name, $hostname, $snmp_version, $community, $username, $password);
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
