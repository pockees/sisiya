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
our @exception_users;
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
my $statusid = $SisIYA_Config::statusids{'info'};
my @users;

if($SisIYA_Config::sisiya_osname eq 'HP-UX') {
	chomp(@users = `who -R | grep "root"`);
}
else {
	chomp(@users = `who | grep "root"`);
}
#print STDERR "Before:\n";
#foreach(@users) {
#	print STDERR "$_\n";
#}
my @a = @users;
my $x;
foreach my $user(@exception_users) {
	# remove from the array
	#print STDERR "Searching for $user logged in users list...\n";
	foreach $x(@a) {
		if(index($x, $user) != -1) {
			#print STDERR "Removing $user from the logged in users list...\n";
			@a = grep ! /$user/, @a;
		}
	}
}
#print STDERR "After:\n";
#foreach(@a) {
#	print STDERR "$_\n";
#}
if(@a) {
	$statusid = $SisIYA_Config::statusids{'warning'};
	$message_str = "User root is logged in!";
}
chomp(@users = `who`);
if(@users) {
	my @only_usernames;
	my @a1;
	foreach(@users) {
		@a1 = split(/ /, $_);
		push(@only_usernames, $a1[0]);
	}
	my %h = map { $_, 1 } @only_usernames;
	@only_usernames = keys %h;
	@users = sort @only_usernames;
	$message_str .= " User list: ";
	foreach(@users) {
		$message_str .= " $_";
		#print STDERR "$_\n";
	}
}
else {
	$message_str = "No user is logged in.";
}
################################################################################
print "users$SisIYA_Config::FS<msg>$message_str</msg><datamsg></datamsg>\n";
exit $statusid;
################################################################################
