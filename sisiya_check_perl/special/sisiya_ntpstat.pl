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
#######################################################################################
###############################################################################
#### the default values
our $ntpstat_prog = '/usr/bin/ntpstat';
our $ntpq_prog = '/usr/bin/ntpq';
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
my $statusid = $SisIYA_Config::statusids{'error'};

#system("$ntpstat_prog 2>/dev/null");
# bitshift by 8 or divide by 256
#my $retcode = $? >>=8;
##my $retcode = $? / 256;
my @a = `$ntpstat_prog 2>/dev/null`;
my $retcode = $? >>=8;
print STDERR "retcode = $retcode \n";
foreach(@a) {
	print STDERR "$_\n";
}
if($retcode == 0) {
	# but it should not be synchronized to its local clock
	$statusid = $SisIYA_Config::statusids{'ok'};
	$message_str = "OK: The system clock is synchronized.";
}
elsif($retcode == 1) {
	$message_str = "ERROR: The system clock is not synchronized!";
}
elsif($retcode == 2) {
	$message_str = "ERROR: The system clock is not synchronized! Could not contact the ntp daemon!";
}
elsif($retcode == 127) {
	@a = `$ntpq_prog -np 2>&1`;
	$retcode = $? >>=8;
	print STDERR "2 retcode = $retcode \n";
	foreach(@a) {
		print STDERR "$_";
	}
	if(grep(/Connection refused/, @a)) {
		print STDERR "Connection refused\n";
		$message_str = "ERROR: The system clock is not synchronized! The ntp daemon is not running!";
	}
	else {
		if($retcode == 0) {
			my $n = @a;
			chomp(my $x = $a[$n-1]);
			print STDERR "n=$n\n";
			print STDERR "last line =$x\n";
			if(substr($x, 0, 1) eq '*') {
				my @b = split(/ /, $x);
				@b = split(/\*/, $b[0]);
				$statusid = $SisIYA_Config::statusids{'ok'};
				$message_str = "OK: The system clock is synchronized to $b[1].";
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
################################################################################
print "ntpstat$SisIYA_Config::FS<msg>$message_str</msg><datamsg></datamsg>\n";
exit $statusid;
################################################################################
