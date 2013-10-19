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
our %percents = ( 'warning' => 95, 'error' => 90 );
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
my $message_str = '';
my $statusid = $SisIYA_Config::statusids{'ok'};
my $service_name = 'oracle_tablespace';
my $error_str = '';
my $ok_str = '';
my $warning_str = '';

### set environment variables
$ENV{'ORACLE_HOME'} = $env_oracle_home;
$ENV{'PATH'} = $env_oracle_bin.':'.$ENV{'PATH'};
$ENV{'NLS_LANG'} = $env_nls_lang;

my %tablespaces;
my $sql_file = $SisIYA_Config::sisiya_special_dir.'/sisiya_oracle_tablespace.sql';
my @a = `$sqlplus_prog -S $db_user/$db_password\@$db_name \@$sql_file`;
my @b;
#print STDERR "@a\n";
foreach(@a) {
	chomp($_);
	@b = split(/[ \t]+/, $_);
	$tablespaces{$b[0]}{'total'} = $b[1]; 
	$tablespaces{$b[0]}{'used'} = $b[2]; 
	$tablespaces{$b[0]}{'free'} = $b[3]; 
	$tablespaces{$b[0]}{'percent'} = $b[4]; 
}
for my $k (keys %tablespaces) {
	#print STDERR "-----> : key=[$k] total=[$tablespaces{$k}{'total'}] used=[$tablespaces{$k}{'used'}] free=[$tablespaces{$k}{'free'}] percent=[$tablespaces{$k}{'percent'}]\n";
		if($tablespaces{$k}{'percent'} >= $percents{'error'}) {
			$error_str .= "ERROR: $k $tablespaces{$k}{'percent'}\% (>= $percents{'error'}) of ".get_size_k($tablespaces{$k}{'total'})." is full!";
		}
		elsif($tablespaces{$k}{'percent'} >= $percents{'warning'}) {
			$warning_str .= "WARNING: $k $tablespaces{$k}{'percent'}\% (>= $percents{'warning'}) of ".get_size($tablespaces{$k}{'total'})." is full!";
		}
		else {
			$ok_str .= "OK: $k $tablespaces{$k}{'percent'}\% of ".get_size($tablespaces{$k}{'total'})." is full.";
		}
}


if($error_str ne '') {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = "$error_str";
}
elsif($warning_str ne '') {
	if($statusid < $SisIYA_Config::statusids{'warning'}) {
		$statusid = $SisIYA_Config::statusids{'warning'};
	}	
	$message_str .= " $warning_str";
}
if($ok_str ne '') {
	$message_str .= " $ok_str";
}
################################################################################
#print "listening_socket$SisIYA_Config::FS<msg>$message_str</msg><datamsg></datamsg>\n";
#exit $statusid;
sisiya_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str);
################################################################################
