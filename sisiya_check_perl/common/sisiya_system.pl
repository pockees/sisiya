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

sub minutes2string
{
	my ($days, $hours, $minutes);
	my $total_minutes = $_[0];

	$days = int($total_minutes / 1440);
	$total_minutes = $total_minutes - $days * 1440;

	$hours = int($total_minutes / 60);
	$minutes = $total_minutes - $hours * 60;

	#print "days = $days hours = $hours minutes = $minutes\n";

	my $str = '';
	if($days > 0) {
		$str = "$days day";
		if($days > 1) {
			$str .= 's';
		}
	}
	if($hours > 0) {
		if($str ne '') {
			$str .= ' ';
		}
		$str .= "$hours hour";
		if($hours > 1) {
			$str .= 's';
		}
	}
	if($minutes > 0) {
		if($str ne '') {
			$str .= ' ';
		}
		$str .= "$minutes minute";
		if($minutes > 1) {
			$str .= 's';
		}
	}

	#return "$_[0] minutes";
	return "$str";
}

sub get_uptime_in_minutes
{
	my $x;
	my $uptime_in_minutes = 0;

	#chomp($x = `/bin/cat /proc/uptime`);
	if($SisIYA_Config::sisiya_osname eq 'Linux') {
		my $file;
		open($file, '<', '/proc/uptime') || die "$0: Could not open file /proc/uptime! $!";
		$x = <$file>;
		close $file;
		chomp($x);
			#my @a = split(/\./, $x); 
			#$uptime_in_minutes = int($a[0] / 60);
		$uptime_in_minutes = int( (split(/\./, $x))[0] / 60 ); 
	}
	return $uptime_in_minutes;
}

###############################################################################
### the default values
# uptimes are given in minutes
our %uptimes = ('error' => 1440, 'warning' => 4320);
### to get information about the server
our $info_prog = '';
##our $info_prog="$SisIYA_Config::sisiya_base_dir/special/sisiya_system_info_hpasm.sh"
our $version_file = "$SisIYA_Config::sisiya_base_dir/version.txt";
#### end of the default values
################################################################################
# override defaults if there is a corresponfing conf file
my $module_conf_file = "$SisIYA_Config::sisiya_systems_conf_dir/".`basename $0`;
chomp($module_conf_file);
if(-f $module_conf_file) {
	require $module_conf_file;
}
################################################################################
my $uptime_in_minutes = get_uptime_in_minutes;
my $message_str;
my $statusid = $SisIYA_Config::statusids{'ok'};
if($uptime_in_minutes < $uptimes{'error'}) {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = 'ERROR:The system was restarted '.minutes2string($uptime_in_minutes).' (< '.minutes2string($uptimes{'error'}).') ago!';
}
elsif($uptime_in_minutes < $uptimes{'warning'}) {
	$statusid = $SisIYA_Config::statusids{'warning'};
	$message_str = 'WARNING:The system was restarted '.minutes2string($uptime_in_minutes).' (< '.minutes2string($uptimes{'warning'}).') ago!';
}
else {
	$message_str = 'OK:The system is up since '.minutes2string($uptime_in_minutes);
}
my $x;
if($SisIYA_Config::sisiya_osname eq 'HP-UX') {
	chomp($x = `/bin/uname -srm`);
}
else {
	chomp($x = `/bin/uname -srmp`);
}
my $file;
$message_str .= " Info: $x";
# add OS version
if($SisIYA_Config::sisiya_osname eq 'Linux') {
	if(open($file, '<', '/etc/issue.net')) {
		$x = <$file>;
		chomp($x);
		close($file);
		$message_str .= " OS: $x";
	}
}
# add SisIYA version
if($version_file ne '') {
	if(open($file, '<', $version_file)) {
		$x = <$file>;
		chomp($x);
		close($file);
		$message_str .= " SisIYA: $x";
	}
}

# add other information via an external info
if($info_prog ne '') {
	chomp($x = `$info_prog`);
	$message_str .= " Details: $x";
}
################################################################################
print "system$SisIYA_Config::FS<msg>$message_str</msg><datamsg></datamsg>\n";
exit $statusid;
################################################################################
