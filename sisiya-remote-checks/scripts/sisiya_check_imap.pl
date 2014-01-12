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
use Socket;
#use Data::Dumper;

my $check_name = 'imap';

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

sub check_imap
{
	my ($isactive, $serviceid, $expire, $system_name, $hostname, $port) = @_;

	if ($isactive eq 'f' ) {
		return '';
	}

	#print STDERR "Checking system_name=[$system_name] hostname=[$hostname] isactive=[$isactive] port=[$port] ...\n";
	my $statusid = $SisIYA_Config::statusids{'ok'};
	my $x_str = "<system><name>$system_name</name><message><serviceid>$serviceid</serviceid>";
	my $s = '';
	my $line = connect_to_socket_and_read_line($hostname, $port, 5, 'tcp');
	if ($line eq '') {
		$statusid = $SisIYA_Config::statusids{'error'};
		$s = "ERROR: Service is not running!";
	} else {
		$line =~ s/\* OK //g;
		#print STDERR "$line\n";
		$s = "OK: ".$line;
	}

	$x_str .= "<statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message></system>";
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
		$xml_str .= check_imap($h->{'isactive'}, $serviceid, $expire, $h->{'system_name'}, $h->{'hostname'}, $h->{'port'});
	}
}
else {
	$xml_str = check_imap($data->{'record'}->{'isactive'}, $serviceid, $expire, $data->{'record'}->{'system_name'}, 
				$data->{'record'}->{'hostname'}, $data->{'record'}->{'port'});
}
unlock_check($check_name);
print $xml_str;
