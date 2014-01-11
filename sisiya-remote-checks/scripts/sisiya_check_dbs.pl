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

my $check_name = 'dbs';

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

sub check_dbs
{
	my ($isactive, $expire, $system_name, $resource_bundle) = @_;

	if ($isactive eq 'f' ) {
		return '';
	}

	#print STDERR "Checking system_name=[$system_name] isactive=[$isactive] resource_bundle=[$resource_bundle] ...\n";
	### set environment variables
	$ENV{'CLASSPATH'} = $SisIYA_Remote_Config::env{'CLASSPATH'};
	my @a = `$SisIYA_Remote_Config::external_progs{'java'} SISIYACheckDB $system_name $resource_bundle $expire`;
	my $retcode = $? >>=8;
	if($retcode == 1) {
		print STDERR "Could not execute java\n";
		return '';
	} 
	my $s = "@a";
	$s = "<system><name>$system_name</name>$s</system>";
	return $s;
}

my ($systems_file, $expire) = @ARGV;
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
		$xml_str .= check_dbs($h->{'isactive'}, $expire, $h->{'system_name'}, $h->{'resource_bundle'});
	}
} else {
	$xml_str = check_dbs($data->{'record'}->{'isactive'}, $expire, $data->{'record'}->{'system_name'}, $data->{'record'}->{'resource_bundle'}); 
}
unlock_check($check_name);
print $xml_str;
