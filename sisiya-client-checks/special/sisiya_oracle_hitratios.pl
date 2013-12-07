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
our $sqlplus_prog = 'sqlplus';
our %hitratios = ( 
		'buffer_cache' 	=> { 'warning' => 95, 'error' => 90 },
		'dictionary'	=> { 'warning' => 95, 'error' => 90 },
		'library'	=> { 'warning' => 95, 'error' => 90 },
		'nowait'	=> { 'warning' => 95, 'error' => 90 },
		'sort'		=> { 'warning' => 95, 'error' => 90 }
	);
our $db_name = 'TIGER';
our $db_user = 'system';
our $db_password = 'manager';
our $env_nls_lang = 'AMERICAN_AMERICA.WE8ISO8859P9';
our $env_oracle_home = '/opt/oracle/product/8.1.7';
our $env_oracle_bin = '/opt/oracle/product/8.1.7/bin';
#### end of the default values
################################################################################
## override defaults if there is a corresponfing conf file
my $module_conf_file = "$SisIYA_Config::systems_conf_dir/".`basename $0`;
chomp($module_conf_file);
if(-f $module_conf_file) {
	require $module_conf_file;
}
################################################################################
my $message_str = '';
my $data_str = '';
my $statusid = $SisIYA_Config::statusids{'ok'};
my $service_name = 'oracle_hitratios';
my $error_str = '';
my $ok_str = '';
my $warning_str = '';

### set environment variables
$ENV{'ORACLE_HOME'} = $env_oracle_home;
$ENV{'PATH'} = $env_oracle_bin.':'.$ENV{'PATH'};
$ENV{'NLS_LANG'} = $env_nls_lang;

### bufer cache hit ratio
my $sql_file = $SisIYA_Config::misc_dir.'/sisiya_oracle_hitratios_buffercache.sql';
my $x;
chomp($x= `$sqlplus_prog -S $db_user/$db_password\@$db_name \@$sql_file`);
$x = trim($x); 
#print STDERR "x=$x\n";
my $s = sprintf("%.2f", $x);
if($x <= $hitratios{'buffer_cache'}{'error'}) {
	$error_str = "ERROR: Buffer cache hit ratio is $s\% <= $hitratios{'buffer_cache'}{'error'}\%!";
}
elsif($x <= $hitratios{'buffer_cache'}{'warning'}) {
	$warning_str = "WARNING: Buffer cache hit ratio is $s\% <= $hitratios{'buffer_cache'}{'warning'}\%!";
}
else {
	$ok_str = "OK: Buffer cache hit ratio is $s\%.";
}

### dictionary hit ratio
$sql_file = $SisIYA_Config::misc_dir.'/sisiya_oracle_hitratios_dictionary.sql';
chomp($x= `$sqlplus_prog -S $db_user/$db_password\@$db_name \@$sql_file`);
$x = trim($x); 
#print STDERR "x=$x\n";
$s = sprintf("%.2f", $x);
if($x <= $hitratios{'dictionary'}{'error'}) {
	$error_str .= " ERROR: Dictionary cache hit ratio is $s\% <= $hitratios{'dictionary'}{'error'}\%!";
}
elsif($x <= $hitratios{'dictionary'}{'warning'}) {
	$warning_str .= " WARNING: Dictionary cache hit ratio is $s\% <= $hitratios{'dictionary'}{'warning'}\%!";
}
else {
	$ok_str .= " OK: Dictionary cache hit ratio is $s\%.";
}

### library cache hit ratio
$sql_file = $SisIYA_Config::misc_dir.'/sisiya_oracle_hitratios_library.sql';
chomp($x= `$sqlplus_prog -S $db_user/$db_password\@$db_name \@$sql_file`);
$x = trim($x); 
#print STDERR "x=$x\n";
$s = sprintf("%.2f", $x);
if($x <= $hitratios{'library'}{'error'}) {
	$error_str .= " ERROR: Library cache hit ratio is $s\% <= $hitratios{'library'}{'error'}\%!";
}
elsif($x <= $hitratios{'library'}{'warning'}) {
	$warning_str .= " WARNING: Library cache hit ratio is $s\% <= $hitratios{'library'}{'warning'}\%!";
}
else {
	$ok_str .= " OK: Library cache hit ratio is $s\%.";
}

### nowait cache hit ratio
$sql_file = $SisIYA_Config::misc_dir.'/sisiya_oracle_hitratios_nowait.sql';
chomp($x= `$sqlplus_prog -S $db_user/$db_password\@$db_name \@$sql_file`);
$x = trim($x); 
#print STDERR "x=$x\n";
$s = sprintf("%.2f", $x);
if($x <= $hitratios{'nowait'}{'error'}) {
	$error_str .= " ERROR: Nowait hit ratio is $s\% <= $hitratios{'nowait'}{'error'}\%!";
}
elsif($x <= $hitratios{'nowait'}{'warning'}) {
	$warning_str .= " WARNING: Nowait hit ratio is $s\% <= $hitratios{'nowait'}{'warning'}\%!";
}
else {
	$ok_str .= " OK: Nowait hit ratio is $s\%.";
}

### sort cache hit ratio
$sql_file = $SisIYA_Config::misc_dir.'/sisiya_oracle_hitratios_sort.sql';
chomp($x= `$sqlplus_prog -S $db_user/$db_password\@$db_name \@$sql_file`);
$x = trim($x); 
#print STDERR "x=$x\n";
$s = sprintf("%.2f", $x);
if($x <= $hitratios{'sort'}{'error'}) {
	$error_str .= " ERROR: Sort hit ratio is $s\% <= $hitratios{'sort'}{'error'}\%!";
}
elsif($x <= $hitratios{'sort'}{'warning'}) {
	$warning_str .= " WARNING: Sort hit ratio is $s\% <= $hitratios{'sort'}{'warning'}\%!";
}
else {
	$ok_str .= " OK: Sort hit ratio is $s\%.";
}

### total users
$sql_file = $SisIYA_Config::misc_dir.'/sisiya_oracle_hitratios_totalusers.sql';
chomp($x= `$sqlplus_prog -S $db_user/$db_password\@$db_name \@$sql_file`);
my $total_users = trim($x); 

### SGA size
$sql_file = $SisIYA_Config::misc_dir.'/sisiya_oracle_hitratios_sgasize.sql';
chomp($x= `$sqlplus_prog -S $db_user/$db_password\@$db_name \@$sql_file`);
my $sga_size = trim($x); 
$sga_size = get_size($sga_size);

if($error_str ne '') {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = "$error_str";
}
if($warning_str ne '') {
	if($statusid < $SisIYA_Config::statusids{'warning'}) {
		$statusid = $SisIYA_Config::statusids{'warning'};
	}	
	$message_str .= " $warning_str";
}
if($ok_str ne '') {
	$message_str .= " $ok_str";
}
$message_str .= " Number of active users is $total_users.  SGA size is $sga_size";
###################################################################################
print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
###################################################################################
