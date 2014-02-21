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

my $check_name = 'telekutu';

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
###########################################################################################################
# default values
our %uptimes = ('error' => 1440, 'warning' => 4320);
# One can override there default values in the $SisIYA_RemoteConfig::conf_dir/switch_system_$system_name.pl
# end of default values
############################################################################################################

sub check_telekutu
{
	my ($isactive, $expire, $system_name, $hostname, $index_file, $http_port, $username, $password) = @_;

	if ($isactive eq 'f' ) {
		return '';
	}


	my $serviceid = get_serviceid('system');
	my $statusid = $SisIYA_Config::statusids{'ok'};
	my $params = '--max-time 4 --include';
	#print STDERR "Checking system_name=[$system_name] hostname=[$hostname] serviceid=[$serviceid] isactive=[$isactive] index_file=[$index_file] http_port=[$http_port] username=[$username] password=[$password] ...\n";
	if (grep(/^HASH/, $username) == 0) {
	       $params = "$params --user \"$username:$password\"";
	}	       
	my @a = `$SisIYA_Remote_Config::external_progs{'curl'} $params http://$hostname:$http_port$index_file 2>/dev/null`;
	my ($s, $x_str);
	my $retcode = $? >>=8;
	if($retcode != 0) {
		$statusid = $SisIYA_Config::statusids{'error'};
		$s = "ERROR: Could not connect to $hostname!";
	} else {
		my $hostname_str 	= (split(/</, (split(/>/, (split(/:/,	(grep(/Host Name/i, 		@a))[0]))[1]))[2]))[0];
		my $product_str 	= (split(/</, (split(/>/, (split(/:/,	(grep(/Product Name/i, 		@a))[0]))[1]))[2]))[0];
		my $sw_str 		= (split(/</, (split(/>/, (split(/:/,	(grep(/Software Version/i, 	@a))[0]))[1]))[2]))[0];
		my $sn_str 		= (split(/</, (split(/>/, (split(/:/,	(grep(/Serial Number/i,	 	@a))[0]))[2]))[2]))[0];
		my $hw_str 		= (split(/</, (split(/>/, (split(/:/,	(grep(/Hardware Version/i, 	@a))[0]))[2]))[2]))[0];
		my $uid_str 		= (split(/</, (split(/>/, (split(/:/,	(grep(/User ID/i,	 	@a))[0]))[2]))[2]))[0];
		my $str 		= (split(/</, (split(/>/, 		(grep(/Elapsed Time/i,	 	@a))[0]))[10]))[0];
		#"9 days and 12:06:42"
		#"1 day and 12:06:42"
		my ($up_days, $up_hours, $up_minutes, $uptime);
		if (grep(/day/, $str)) {
			$up_days 	= (split(/\s+/, $str))[0];
			$up_hours 	= (split(/\s+/, (split(/:/, $str))[0]))[3];
			$up_minutes 	= (split(/:/, $str))[1];
		} else {
			$up_days 	= 0;
			$up_hours 	= (split(/:/, (split(/\s+/, $str))[3]))[0];
			$up_minutes 	= (split(/:/, (split(/\s+/, $str))[3]))[1];
		}
		my $up_in_minutes = 1440 * $up_days + 60 * $up_hours + $up_minutes;
		$s = check_uptime(\$statusid, $up_in_minutes, $uptimes{'warning'}, $uptimes{'error'});
		$s .= "INFO: Hostname: $hostname_str Product name: $product_str Software version: $sw_str Serial number: $sn_str Hardware version: $hw_str User ID: $uid_str.";
		$x_str = "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message>";

		# check line status
		$serviceid = get_serviceid('linestatus');
		$statusid = $SisIYA_Config::statusids{'ok'};
		$str = (split(/</, (split(/>/, (grep(/Registration State/i, @a))[0]))[10]))[0];
		$str =~ s/'/ /g;
		if (grep(/Online/i, $str)) {
			$s = "OK: $str.";
		} else {
			$statusid = $SisIYA_Config::statusids{'error'};
			$s = "ERROR: $str!";
		}
		$x_str .= "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message>";
	}
	return "<system><name>$system_name</name>$x_str</system>";
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
if (ref($data->{'record'}) eq 'ARRAY' ) {
	foreach my $h (@{$data->{'record'}}) {
		$xml_str .= check_telekutu($h->{'isactive'},  $expire, $h->{'system_name'}, $h->{'hostname'}, 
						$h->{'index_file'}, $h->{'http_port'}, $h->{'username'}, $h->{'password'}, 0);
	}
} else {
	$xml_str = check_telekutu($data->{'record'}->{'isactive'}, $expire, $data->{'record'}->{'system_name'}, 
					$data->{'record'}->{'hostname'}, $data->{'record'}->{'index_file'}, $data->{'record'}->{'http_port'}, 
					$data->{'record'}->{'username'}, $data->{'record'}->{'password'}, 0); 
}
unlock_check($check_name);
print $xml_str;
