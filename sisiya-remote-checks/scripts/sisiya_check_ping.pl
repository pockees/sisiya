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

my $check_name = 'ping';

if( $#ARGV != 1 ) {
	print "Usage : $0 ".$check_name."_systems.xml expire\n";
	print "The expire parameter must be given in minutes.\n";
	exit 1;
}

if(-f $SisIYA_Remote_Config::local_conf) {
	require $SisIYA_Remote_Config::local_conf;
}
if(-f $SisIYA_Remote_Config::client_local_conf) {
	require $SisIYA_Remote_Config::client_local_conf;
}
if(-f $SisIYA_Config::functions) {
	require $SisIYA_Config::functions;
}
if(-f $SisIYA_Remote_Config::functions) {
	require $SisIYA_Remote_Config::functions;
}


sub check_ping
{
	my ($isactive, $serviceid, $expire, $system_name, $hostname, $packets_to_send, $timeout_to_wait) = @_;

	if ($isactive eq 'f' ) {
		return '';
	}

	#print STDERR "Checking system_name=[$system_name] hostname=[$hostname] isactive=[$isactive] packets_to_send=[$packets_to_send] timeout_to_wait=[$timeout_to_wait]...\n";
	my $statusid = $SisIYA_Config::statusids{'ok'};
	my $x_str .= "<system><name>$system_name</name><message><serviceid>$serviceid</serviceid>";
	my $s = '';
	my $data_str = '';
	my @a = `$SisIYA_Remote_Config::external_progs{'ping'} -q -c $packets_to_send -w $timeout_to_wait $hostname`;
	my $retcode = $? >>=8;
	if($retcode == 1) {
		$statusid = $SisIYA_Config::statusids{'error'};
		$s = "ERROR: The system is unreachable!";
		$data_str .= '<entry name="packet_loss" type="numeric" unit="%">100</entry>';
	}
	else {
		my ($response_time, $packet_loss);
		my $info_str = (grep(/^$packets_to_send packets/, @a))[0];
		if($retcode == 0) {
			$s = "OK: $info_str";
			$data_str .= '<entry name="packet_loss" type="numeric" unit="%">0</entry>';
		}
		else {
			$statusid = $SisIYA_Config::statusids{'warning'};
			$s = "WARNING: The system has network problems! $info_str";
			$packet_loss = (split(/%/, (split(/,/, $info_str))[2]))[0];
			$data_str .= '<entry name="packet_loss" type="numeric" unit="ms">'.$packet_loss.'</entry>';
		}
		$response_time = (split(/\s+/, (split(/,/, $info_str))[3]))[1];
		$data_str .= '<entry name="response_time" type="numeric" unit="">'.$response_time.'</entry>';
	}
	$x_str .= "<statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg>$data_str</datamsg></data></message></system>";
	return $x_str;
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
		$xml_str .= check_ping($h->{'isactive'}, $serviceid, $expire, $h->{'system_name'}, $h->{'hostname'}, 
					$h->{'packets_to_send'}, $h->{'timeout_to_wait'});
	}
}
else {
	$xml_str .= check_ping($data->{'record'}->{'isactive'}, $serviceid, $expire, $data->{'record'}->{'system_name'}, 
				$data->{'record'}->{'hostname'}, $data->{'record'}->{'packets_to_send'}, 
				$data->{'record'}->{'timeout_to_wait'});
}
unlock_check($check_name);
print $xml_str;
