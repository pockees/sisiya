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

if (-f $SisIYA_Config::local_conf) {
	require $SisIYA_Config::local_conf;
}
if (-f $SisIYA_Config::functions) {
	require $SisIYA_Config::functions;
}
#######################################################################################
#######################################################################################
#### the default values
our $env_slmhome = '/infor/slm';
our $SisIYA_Config::external_progs{'SlmCmd'} = "$env_slmhome/bin/SlmCmd";
our $slm_license_file = "$env_slmhome/license/1/6005/license.xml";
our $env_bse = '/infor/erpln/bse';
our $env_bse_tmp = "$env_bse/tmp";
our @slm_servers = ( {'server' => 'localhost', 'port' => 6005} );
#### end of the default values
#######################################################################################
my $service_name = 'baan_slm';
## override defaults if there is a corresponding conf file
my $module_conf_file = "$SisIYA_Config::conf_d_dir/sisiya_$service_name.conf";
if (-f $module_conf_file) {
	require $module_conf_file;
}
#######################################################################################
my $message_str = '';
my $data_str = '';
my $statusid = $SisIYA_Config::statusids{'ok'};
my $error_str = '';
my $info_str = '';
my $ok_str = '';
my $warning_str = '';
#push @slm_servers , { 'server' => 'localhost', 'port' => 6005 };

### set environment variables
$ENV{'SLMHOME'} = $env_slmhome;
$ENV{'BSE'} = $env_bse;
$ENV{'BSE_TMP'} = $env_bse_tmp;

my $retcode;
my @a;
my @b;
my $port_str;
my $udpport_str;
my $host_str;
my $mode_str;

if (! -f $SisIYA_Config::external_progs{'SlmCmd'}) {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = "ERROR: External program $SisIYA_Config::external_progs{'SlmCmd'} does not exist!";
	print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
}
for my $i (0..$#slm_servers) {
	#print STDERR "SLM server $slm_servers[$i]{'server'}...\n";
	@a = `$SisIYA_Config::external_progs{'SlmCmd'} -montts $slm_servers[$i]{'server'}`;
	#print STDERR @a;
	$retcode = $? >>=8;
	if ($retcode != 0) {
		$error_str .= " ERROR: Could not connect to SLM server: $slm_servers[$i]{'server'}!";
	}
	else {
		chomp(@a = @a);

		@b = grep(/host=/, @a);
		@b = split(/"/, $b[0]);
		$host_str = $b[1];

		@b = grep(/port=/, @a);
		@b = split(/"/, $b[0]);
		$port_str = $b[1];

		@b = grep(/udpPort=/, @a);
		@b = split(/"/, $b[0]);
		$udpport_str = $b[1];

		@b = grep(/mode=/, @a);
		@b = split(/"/, $b[0]);
		$mode_str = $b[1];

		$ok_str .= " OK: Host: $host_str Port: $port_str UDP Port: $udpport_str Mode: $mode_str";
	}
}

if ($error_str ne '') {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = "$error_str";
}
if ($warning_str ne '') {
	if ($statusid < $SisIYA_Config::statusids{'warning'}) {
		$statusid = $SisIYA_Config::statusids{'warning'};
	}	
	$message_str .= " $warning_str";
}
if ($ok_str ne '') {
	$message_str .= " $ok_str";
}
if ($info_str ne '') {
	$message_str .= " $info_str";
}
###################################################################################
print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
###################################################################################
