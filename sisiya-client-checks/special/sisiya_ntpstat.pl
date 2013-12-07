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

if(-f $SisIYA_Config::local_conf) {
	require $SisIYA_Config::local_conf;
}
if(-f $SisIYA_Config::functions) {
	require $SisIYA_Config::functions;
}
#######################################################################################
###############################################################################
#### the default values
our $ntpstat_prog = '/usr/bin/ntpstat';
our $ntpq_prog = '/usr/bin/ntpq';
#### end of the default values
################################################################################
sub get_synchronized_peer
{
	###############################################################################
	# ntpq -np
	###############################################################################
	# remote           refid      st t when poll reach   delay   offset  jitter
	#==============================================================================
	# 141.82.49.100   .INIT.          16 u    - 1024    0    0.000    0.000   0.000
	# 141.82.49.102   .INIT.          16 u    - 1024    0    0.000    0.000   0.000
	#*130.149.17.8    .GPS.            1 u  226 1024  377   61.753    6.097   0.745
	# 192.53.103.108  .INIT.          16 u    - 1024    0    0.000    0.000   0.000
	#+192.53.103.104  .PTB.            1 u  445 1024  373   78.638   -4.048   0.671
	###############################################################################
	###############################################################################
	# ntpstat 
	###############################################################################
	# synchronised to NTP server (10.10.14.1) at stratum 3 
	#    time correct to within 78 ms
	#       polling server every 1024 s
	#
	###############################################################################
	if(grep(/NTP/, @_)) {
		if(index($_[0], '(') != -1) {
			my @a = split(/\(/, $_[0]);
			if(index($a[1], ')') != -1) {
				@a = split(/\)/, $a[1]);
				return $a[0];
			}
		}	
	}
	else {
		foreach(my $i = 0; $i < @_; $i++) {
			if(substr($_[$i], 0, 1) eq '*') {
				my @a = split(/ /, $_[$i]);
				@a = split(/\*/, $a[0]);
				return $a[1];
			}
		}	
	}
	return '';
}

## override defaults if there is a corresponfing conf file
my $module_conf_file = "$SisIYA_Config::systems_conf_dir/".`basename $0`;
chomp($module_conf_file);
if(-f $module_conf_file) {
	require $module_conf_file;
}

################################################################################
my $message_str = '';
my $data_str = '';
my $statusid = $SisIYA_Config::statusids{'error'};
my $service_name = 'ntpstat';
my @a = `$ntpstat_prog 2>/dev/null`;
my $retcode = $? >>=8;

if($retcode == 0) {
	#######################################################       
	# ntpstat 
	#######################################################       
	# synchronised to NTP server (10.10.14.1) at stratum 3 
	#    time correct to within 78 ms
	#       polling server every 1024 s
	#
	#######################################################       
	# but it should not be synchronized to its local clock
	$statusid = $SisIYA_Config::statusids{'ok'};
	my $s = (split(/\(/, (grep(/synchronised to NTP server/, @a))[0]))[1];
	chomp($s = $s);
	$s =~ s/\)//g;
	$message_str = "OK: The system clock is synchronized to $s.";
}
elsif($retcode == 1) {
	#######################################################       
	# ntpstat 
	#######################################################       
	# unsynchronised
	#  time server re-starting
	#   polling server every 64 s
	#######################################################       
	$message_str = "ERROR: The system clock is not synchronized!";
}
elsif($retcode == 2) {
	$message_str = "ERROR: The system clock is not synchronized! Could not contact the ntp daemon!";
}
elsif($retcode == 127) {
	@a = `$ntpq_prog -np 2>&1`;
	$retcode = $? >>=8;
	if(grep(/Connection refused/, @a)) {
		print STDERR "Connection refused\n";
		$message_str = "ERROR: The system clock is not synchronized! The ntp daemon is not running!";
	}
	else {
		if($retcode == 0) {
			my $p = get_synchronized_peer(@a);
			if($p ne '') {
				$statusid = $SisIYA_Config::statusids{'ok'};
				$message_str = "OK: The system clock is synchronized to $p.";
			}
			else {
				$statusid = $SisIYA_Config::statusids{'warning'};
				$message_str = "WARNING: The system clock is not yet synchronized!";
			}
		}
		else {
			$message_str = "ERROR: The system clock is not synchronized! Unknown return code $retcode!";
		}
	}
}
###################################################################################
print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
###################################################################################
