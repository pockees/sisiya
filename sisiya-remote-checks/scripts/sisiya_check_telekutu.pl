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
###########################################################################################################
# default values
our %uptimes = ('error' => 1440, 'warning' => 4320);
# One can override there default values in the $SisIYA_RemoteConfig::conf_dir/switch_system_$system_name.pl
# end of default values
############################################################################################################

sub check_telekutu
{
	my ($isactive, $serviceid, $expire, $system_name, $hostname, $index_file, $http_port, $username, $password) = @_;

	if ($isactive eq 'f' ) {
		return '';
	}

	print STDERR "Checking system_name=[$system_name] hostname=[$hostname] serviceid=[$serviceid] isactive=[$isactive] index_file=[$index_file] http_port=[$http_port] username=[$username] password=[$password] ...\n";

	my $serviceid = get_serviceid('system');
	my $statusid = $SisIYA_Config::statusids{'ok'};
	my $params = '--max-time 4 --include';
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
		$s = "OK: connected";
		print STDERR (grep(/Host Name/i, @a))[0];
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
			$up_hours 	= (split(/:/,   $str))[0];
			$up_minutes 	= (split(/:/,   $str))[1];
		} else {
			$up_days 	= 0;
			$up_hours 	= (split(/:/, (split(/\s+/, $str))[3]))[0];
			$up_minutes 	= (split(/:/, (split(/\s+/, $str))[3]))[1];
		}
		$up_in_minutes = 1440 * $up_days + 60 * $up_hours + $up_minutes;
		if ($up_in_minutes <= $uptimes{'error'}) {
			$statusid = $SisIYA_Config::statusids{'error'};
			$s = "ERROR: The systems was restarted ".minutes2string($up_in_minutes). " (<= ".minutes2string($uptimes{'error'}).") ago!";
		} elsif ($up_in_minutes <= $uptimes{'warning'}) {
			$statusid = $SisIYA_Config::statusids{'warning'};
			$s = "WARNING: The systems was restarted ".minutes2string($up_in_minutes). " (<= ".minutes2string($uptimes{'warning'}).") ago!";
		} else {
			$s = "OK: The system is up for ".minutes2string($up_in_minutes). ".";
		}
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
