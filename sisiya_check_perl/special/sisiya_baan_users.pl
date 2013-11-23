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

if(-f $SisIYA_Config::sisiya_local_conf) {
	require $SisIYA_Config::sisiya_local_conf;
}
if(-f $SisIYA_Config::sisiya_functions) {
	require $SisIYA_Config::sisiya_functions;
}
#######################################################################################
###############################################################################
#### the default values
our $licmon_prog = '/infor/baan/bse/bin/licmon6.1';
our %users = ( 'error' => 100, 'warning' => 95 );
our $env_bse = '/infor/erpln/bse';
our $slmcmd_prog = '/infor/slm/bin/SlmCmd';
our @slm_servers = ( 'localhost' );
our $env_bse_tmp = "$env_bse/tmp";
#### end of the default values
################################################################################
## override defaults if there is a corresponfing conf file
my $module_conf_file = "$SisIYA_Config::sisiya_systems_conf_dir/".`basename $0`;
chomp($module_conf_file);
if(-f $module_conf_file) {
	require $module_conf_file;
}
################################################################################
my $message_str = '';
my $statusid = $SisIYA_Config::statusids{'ok'};
my $service_name = 'baan_users';
my $error_str = '';
my $info_str = '';
my $ok_str = '';
my $warning_str = '';

my $retcode;
my @a;

### set environment variables
$ENV{'BSE'} = $env_bse;
$ENV{'BSE_TMP'} = $env_bse_tmp;
if(! -f $licmon_prog) {
	if(! -f $slmcmd_prog) {
		exit;
	}
	else {
		my $s;
		my $total_users;
		my $server_license_count = 0;
		my $desktop_license_count = 0;
		my ($concurrent_license_count, $named_license_count);
		for my $i (0..$#slm_servers) {
			@a = `$slmcmd_prog -mondts $slm_servers[$i]`;
			$retcode = $? >>=8;
			if($retcode != 0) {
				$error_str .= " ERROR: Could not execute $slmcmd_prog command!";
			}
			#print STDERR @a;
			chomp(@a = @a);
			$s = "@a";
			$s =~ s/\s+//g;
			#print STDERR "s=[$s]\n";
			$concurrent_license_count += (split(/"/, (split(/<concurrentLicensecount="/, $s))[1]))[0];
			$named_license_count += (split(/"/, (split(/<userLicensecount="/, $s))[1]))[0];
			if($server_license_count == 0) {
				$server_license_count += (split(/"/, (split(/<serverLicensecount="/, $s))[1]))[0];
			}
			if($desktop_license_count == 0) {
				$desktop_license_count += (split(/"/, (split(/<desktopLicensecount="/, $s))[1]))[0];
			}
			#print STDERR "concurrent license count = [$concurrent_license_count] named user license count = [$named_license_count] server license count = [$server_license_count] desktop license count = [$desktop_license_count]\n";
		}
		$total_users = $concurrent_license_count + $named_license_count;
		if($total_users >= $users{'error'}) {
			$error_str = "ERROR: Number of total users is $total_users (>=$users{'error'})!";
		}
		elsif($total_users >= $users{'warning'}) {
			$warning_str = "WARNING: Number of total users is $total_users (>=$users{'warning'})!";
		}
		else {
			$ok_str = "OK: Number of total users is $total_users.";
		}
	       	if($concurrent_license_count > 0) {
			$info_str .= "INFO: Number of concurrent users is $concurrent_license_count.";
		}
	       	if($named_license_count > 0) {
			$info_str .= "INFO: Number of named users is $named_license_count.";
		}
	       	if($desktop_license_count > 0) {
			$info_str .= "INFO: Number of desktop licenses is $desktop_license_count.";
		}
	       	if($server_license_count > 0) {
			$info_str .= "INFO: Number of server licenses is $server_license_count.";
		}
	}
}
else {
	@a = `$licmon_prog -u`;
	#print STDERR @a;
	$retcode = $? >>=8;
	if($retcode != 0) {
		$error_str .= " ERROR: Could not execute $licmon_prog command!";
	}
	else {
		#chomp(@a = @a);
		my $s = (grep(/TOTAL/, @a))[0];
		chomp($s = $s);
		#print STDERR "s=[$s]\n;";
		my $licmon_count = (split(/\s+/, $s))[1] + (split(/\s+/, $s))[2] + (split(/\s+/, $s))[3];
		#my $licmon_count = $x + $y + $z;
		if($licmon_count >= $users{'error'}) {
			$error_str .= " ERROR: Number of users is $licmon_count (>=$users{'error'})!";
		}
		elsif($licmon_count >= $users{'warning'}) {
			$warning_str .= " WARNING: Number of users is $licmon_count (>=$users{'warning'})!";
		}
		else {
			$ok_str .= " OK: Number of users is $licmon_count.";
		}
	}
}

if($error_str ne '') {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = "$error_str";
}
if($warning_str ne '') {
	if($statusid < $SisIYA_Config::statusids{'warning'}) {
		$statusid = $SisIYA_Config::statusids{'warning'};
	}	
	$message_str .= " $warning_str";
}
if($ok_str ne '') {
	$message_str .= " $ok_str";
}
if($info_str ne '') {
	$message_str .= " $info_str";
}
################################################################################
#print "listening_socket$SisIYA_Config::FS<msg>$message_str</msg><datamsg></datamsg>\n";
#exit $statusid;
sisiya_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str);
################################################################################
#  ---------- USERS ---------
#  SERVER         MON/SETUP      BA    BX/BW
#  baan4-alt.altiniplik.com.tr        1        0        0
#  ======== ======== ======== +
#  TOTAL                 1        0        0
#
