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
################################################################################
## the default values
# uptimes are given in minutes
our %uptimes = ('error' => 1440, 'warning' => 4320);
### to get information about the server
our $info_prog = '';
##our $info_prog="$SisIYA_Config::base_dir/special/system_info_hpasm.sh"
our $version_file = "/usr/share/doc/sisiya-client-checks/version.txt";
#### end of the default values
################################################################################
my $service_name = 'system';
## override defaults if there is a corresponding conf file
my $module_conf_file = "$SisIYA_Config::conf_d_dir/sisiya_$service_name.conf";
if (-f $module_conf_file) {
	require $module_conf_file;
}
################################################################################
my $message_str;
my $data_str = '';
my $statusid = $SisIYA_Config::statusids{'ok'};

sub get_uptime_in_minutes
{
	my $x;
	my $uptime_in_minutes = 0;

	if ($SisIYA_Config::osname eq 'Linux') {
		my $file;
		open($file, '<', '/proc/uptime') || die "$0: Could not open file /proc/uptime! $!";
		$x = <$file>;
		close $file;
		#chomp($x);
			#my @a = split(/\./, $x); 
			#$uptime_in_minutes = int($a[0] / 60);
		$uptime_in_minutes = int( (split(/\./, $x))[0] / 60 ); 
	}
	if ($SisIYA_Config::osname eq 'SunOS') {
		#uptime   
		# 11:52am  up  1 user,  load average: 0.04, 0.02, 0.04
		if (! -f $SisIYA_Config::external_progs{'uptime'}) {
			$statusid = $SisIYA_Config::statusids{'error'};
			$message_str = "ERROR: External program $SisIYA_Config::external_progs{'uptime'} does not exist!";
			print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
		}
		my @a = `$SisIYA_Config::external_progs{'uptime'}`;
		my $retcode = $? >>=8;
		if ($retcode != 0) {
			$statusid = $SisIYA_Config::statusids{'error'};
			$message_str = "ERROR: Error executing the uptime command $SisIYA_Config::external_progs{'uptime'}! retcode=$retcode";
			print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
		}
		else {
			$x = (split(/m/, $a[0]))[0];
			my $days = 0;
			my $s = (split(/\s+/, $x))[1];
			$s = (split(/[a,p]/, $s))[0];
			$uptime_in_minutes = 24 * (split(/:/, $s))[0] + (split(/:/, $s))[1];
			print STDERR "x=[$x] s=[$s]\n";
			$x = 0;
		}

	}
	return $uptime_in_minutes;
}

###############################################################################
my $uptime_in_minutes = get_uptime_in_minutes;

if ($uptime_in_minutes < $uptimes{'error'}) {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = 'ERROR:The system was restarted '.minutes2string($uptime_in_minutes).' (< '.minutes2string($uptimes{'error'}).') ago!';
}
elsif ($uptime_in_minutes < $uptimes{'warning'}) {
	$statusid = $SisIYA_Config::statusids{'warning'};
	$message_str = 'WARNING:The system was restarted '.minutes2string($uptime_in_minutes).' (< '.minutes2string($uptimes{'warning'}).') ago!';
}
else {
	$message_str = 'OK:The system is up for '.minutes2string($uptime_in_minutes);
}
my $x;
if ($SisIYA_Config::osname eq 'HP-UX') {
	chomp($x = `/bin/uname -srm`);
}
else {
	chomp($x = `/bin/uname -srmp`);
}
my $file;
$message_str .= " Info: $x";
# add OS version
if ($SisIYA_Config::osname eq 'Linux') {
	if (open($file, '<', '/etc/issue.net')) {
		$x = <$file>;
		chomp($x);
		close($file);
		$message_str .= " OS: $x";
	}
}
# add SisIYA version
if ($version_file ne '') {
	if (open($file, '<', $version_file)) {
		$x = <$file>;
		chomp($x);
		close($file);
		$message_str .= " SisIYA: $x";
	}
}
# add IP information
my @a = `$SisIYA_Config::external_progs{'ip'} -4 a`;
my $retcode = $? >>=8;
if ($retcode == 0) {
	@a = grep(/inet/, @a);
	foreach (@a) {
		$_ = (split(/\s+/, $_))[2];
	}
	#print STDERR "@a\n";
	#chomp(@a = @a);
	$x = "@a";
	$message_str .= " IP: $x";
}

# add other information via an external info
if ($info_prog ne '') {
	chomp($x = `$info_prog`);
	$message_str .= " Details: $x";
}
$data_str = '<entries>';
$data_str .= '<entry name="uptime" type="numeric">'.$uptime_in_minutes.'</entry>';
$data_str .= '</entries>';
###################################################################################
print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
###################################################################################
