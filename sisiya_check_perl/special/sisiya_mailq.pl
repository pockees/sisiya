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
our $mailq_prog = 'mailq';
our %mailq = ('error' => 5, 'warning' => 3);
#our $mailq_prog = '/opt/sisiya-client-checks/special/sisiya_mailq.sh';
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
my $service_name = 'mailq';

my @a = qx/$mailq_prog/;
my $retcode = $? >>=8;
if($retcode != 0) {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = "ERROR: Error executing the $mailq_prog command! retcode=$retcode";
	sisiya_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str);
}
my $queue_count;
if($a[0] eq "Mail queue is empty\n") {
	$queue_count = 0;
}
else {
	$queue_count = grep(/^[A-Z0-9]/, @a);
}
if($queue_count >= $mailq{'error'}) {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = "ERROR: There are $queue_count (>= $mailq{'error'}) number of mails waiting in the queue!";
}
elsif($queue_count >= $mailq{'warning'}) {
	$statusid = $SisIYA_Config::statusids{'warning'};
	$message_str = "WARNING: There are $queue_count (>= $mailq{'warning'}) number of mails waiting in the queue!";
}
else {
	$statusid = $SisIYA_Config::statusids{'ok'};
	$message_str = "OK: There are no mails in the queue.";
}
################################################################################
#print "listening_socket$SisIYA_Config::FS<msg>$message_str</msg><datamsg></datamsg>\n";
#exit $statusid;
sisiya_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str);
################################################################################
