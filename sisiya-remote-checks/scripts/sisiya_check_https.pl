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
	print "Usage : $0 https_systems.xml expire\n";
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

my $systems_file = $ARGV[0];
my $expire = $ARGV[1];
my $serviceid = get_serviceid('https');
my $xml = new XML::Simple;
my $data = $xml->XMLin($systems_file);
my $xml_str = '';
#print STDERR Dumper($data);
if( ref($data->{'record'}) eq 'ARRAY' ) {
	foreach my $h (@{$data->{'record'}}) {
		$xml_str .= check_http_protocol($h->{'isactive'}, $serviceid, $expire, 1, $h->{'system_name'},  $h->{'virtual_host'}, 
						$h->{'index_file'}, $h->{'https_port'}, $h->{'username'}, $h->{'password'});
	}
}
else {
	$xml_str = check_http_protocol($data->{'record'}->{'isactive'}, $serviceid, $expire, 1, $data->{'record'}->{'system_name'}, 
					$data->{'record'}->{'virtual_host'}, $data->{'record'}->{'index_file'}, $data->{'record'}->{'https_port'}, 
					$data->{'record'}->{'username'}, $data->{'record'}->{'password'}); 
}
#print STDERR $xml_str."\n";
print $xml_str;
