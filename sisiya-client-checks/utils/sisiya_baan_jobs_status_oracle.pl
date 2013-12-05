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
our $sqlplus_prog = 'sqlplus';
our $db_name = 'TIGER';
our $db_user = 'system';
our $db_password = 'manager';
our $env_nls_lang = 'AMERICAN_AMERICA.WE8ISO8859P9';
our $env_oracle_home = '/opt/oracle/product/8.1.7';
our $env_oracle_bin = '/opt/oracle/product/8.1.7/bin';
#### end of the default values
################################################################################
## override defaults if there is a corresponfing conf file
my $module_conf_file = "$SisIYA_Config::sisiya_systems_conf_dir/".`basename $0`;
chomp($module_conf_file);
if(-f $module_conf_file) {
	require $module_conf_file;
}
################################################################################

### set environment variables
$ENV{'ORACLE_HOME'} = $env_oracle_home;
$ENV{'PATH'} = $env_oracle_bin.':'.$ENV{'PATH'};
$ENV{'NLS_LANG'} = $env_nls_lang;

my $sql_file = $SisIYA_Config::sisiya_systems_conf_dir.'/sisiya_baan_jobs_status_oracle.sql';
if(-f $sql_file) {
	my @a = `$sqlplus_prog -S $db_user/$db_password\@$db_name \@$sql_file`;
	print @a;
	#foreach(@a) {
	#	$_ =~ s/\s+/ /g;
	#}	
	#print STDERR @a;
}
