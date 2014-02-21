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
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
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
### table_check_types are the valid options for the MySQL check table command : quick, fast, changed, medium, extended
### QUICK   : Do not scan the rows to check for incorrect links.
### FAST    : Check only tables that have not been closed properly.
### CHANGED : Check only tables that have been changed since the last check or that have not been closed properly.
### MEDIUM  : Scan rows to verify that deleted links are valid. This also calculates a key checksum for the rows 
###           and verifies this with a calculated checksum for the keys.
### EXTENDED : Do a full key lookup for all keys for each row. This ensures that the table is 100% consistent, but takes a long time.
#######################################################################################
#######################################################################################
#### the default values
our $dba_user = 'mysql';
our $dba_password = 'mysql123654';
our $dba_database = 'mysql';
our @dbs = ( { 'db_name' => 'mysql', 'description' => 'MySQL System DB', 'check_type' => 'extended' });
our @exception_tables = ( {'db' => 'mysql', 'table' => 'general_log'}, { 'db' => 'mysql', 'table' => 'slow_log'});
#
#### end of the default values
#######################################################################################
my $service_name = 'mysql_table_status';
## override defaults if there is a corresponding conf file
my $module_conf_file = "$SisIYA_Config::conf_d_dir/sisiya_$service_name.conf";
if (-f $module_conf_file) {
	require $module_conf_file;
}
#######################################################################################
sub is_exception
{
	my $db = $_[0];
	my $table = $_[1];
	for my $i (0..$#exception_tables) {
		if ( ($exception_tables[$i]{'db'} eq $db) && ($exception_tables[$i]{'table'} eq $table)) {
			return 1;
		}
	}
	return 0;
}

my $message_str = '';
my $data_str = '';
my $statusid = $SisIYA_Config::statusids{'ok'};
my $error_str = '';
my $info_str = '';
my $ok_str = '';
#my $warning_str = '';
#push @dbs , { 'db_name' => 'db1', 'description' => 'DB1', 'check_type' => 'quick' };
my @a;
my @b;
my $table_name;
my $status;
my $msg_type;
my $status_message;

my $i = 0;
if ($#dbs > -1) {
	if (! -f $SisIYA_Config::external_progs{'mysql'}) {
		$statusid = $SisIYA_Config::statusids{'error'};
		$message_str = "ERROR: External program $SisIYA_Config::external_progs{'mysql'} does not exist!";
		print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
	}
	# check the MySQL connection
	`$SisIYA_Config::external_progs{'mysql'} -u$dba_user -p$dba_password -D $dba_database -NBt -e "show tables"`;
	my $retcode = $? >>=8;
	if ($retcode != 0) {
		$statusid = $SisIYA_Config::statusids{'error'};
		$message_str = "ERROR: Error executing the mysql command! retcode=$retcode";
		print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
	}

	for $i (0..$#dbs) {
		#print STDERR "$dbs[$i]{'db_name'}...\n";
		@a = `$SisIYA_Config::external_progs{'mysql'} -u$dba_user -p$dba_password -D $dbs[$i]{'db_name'} -NBt -e "show tables"`;
		$retcode = $? >>=8;
		if ($retcode != 0) {
			$error_str .= " ERROR: Could not get table list for $dbs[$i]{'db_name'} $dbs[$i]{'description'}!";
		}
		else {
			@a = grep(/^\|/, @a);
			foreach (@a) {
				$table_name = trim((split(/\|/, $_))[1]);
				#print STDERR "---------------------------------\n";
				#print STDERR "Checking $dbs[$i]{'db_name'} $table_name ...\n";;
				@b = `$SisIYA_Config::external_progs{'mysql'} -u$dba_user -p$dba_password -D $dbs[$i]{'db_name'} -NBt -e "check table $table_name $dbs[$i]{'check_type'}"`;
				$retcode = $? >>=8;
				if ($retcode != 0) {
					$error_str .= " ERROR: Could not check table $dbs[$i]{'db_name'}:$table_name!";
				}
				else {
					foreach my $c (@b) {
						#	#print STDERR "c=$c\n";
						if (index($c, '|') != -1) {
							#print STDERR "c=$c\n";
							$msg_type = (split(/\|/, $c))[3];
							#print STDERR "msg_type=[$msg_type]\n";
							if (index($msg_type, 'status') != -1) {
								$status_message = (split(/\|/, $c))[4];
								#print STDERR "status_message=[$status_message]\n";
								if ( (index($status_message, 'OK') != -1) && ( index($status_message, 'Table is already up to date') != -1 ) ) {
									#print STDERR "error\n";
									$error_str .= " ERROR: $dbs[$i]{'db_name'}:$table_name message: $status_message! "; 
								}
							}
							else {
								$status_message = (split(/\|/, $c))[4];
								#print STDERR "2 msg_type=[$msg_type] status_message=[$status_message]\n";
								if (is_exception($dbs[$i]{'db_name'}, $table_name)) {
									$info_str .= " INFO: $dbs[$i]{'db_name'}:$table_name message: $status_message!"; 
								}
								else {
									$error_str .= " ERROR: $dbs[$i]{'db_name'}:$table_name message: $status_message!"; 
								}
							}
						}
					}
				}
			}
		}
	}
}
if ($error_str ne '') {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = "$error_str";
}
#if ($warning_str ne '') {
#	if ($statusid < $SisIYA_Config::statusids{'warning'}) {
#		$statusid = $SisIYA_Config::statusids{'warning'};
#	}	
#	$message_str .= "$warning_str";
#}
my $db_list = '';
for $i (0..$#dbs) {
	$db_list .= " $dbs[$i]{'db_name'}";
}
if ($statusid == $SisIYA_Config::statusids{'error'}) {
	$ok_str = " OK: The rest of the tables of the following databases have no problems:$db_list.";
}
else {
	$ok_str = " OK: All tabales of the following databases are okey:$db_list.";
}

if ($ok_str ne '') {
	$message_str .= "$ok_str";
}
if ($info_str ne '') {
	$message_str .= "$info_str";
}
###################################################################################
print_and_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str, $data_str);
###################################################################################
#mysql mysql -e "check table db extended"
#+----------+-------+----------+----------+
#| Table    | Op    | Msg_type | Msg_text |
#+----------+-------+----------+----------+
#| mysql.db | check | status   | OK       |
#+----------+-------+----------+----------+
