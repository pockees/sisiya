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

my $check_name = 'idrac';

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
	#'idrac_mib'		=> '1.3.6.1.4.1.674.10892',		# whole IDRAC tree
	'idrac_mib'				=> '1.3.6.1.4.1.674.10892.5.5.1.20',		# whole logical devices tree
	# for the following IDs append .1 for the first table entry, .2 for the next etc	
	'physical_disk_number'			=> '1.3.6.1.4.1.674.10892.5.5.1.20.130.4.1.1',	
	'physical_disk_name'			=> '1.3.6.1.4.1.674.10892.5.5.1.20.130.4.1.2',
	'physical_disk_size'			=> '1.3.6.1.4.1.674.10892.5.5.1.20.130.4.1.11',
	'physical_disk_state'			=> '1.3.6.1.4.1.674.10892.5.5.1.20.130.4.1.4',
	'physical_disk_spare_state'		=> '1.3.6.1.4.1.674.10892.5.5.1.20.130.4.1.22',
	'physical_disk_media_type'		=> '1.3.6.1.4.1.674.10892.5.5.1.20.130.4.1.35',
	'physical_disk_state'			=> '1.3.6.1.4.1.674.10892.5.5.1.20.130.4.1.4',
	'physical_disk_display_name'		=> '1.3.6.1.4.1.674.10892.5.5.1.20.130.4.1.55',
	'physical_disk_manufacturer'		=> '1.3.6.1.4.1.674.10892.5.5.1.20.130.4.1.3',
	'physical_disk_operational_state'	=> '1.3.6.1.4.1.674.10892.5.5.1.20.130.4.1.50',
	'virtual_disk_table_entry'		=> '1.3.6.1.4.1.674.10892.5.5.1.20.140.1',
	'virtual_disk_number'			=> '1.3.6.1.4.1.674.10892.5.5.1.20.140.1.1.1',
	'virtual_disk_name'			=> '1.3.6.1.4.1.674.10892.5.5.1.20.140.1.1.2',
	'virtual_disk_display_name'		=> '1.3.6.1.4.1.674.10892.5.5.1.20.140.1.1.36',
	'virtual_disk_state'			=> '1.3.6.1.4.1.674.10892.5.5.1.20.140.1.1.4',
	'virtual_disk_operational_state'	=> '1.3.6.1.4.1.674.10892.5.5.1.20.140.1.1.30',
	'virtual_disk_size'			=> '1.3.6.1.4.1.674.10892.5.5.1.20.140.1.1.6',
	'virtual_disk_layout'			=> '1.3.6.1.4.1.674.10892.5.5.1.20.140.1.1.13',
	'virtual_disk_remaining_redundancy'	=> '1.3.6.1.4.1.674.10892.5.5.1.20.140.1.1.34',
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

sub check_idrac_raid
{
	my ($expire, $system_name, $hostname, @a) = @_;
	my $error_str = '';
	my $warning_str = '';
	my $ok_str = '';
	my $serviceid = get_serviceid('raid');
	my $statusid = $SisIYA_Config::statusids{'ok'};

	#print STDERR "@a\n";
	my %h;
	my ($k, $v);
	for my $s (@a) {
		($k, $v) = split(/ = /, $s);
		chomp($v = $v);
		$h{$k} = $v;
	}

	#foreach $k (keys %h) {
	#	print STDERR "key=[$k] value=[$h{$k}]\n";
	#}

	# logical drives
	my $i = 0;
	do {
		$i++;
		$k = '.'.$mibs{'virtual_disk_number'}.'.'.$i;
		#print STDERR "k=[$k]\n";
	} while (exists $h{$k}); 
	my $number_of_virtual_disks = $i - 1;
	my ($index, $vd_name, $vd_desc, $vd_manufacturer, $vd_remaining_redundancy, $vd_op_state, $vd_state, $vd_size);
	#print STDERR "Number of virtual disks = $number_of_virtual_disks\n";
	my $str;
	for ($i = 1; $i <= $number_of_virtual_disks; $i++) {
		$k = '.'.$mibs{'virtual_disk_number'}.'.'.$i;
		$index = $h{$k};
		$k = '.'.$mibs{'virtual_disk_name'}.'.'.$index;
		$vd_name = $h{$k};
		$vd_name =~ s/"//g;
		$k = '.'.$mibs{'virtual_disk_state'}.'.'.$index;
		$vd_state = $h{$k};
		$k = '.'.$mibs{'virtual_disk_operational_state'}.'.'.$index;
		$vd_op_state = $h{$k};
		$k = '.'.$mibs{'virtual_disk_size'}.'.'.$index;
		$vd_size = $h{$k} / 1024;	# convert to GB
		$k = '.'.$mibs{'virtual_disk_remaining_redundancy'}.'.'.$index;
		$vd_remaining_redundancy = $h{$k};
		$k = '.'.$mibs{'virtual_disk_display_name'}.'.'.$index;
		$vd_desc = $h{$k};
		$vd_desc =~ s/"//g;
		$k = '.'.$mibs{'virtual_disk_layout'}.'.'.$index;
		$vd_manufacturer = $h{$k};
		#print STDERR "index = [$index] name=[$vd_name] state=[$vd_state]\n";
		$str = "name: $vd_name, capacity: $vd_size GB, layout: $vd_manufacturer, operational state: $vd_op_state, remaining redundancy: $vd_remaining_redundancy";
		if ($vd_state == 2) { # online
			$ok_str .= "OK: Logical drive $vd_desc ($str) status is OK.";
		} else {
			$statusid = $SisIYA_Config::statusids{'error'};
			$error_str .= "ERROR: Logical drive $vd_desc ($str) status is not OK (state=$vd_state != 2)!";
		}
	}

	# physical disks
	$i = 0;
	do {
		$i++;
		$k = '.'.$mibs{'physical_disk_number'}.'.'.$i;
		#print STDERR "k=[$k]\n";
	} while (exists $h{$k}); 
	my $number_of_physical_disks = $i - 1;
	my ($d_name, $d_desc, $d_manufacturer, $d_remaining_redundancy, $d_op_state, $d_spare_state, $d_state, $d_size);
	my $spare_str;
	#print STDERR "Number of physical disks = $number_of_physical_disks\n";
	for ($i = 1; $i <= $number_of_physical_disks; $i++) {
		$k = '.'.$mibs{'physical_disk_number'}.'.'.$i;
		$index = $h{$k};
		$k = '.'.$mibs{'physical_disk_name'}.'.'.$index;
		$d_name = $h{$k};
		$d_name =~ s/"//g;
		$k = '.'.$mibs{'physical_disk_state'}.'.'.$index;
		$d_state = $h{$k};
		$k = '.'.$mibs{'physical_disk_spare_state'}.'.'.$index;
		$d_spare_state = $h{$k};
		$k = '.'.$mibs{'physical_disk_operational_state'}.'.'.$index;
		$d_op_state = $h{$k};
		$k = '.'.$mibs{'physical_disk_size'}.'.'.$index;
		$d_size = $h{$k} / 1024;	# convert to GB
		$k = '.'.$mibs{'physical_disk_display_name'}.'.'.$index;
		$d_desc = $h{$k};
		$d_desc =~ s/"//g;
		$k = '.'.$mibs{'physical_disk_manufacturer'}.'.'.$index;
		$d_manufacturer = $h{$k};
		$d_manufacturer =~ s/"//g;
		#print STDERR "index = [$index] name=[$d_name] state=[$d_state]\n";
		if ($d_spare_state == 1) {
			$spare_str = 'spare: no';
		} elsif ($d_spare_state == 3) {
			$spare_str = 'spare: global';
		} else {
			$spare_str = "spare: unknown, spare state code: $d_spare_state";
		}
			
		$str = "name: $d_name, state: $d_state, $spare_str, capacity: $d_size GB, manufacturer: $d_manufacturer, operational state: $d_op_state";
		if ($d_state == 3 || $d_state == 2) { # 2=online, 3=ready
			$ok_str .= "OK: Disk $d_desc ($str) status is OK.";
		} else {
			$statusid = $SisIYA_Config::statusids{'error'};
			$error_str .= "ERROR: Disk $d_desc ($str) status is not OK (state=$d_state != 2)!";
		}
	}

	return "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$error_str$warning_str$ok_str</msg><datamsg></datamsg></data></message>";
}

sub check_idrac
{
	my ($isactive, $expire, $system_name, $hostname, $snmp_version, $community, $username, $password) = @_;

	if ($isactive eq 'f' ) {
		return '';
	}

	#print STDERR "Checking system_name=[$system_name] hostname=[$hostname] isactive=[$isactive] snmp_version=[$snmp_version] community=[$community] username=[$username] password=[$password]...\n";
	my $s = '';
	# get the all in an array
        my @a = `$SisIYA_Remote_Config::external_progs{'snmpwalk'} -OnQ -v $snmp_version -c $community $hostname $mibs{'idrac_mib'} 2>&1`;

	$s .= check_idrac_raid($expire, $system_name, $hostname, @a);
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
		$xml_str .= check_idrac($h->{'isactive'}, $expire, $h->{'system_name'}, $h->{'hostname'}, 
					$h->{'snmp_version'}, $h->{'community'}, $h->{'username'}, $h->{'password'});
	}
}
else {
	$xml_str = check_idrac($data->{'record'}->{'isactive'}, $expire, $data->{'record'}->{'system_name'}, 
				$data->{'record'}->{'hostname'}, $data->{'record'}->{'snmp_version'}, $data->{'record'}->{'community'},
				$data->{'record'}->{'username'}, $data->{'record'}->{'password'});
}
unlock_check($check_name);
print $xml_str;
