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
use Net::SMTP;
#use Data::Dumper;

if( $#ARGV != 1 ) {
	print "Usage : $0 smtp_systems.xml expire\n";
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


sub check_smtp
{
	my $isactive		= $_[0];
	if ($isactive eq 'f' ) {
		return '';
	}
	my $serviceid 		= $_[1];
	my $expire 		= $_[2];
	my $system_name 	= $_[3];
	my $hostname		= $_[4];
	my $port		= $_[5];

	#print STDERR "Checking system_name=[$system_name] hostname=[$hostname] isactive=[$isactive] port=[$port] ...\n";
	my $statusid = $SisIYA_Config::statusids{'ok'};
	my $x_str = "<system><name>$system_name</name><message><serviceid>$serviceid</serviceid>";
	my $s = '';
	my $smtp = Net::SMTP->new( Host => $hostname, Hello => $SisIYA_Config::hostname, Timeout => 3, Debug => 0);
	#print STDERR "banner=[".$smtp->banner."] domain=[".$smtp->domain."]\n";
	$smtp->quit();

	if($smtp) {
		$s = "OK: ".$smtp->banner;
		chomp($s = $s);
		#print STDERR "s=[$s]\n";
	}
	else {
		$statusid = $SisIYA_Config::statusids{'error'};
		$s = "ERROR: Service is not running!";
	}
	$x_str .= "<statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message></system>";
	return $x_str;
}

my $systems_file = $ARGV[0];
my $expire = $ARGV[1];
my $serviceid = get_serviceid('smtp');
my $xml = new XML::Simple;
my $data = $xml->XMLin($systems_file);
my $xml_str = '';
#print STDERR Dumper($data);
if( ref($data->{'record'}) eq 'ARRAY' ) {
	foreach my $h (@{$data->{'record'}}) {
		$xml_str .= check_smtp($h->{'isactive'}, $serviceid, $expire, $h->{'system_name'}, $h->{'hostname'}, $h->{'port'});
	}
}
else {
	$xml_str .= check_smtp($data->{'record'}->{'isactive'}, $serviceid, $expire, $data->{'record'}->{'system_name'}, 
				$data->{'record'}->{'hostname'}, $data->{'record'}->{'port'});
}
print $xml_str;
