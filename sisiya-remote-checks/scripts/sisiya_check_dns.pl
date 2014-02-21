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

my $check_name = 'dns';

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


sub check_dns
{
	my ($isactive, $serviceid, $expire, $system_name, $hostname, $hostname_to_query, $ip_to_query, $port, $timeout, $number_of_tries) = @_;

	if ($isactive eq 'f' ) {
		return '';
	}

	#print STDERR "Checking system_name=[$system_name] hostname=[$hostname] isactive=[$isactive] hostname_to_query=[$hostname_to_query] ip_to_query=[$ip_to_query] port=[$port] timeout=[$timeout] number_of_tries=[$number_of_tries] ...\n";
	my $statusid = $SisIYA_Config::statusids{'ok'};
	my $s;
	`$SisIYA_Remote_Config::external_progs{'dig'} -p $port +timeout=$timeout +tries=$number_of_tries -x $hostname_to_query \@$hostname >/dev/null 2>&1`;
	my $retcode = $? >>=8;
	if($retcode != 0) {
		$statusid = $SisIYA_Config::statusids{'error'};
		$s = "ERROR: Could not query $hostname_to_query on $hostname!";
	}
	else {
		$s = "OK: Checked $hostname_to_query on $hostname.";
	}
	`$SisIYA_Remote_Config::external_progs{'dig'} -p $port +timeout=$timeout +tries=$number_of_tries -x $ip_to_query \@$hostname >/dev/null 2>&1`;
	$retcode = $? >>=8;
	if($retcode != 0) {
		$statusid = $SisIYA_Config::statusids{'error'};
		$s .= "ERROR: Could query $ip_to_query on $hostname!";
	}
	else {
		$s .= "OK: Checked $ip_to_query on $hostname.";
	}
	return "<system><name>$system_name</name><message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message></system>";
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
		$xml_str .= check_dns($h->{'isactive'}, $serviceid, $expire, $h->{'system_name'}, $h->{'hostname'}, $h->{'hostname_to_query'}, 
					$h->{'ip_to_query'}, $h->{'port'}, $h->{'timeout'}, $h->{'number_of_tries'});
	}
}
else {
	$xml_str = check_dns($data->{'record'}->{'isactive'}, $serviceid, $expire, $data->{'record'}->{'system_name'}, $data->{'record'}->{'hostname'}, 
				$data->{'record'}->{'hostname_to_query'}, $data->{'record'}->{'ip_to_query'}, 
				$data->{'record'}->{'port'}, $data->{'record'}->{'timeout'}, $data->{'record'}->{'number_of_tries'});
}
unlock_check($check_name);
print $xml_str;
