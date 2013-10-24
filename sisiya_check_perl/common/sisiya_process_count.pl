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
our %process_counts = ('error' => 1000, 'warning' => 800);
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
my @a = `ps -ef`;
my $n = @a;
if($n >= $process_counts{'error'}) {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = "ERROR: There are $n (>= $process_counts{'error'}) running processes!";
}
elsif($n >= $process_counts{'warning'}) {
	$statusid = $SisIYA_Config::statusids{'warning'};
	$message_str = "WARNING: There are $n (>= $process_counts{'warning'}) running processes!";
}
else {
	$message_str = "OK: There are $n running processes.";
}
################################################################################
print "process_count$SisIYA_Config::FS<msg>$message_str</msg><datamsg></datamsg>\n";
exit $statusid;
################################################################################
