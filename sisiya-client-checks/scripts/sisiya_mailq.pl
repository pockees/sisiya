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
our $mailq_prog = 'mailq';
our %mailq = ('error' => 5, 'warning' => 3);
#our $mailq_prog = '/usr/share/sisiya-client-checks/utils/sisiya_mailq.sh';
#### end of the default values
#######################################################################################
my $service_name = 'mailq';
## override defaults if there is a corresponding conf file
my $module_conf_file = "$SisIYA_Config::conf_d_dir/sisiya_$service_name.conf";
if (-f $module_conf_file) {
	require $module_conf_file;
}
#######################################################################################
my $message_str = '';
my $data_str = '';
my $statusid = $SisIYA_Config::statusids{'ok'};

my @a = qx/$mailq_prog/;
my $retcode = $? >>=8;
if ($retcode != 0) {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = "ERROR: Error executing the $mailq_prog command! retcode=$retcode";
	print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
}
my $queue_count;
if ($a[0] eq "Mail queue is empty\n") {
	$queue_count = 0;
}
else {
	$queue_count = grep(/^[A-Z0-9]/, @a);
}
if ($queue_count >= $mailq{'error'}) {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = "ERROR: There are $queue_count (>= $mailq{'error'}) number of mails waiting in the queue!";
} elsif ($queue_count >= $mailq{'warning'}) {
	$statusid = $SisIYA_Config::statusids{'warning'};
	$message_str = "WARNING: There are $queue_count (>= $mailq{'warning'}) number of mails waiting in the queue!";
}
else {
	$statusid = $SisIYA_Config::statusids{'ok'};
	$message_str = "OK: There are no mails in the queue.";
}
######################################################################################
print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
######################################################################################
