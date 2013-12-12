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
	print "Usage : $0 http_systems.xml expire\n";
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

my $systems_file	= $ARGV[0];
my $expire 		= $ARGV[1];
my $serviceid 		= get_serviceid('http');

sub check_http
{
	my $isactive 		= $_[1];
	if ($isactive eq 'f' ) {
		return '';
	}
	my $system_name 	= $_[0];
	my $virtual_host	= $_[2];
	my $index_file		= $_[3];
	my $http_port		= $_[4];
	my $username 		= $_[5];
	my $password		= $_[6];
	#print STDERR "check_http: Checking system_name=[$system_name] isactive=[$isactive] virtual_host=[$virtual_host] index_file=[$index_file] http_port=[$http_port] username=[$username] password=[$password]...\n";

	my $statusid = $SisIYA_Config::statusids{'ok'};
	my $x_str = "<system><name>$system_name</name><message><serviceid>$serviceid</serviceid>";
	my $s = '';
	#############################################################
	#HTTP/1.1 200 OK
	#Date: Thu, 12 Dec 2013 07:24:06 GMT
	#Server: Apache
	#Last-Modified: Wed, 11 Sep 2013 14:27:45 GMT
	#ETag: "101513-ca7-4e61c6cc7b001"
	#Accept-Ranges: bytes
	#Content-Length: 3239
	#Connection: close
	#Content-Type: text/html; charset=UTF-8
	#############################################################
	my $params = '--max-time 4 --include';
	if (grep(/^HASH/, $username) == 0) {
	       $params = "$params --user \"$username:$password\"";
	}	       
	#print STDERR "$SisIYA_Remote_Config::external_progs{'curl'} $params http://$virtual_host:$http_port$'index_file'\n";
	my @a = `$SisIYA_Remote_Config::external_progs{'curl'} $params http://$virtual_host:$http_port$index_file 2>/dev/null`;
	my $retcode = $? >>=8;
	if ($retcode != 0) {
		$statusid = $SisIYA_Config::statusids{'error'};
		#print STDERR "FAILED\n";
		$s .= "ERROR: The HTTP server is not running! retcode=$retcode";
	}
	else {
		my $info_str = '';
		if ( grep(/^Server/, @a) != 0 ) {
			$info_str = (grep(/^Server/, @a))[0];
			#print "info=[$info_str]\n";
			$info_str = (split(/:/, (grep(/^Server/, @a))[0]))[1];
			#print "info=[$info_str]\n";
		}
		if ($info_str ne '') {
			$info_str = "INFO: $info_str";
			chomp($info_str = $info_str);
		}
		my $http_status_code = (split(/\s+/, (grep(/^HTTP\//, @a))[0]))[1];
		if ( ($http_status_code == 200) || ($http_status_code == 302) ) {
			$s = "OK: The service is running. $info_str";
		}
		elsif ($http_status_code == 401) {
			$s = "WARNING: Unauthorized access to $virtual_host$index_file! $info_str";
		}
		elsif ($http_status_code == 403) {
			$s = "WARNING: It is forbidden to get $virtual_host$index_file! $info_str";
		}
		elsif ($http_status_code == 404) {
			$s = "WARNING: $index_file could not be found! $info_str";
		}
		else {
			$s = "ERROR: Unknown status $http_status_code! $info_str";
		}
	}
	$x_str .= "<statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message></system>";
	return $x_str;
}

my $xml = new XML::Simple;
my $data = $xml->XMLin($systems_file);
#print STDERR Dumper($data);
my $xml_str = '';
if( ref($data->{'record'}) eq 'ARRAY' ) {
	foreach my $h (@{$data->{'record'}}) {
		$xml_str .= check_http($h->{'system_name'}, $h->{'isactive'}, $h->{'virtual_host'}, $h->{'index_file'}, $h->{'http_port'}, $h->{'username'}, $h->{'password'});
	}
}
else {
	$xml_str = check_http($data->{'record'}->{'system_name'}, $data->{'record'}->{'isactive'}, $data->{'record'}->{'virtual_host'}, $data->{'record'}->{'index_file'}, $data->{'record'}->{'http_port'}, $data->{'record'}->{'username'}, $data->{'record'}->{'password'}); 
}

#print STDERR $xml_str."\n";
print $xml_str;
#######################################################################################
