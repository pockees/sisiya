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
our $log_file = '/var/log/secure';
our @strings = ('bad username', 'illegal', 'Invalid user', 'failed password for', 'POSSIBLE BREAKIN ATTEMPT');
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
my $service_name = 'ssh_attack';
my $error_messages = '';
my $warning_messages = '';
my $ok_messages = '';

if(! -f $log_file) {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = "ERROR: Could not find log file $log_file!";
	sisiya_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str);
}
my $file;
open($file, '<', $log_file) || die "$0: Could not open file $log_file! $!";
my @a = <$file>;
close $file;
my $s;
my @b;
foreach my $x (@strings) {
	#print STDERR "Searching for [$x] in $log_file...\n";
	@b = grep(/$x/, @a);
	#print STDERR @b;
	chomp(@b = @b);
	$s = "@b";
	#print STDERR "s=[$s]\n";
	if($s ne '') {
		$error_messages .= " ERROR: $x ($s)!";
	}
	else {
		$ok_messages .= "[$x]";
	}
}
if($error_messages ne '') {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = $error_messages;
}
if($warning_messages ne '') {
	if($statusid < $SisIYA_Config::statusids{'warning'}) {
		$statusid = $SisIYA_Config::statusids{'warning'};
	}
	$message_str .= $warning_messages;
}
if($ok_messages ne '') {
	$message_str .= " OK: $log_file does not contain any of $ok_messages";
}

# replace the ' with whitespace => no need anymore, it is replaced in sisiya_all.pl with \'
#$message_str =~ s/\'/ /g; 
################################################################################
sisiya_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str);
################################################################################
