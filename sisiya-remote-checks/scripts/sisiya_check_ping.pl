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
	print "Usage : $0 ping_systems.xml expire\n";
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

my ($systems_file, $expire) = @ARGV;
my $serviceid = get_serviceid('ping');

sub check_ping
{
	my $isactive 		= $_[0];
	if ($isactive eq 'f' ) {
		return '';
	}
	my $serviceid	 	= $_[1];
	my $expire	 	= $_[2];
	my $system_name 	= $_[3];
	my $hostname		= $_[4];
	my $packets_to_send	= $_[5];
	my $timeout_to_wait	= $_[6];

	#print STDERR "Checking system_name=[$system_name] hostname=[$hostname] isactive=[$isactive] packets_to_send=[$packets_to_send] timeout_to_wait=[$timeout_to_wait]...\n";
	my $statusid = $SisIYA_Config::statusids{'ok'};
	my $x_str .= "<system><name>$system_name</name><message><serviceid>$serviceid</serviceid>";
	my $s = '';
	my @a = `$SisIYA_Remote_Config::external_progs{'ping'} -q -c $packets_to_send -w $timeout_to_wait $hostname`;
	my $retcode = $? >>=8;
	if($retcode == 1) {
		$statusid = $SisIYA_Config::statusids{'error'};
		$s = "ERROR: The system is unreachable!";
	}
	else {
		my $info_str = (grep(/^$packets_to_send packets/, @a))[0];
		if($retcode == 0) {
			$s = "OK: $info_str";
		}
		else {
			$statusid = $SisIYA_Config::statusids{'warning'};
			$s = "WARNING: The system has network problems! $info_str";
		}
	}
	$x_str .= "<statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message></system>";
	return $x_str;
}

my $xml = new XML::Simple;
my $data = $xml->XMLin($systems_file);
my $xml_str = '';
#print STDERR Dumper($data);
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
print $xml_str;
