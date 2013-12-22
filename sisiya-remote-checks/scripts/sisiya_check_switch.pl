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
	print "Usage : $0 switch_systems.xml expire\n";
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

###########################################################################################################
# default values
our %uptimes = ('error' => 1440, 'warning' => 4320);
# One can override there default values in the $SisIYA_RemoteConfig::conf_dir/switch_system_$system_name.pl
# end of default values
############################################################################################################
sub check_switch_system
{
	my ($serviceid, $expire, $hostname, $snmp_version, $community, $username, $password) = @_;
	my $statusid = $SisIYA_Config::statusids{'ok'};
	my $s = 'OK: deneme';

	return "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message>";
}

sub check_switch_temperature
{
	return '';
}

sub check_switch_fans
{
	return '';
}

sub check_switch_load
{
	return '';
}

sub check_switch_process_count
{
	return '';
}

sub check_switch_ram
{
	return '';
}

sub check_switch
{
	my ($isactive, $serviceid, $expire, $system_name, $hostname, $snmp_version, $community, $username, $password) = @_;

	if ($isactive eq 'f' ) {
		return '';
	}

	print STDERR "Checking system_name=[$system_name] hostname=[$hostname] isactive=[$isactive] snmp_version=[$snmp_version] community=[$community] username=[$username] password=[$password]...\n";
	my $s = check_switch_system($serviceid, $expire, $hostname, $snmp_version, $community, $username, $password);
	$s .= check_switch_temperature($serviceid, $expire, $hostname, $snmp_version, $community, $username, $password);
	$s .= check_switch_fans($serviceid, $expire, $hostname, $snmp_version, $community, $username, $password);
	$s .= check_switch_load($serviceid, $expire, $hostname, $snmp_version, $community, $username, $password);
	$s .= check_switch_process_count($serviceid, $expire, $hostname, $snmp_version, $community, $username, $password);
	$s .= check_switch_ram($serviceid, $expire, $hostname, $snmp_version, $community, $username, $password);

	if ($s == '') {
		return '';
	}
	return "<system><name>$system_name</name>$s</system>";
}

my ($systems_file, $expire) = @ARGV;
my $serviceid = get_serviceid('switch');
my $xml = new XML::Simple;
my $data = $xml->XMLin($systems_file);
my $xml_str = '';
#print STDERR Dumper($data);
if( ref($data->{'record'}) eq 'ARRAY' ) {
	foreach my $h (@{$data->{'record'}}) {
		$xml_str .= check_switch($h->{'isactive'}, $serviceid, $expire, $h->{'system_name'}, $h->{'hostname'}, 
					$h->{'snmp_version'}, $h->{'community'}, $h->{'username'}, $h->{'password'});
	}
}
else {
	$xml_str = check_switch($data->{'record'}->{'isactive'}, $serviceid, $expire, $data->{'record'}->{'system_name'}, 
				$data->{'record'}->{'hostname'}, $data->{'record'}->{'snmp_version'}, $data->{'record'}->{'community'},
				$data->{'record'}->{'username'}, $data->{'record'}->{'password'});
}
print $xml_str;
