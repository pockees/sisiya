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

if (-f $SisIYA_Config::local_conf) {
	require $SisIYA_Config::local_conf;
}
if (-f $SisIYA_Config::functions) {
	require $SisIYA_Config::functions;
}
#######################################################################################
#######################################################################################
#### the default values
our %users = ( 'error' => 100, 'warning' => 95 );
our $env_bse = '/infor/erpln/bse';
our $env_slmhome = '/infor/slm';
our @slm_servers = ( 'localhost' );
our $env_bse_tmp = "$env_bse/tmp";
#### end of the default values
#######################################################################################
my $service_name = 'baan_users';
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
my $retcode;
my @a;

### set environment variables
$ENV{'BSE'} = $env_bse;
$ENV{'BSE_TMP'} = $env_bse_tmp;
$ENV{'SLMHOME'} = $env_slmhome;
if (! -f $SisIYA_Config::external_progs{'licmon'}) {
	if (! -f $SisIYA_Config::external_progs{'SlmCmd'}) {
		$statusid = $SisIYA_Config::statusids{'error'};
		$message_str = "ERROR: Neither $SisIYA_Config::external_progs{'SlmCmd'} nor $SisIYA_Config::external_progs{'licmon'} program does not exist!";
		print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
	}
	else {
		my $s;
		my $total_users;
		my $server_license_count = 0;
		my $desktop_license_count = 0;
		my ($concurrent_license_count, $named_license_count);

		for my $i (0..$#slm_servers) {
			@a = `$SisIYA_Config::external_progs{'SlmCmd'} -mondts $slm_servers[$i]`;
			$retcode = $? >>=8;
			if ($retcode != 0) {
				$error_str .= " ERROR: Could not execute $SisIYA_Config::external_progs{'SlmCmd'} command!";
			}
			#print STDERR @a;
			chomp(@a = @a);
			$s = "@a";
			$s =~ s/\s+//g;
			#print STDERR "s=[$s]\n";
			#$concurrent_license_count += (split(/"/, (split(/<concurrentLicensecount="/, $s))[1]))[0];
			$concurrent_license_count += (split(/"/, (split(/<productid="10996"count="/, $s))[1]))[0];
			$named_license_count += (split(/"/, (split(/<userLicensecount="/, $s))[1]))[0];
			if ($server_license_count == 0) {
				$server_license_count += (split(/"/, (split(/<serverLicensecount="/, $s))[1]))[0];
			}
			if ($desktop_license_count == 0) {
				$desktop_license_count += (split(/"/, (split(/<desktopLicensecount="/, $s))[1]))[0];
			}
			#print STDERR "concurrent license count = [$concurrent_license_count] named user license count = [$named_license_count] server license count = [$server_license_count] desktop license count = [$desktop_license_count]\n";
		}
		$total_users = $concurrent_license_count + $named_license_count;
		$data_str = '<entries>';
		$data_str .= '<entry name="baan_total_user_count" type="numeric">'.$total_users.'</entry>';
		if ($total_users >= $users{'error'}) {
			$error_str = "ERROR: Number of total users is $total_users (>=$users{'error'})!";
		}
		elsif ($total_users >= $users{'warning'}) {
			$warning_str = "WARNING: Number of total users is $total_users (>=$users{'warning'})!";
		}
		else {
			$ok_str = "OK: Number of total users is $total_users.";
		}
	       	if ($concurrent_license_count > 0) {
			$info_str .= "INFO: Number of concurrent users is $concurrent_license_count.";
			$data_str .= '<entry name="baan_concurrent_users_count" type="numeric">'.$concurrent_license_count.'</entry>';
		}
	       	if ($named_license_count > 0) {
			$info_str .= "INFO: Number of named users is $named_license_count.";
			$data_str .= '<entry name="baan_named_users_count" type="numeric">'.$named_license_count.'</entry>';
		}
	       	if ($desktop_license_count > 0) {
			$info_str .= "INFO: Number of desktop licenses is $desktop_license_count.";
			$data_str .= '<entry name="baan_desktop_license_count" type="numeric">'.$desktop_license_count.'</entry>';
		}
	       	if ($server_license_count > 0) {
			$info_str .= "INFO: Number of server licenses is $server_license_count.";
			$data_str .= '<entry name="baan_server_license_count" type="numeric">'.$server_license_count.'</entry>';
		}
		$data_str .= '</entries>';
	}
}
else {
	@a = `$SisIYA_Config::external_progs{'licmon'} -u`;
	#print STDERR @a;
	$retcode = $? >>=8;
	if ($retcode != 0) {
		$error_str .= " ERROR: Could not execute $SisIYA_Config::external_progs{'licmon'} command!";
	}
	else {
		#chomp(@a = @a);
		my $s = (grep(/TOTAL/, @a))[0];
		chomp($s = $s);
		#print STDERR "s=[$s]\n;";
		my $licmon_count = (split(/\s+/, $s))[1] + (split(/\s+/, $s))[2] + (split(/\s+/, $s))[3];
		#my $licmon_count = $x + $y + $z;
		if ($licmon_count >= $users{'error'}) {
			$error_str .= " ERROR: Number of users is $licmon_count (>=$users{'error'})!";
		}
		elsif ($licmon_count >= $users{'warning'}) {
			$warning_str .= " WARNING: Number of users is $licmon_count (>=$users{'warning'})!";
		}
		else {
			$ok_str .= " OK: Number of users is $licmon_count.";
		}
		$data_str = '<entries>';
		$data_str .= '<entry name="baan_total_user_count" type="numeric">'.$licmon_count.'</entry>';
		$data_str .= '</entries>';
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
#  ---------- USERS ---------
#  SERVER         MON/SETUP      BA    BX/BW
#  baan4-alt.altiniplik.com.tr        1        0        0
#  ======== ======== ======== +
#  TOTAL                 1        0        0
#
