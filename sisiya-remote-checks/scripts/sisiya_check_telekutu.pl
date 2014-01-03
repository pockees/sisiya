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
	print "Usage : $0 telekutu_systems.xml expire\n";
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

sub check_telekutu_system
{
	my ($expire, $system_name, $hostname, $index_file, $http_port, $username, $password) = @_;


	print STDERR "Checking system_name=[$system_name] hostname=[$hostname] index_file=[$index_file] http_port=[$http_port] username=[$username] password=[$password] ...\n";
	my $serviceid = get_serviceid('system');
	my $statusid = $SisIYA_Config::statusids{'ok'};
	my $params = '--max-time 4 --include';
	if (grep(/^HASH/, $username) == 0) {
	       $params = "$params --user \"$username:$password\"";
	}	       
	my @a = `$SisIYA_Remote_Config::external_progs{'curl'} $params http://$hostname:$http_port$index_file 2>/dev/null`;
	my $s;
	my $retcode = $? >>=8;
	if($retcode != 0) {
		$statusid = $SisIYA_Config::statusids{'error'};
		$s = "ERROR: Could not connect to $hostname!";
	} else {
		$s = "OK: connected";
		print STDERR (grep(/Host Name/i, @a))[0];
	}

	return "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message>";
}

sub check_telekutu
{
	my ($isactive, $serviceid, $expire, $system_name, $hostname, $index_file, $http_port, $username, $password) = @_;

	if ($isactive eq 'f' ) {
		return '';
	}

	print STDERR "Checking system_name=[$system_name] hostname=[$hostname] serviceid=[$serviceid] isactive=[$isactive] index_file=[$index_file] http_port=[$http_port] username=[$username] password=[$password] ...\n";
	my $s = check_telekutu_system($expire, $hostname, $index_file, $http_port, $username, $password);
	if ($s eq '') {
		return '';
	}
	#$s .= check_telekutu_line($expire, $hostname, $index_file, $http_port, $username, $password);
	return "<system><name>$system_name</name>$s</system>";
}

my ($systems_file, $expire) = @ARGV;
my $xml = new XML::Simple;
my $data = $xml->XMLin($systems_file);
my $xml_str = '';
#print STDERR Dumper($data);
if( ref($data->{'record'}) eq 'ARRAY' ) {
	foreach my $h (@{$data->{'record'}}) {
		$xml_str .= check_telekutu($h->{'isactive'},  $expire, $h->{'system_name'}, $h->{'hostname'}, 
						$h->{'index_file'}, $h->{'http_port'}, $h->{'username'}, $h->{'password'}, 0);
	}
} else {
	$xml_str = check_telekutu($data->{'record'}->{'isactive'}, $serviceid, $expire, $data->{'record'}->{'system_name'}, 
					$data->{'record'}->{'hostname'}, $data->{'record'}->{'index_file'}, $data->{'record'}->{'http_port'}, 
					$data->{'record'}->{'username'}, $data->{'record'}->{'password'}, 0); 
}
print STDERR $xml_str;
print $xml_str;
