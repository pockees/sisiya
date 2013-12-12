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
	print "Usage : $0 dns_systems.xml expire\n";
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

my $systems_file = $ARGV[0];
my $expire = $ARGV[1];
my $serviceid = get_serviceid('dns');
my $statusid;
my $retcode;
my $xml_str;
my $s;
my $xml = new XML::Simple;
my $data = $xml->XMLin($systems_file);
	#print STDERR Dumper($data);
foreach my $h (@{$data->{'record'}}) {
	#print STDERR "Checking system_name=[$h->{'system_name'}] hostname=[$h->{'hostname'}] isactive=[$h->{'isactive'}] hostname_to_query=[$h->{'hostname_to_query'}] ip_to_query=[$h->{'ip_to_query'}] port=[$h->{'port'}] timeout=[$h->{'timeout'}] number_of_tries=[$h->{'number_of_tries'}] ...\n";
	if ($h->{'isactive'} eq 'f' ) {
		#print STDERR "Skipping ...\n";
		next;
	}
	$statusid = $SisIYA_Config::statusids{'ok'};
	$xml_str .= "<system><name>$h->{'system_name'}</name><message><serviceid>$serviceid</serviceid>";
	$s = '';
	`$SisIYA_Remote_Config::external_progs{'dig'} -p $h->{'port'} +timeout=$h->{'timeout'} +tries=$h->{'number_of_tries'} $h->{'hostname_to_query'} \@$h->{'hostname'} >/dev/null 2>&1`;
	$retcode = $? >>=8;
	if($retcode != 0) {
		$statusid = $SisIYA_Config::statusids{'error'};
		#print STDERR "FAILED\n";
		$s = "ERROR: Could not query $h->{'hostname_to_query'} on $h->{'hostname'}!";
	}
	else {
		$s = "OK: Checked $h->{'hostname_to_query'} on $h->{'hostname'}.";
	}
	`$SisIYA_Remote_Config::external_progs{'dig'} -p $h->{'port'} +timeout=$h->{'timeout'} +tries=$h->{'number_of_tries'} -x $h->{'ip_to_query'} \@$h->{'hostname'} >/dev/null 2>&1`;
	$retcode = $? >>=8;
	if($retcode != 0) {
		$statusid = $SisIYA_Config::statusids{'error'};
		$s .= "ERROR: Could query $h->{'ip_to_query'} on $h->{'hostname'}!";
	}
	else {
		$s .= "OK: Checked $h->{'ip_to_query'} on $h->{'hostname'}.";
	}
	$xml_str .= "<statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message></system>";
	#print STDERR $xml_str;
}
print $xml_str;
#######################################################################################
