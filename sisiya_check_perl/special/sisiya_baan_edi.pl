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
our $baan_edi_db_prog = '';
##our $baan_edi_db_prog="$SisIYA_Config::sisiya_utils_dir/sisiya_baan_edi_oracle.pl"
######
# this program should print the row numbers of ecedi700, ecedi750 and ecedi751 Baan EDI
# tables for the corresponding company in the form of table_name,row_count each line.
# Example:
# ecedi751,17
# ecedi700,0
# ecedi750,6 
######
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
my $service_name = 'baan_edi';
my $error_str = '';
my $info_str = '';
my $ok_str = '';
my $warning_str = '';

if($baan_edi_db_prog eq '') {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = "ERROR: There is no defined Baan EDI db script!";
	sisiya_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str);
}

my %table_row_counts = ( 'ecedi700' => 0, 'ecedi750' => 0, 'ecedi751' => 0 ); 

#my @a = ( "ecedi700,19\n", "ecedi750,3\n", "ecedi751,8\n" );
my @a = `$baan_edi_db_prog`;
my $retcode = $? >>=8;
if($retcode != 0) {
	$statusid = $SisIYA_Config::statusids{'error'};
	$message_str = "ERROR: Error executing the $baan_edi_db_prog command! retcode=$retcode";
	sisiya_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str);
}
my $n;
my $table_name;
chomp(@a = @a);
foreach(@a) {
	$table_name = (split(/,/, $_))[0];
	$n = (split(/,/, $_))[1];
	$table_row_counts{$table_name} = $n;
}

$table_name = 'ecedi750';
$n = $table_row_counts{$table_name};
if($n > 0) {
	$error_str .= "ERROR: There are $n error messages in the EDI table $table_name!"; 
}
else {
	$ok_str .= "OK: There are no error messages in the EDI table $table_name."; 
}

$table_name = 'ecedi751';
$n = $table_row_counts{$table_name};
if($n > 0) {
	$warning_str .= " WARNING: There are $n messages saved to be received in the EDI table $table_name!"; 
}
else {
	$ok_str .= " OK: There are no messages saved to be received in the EDI table $table_name."; 
}

$table_name = 'ecedi700';
$n = $table_row_counts{$table_name};
if($n > 0) {
	$warning_str .= " WARNING: There are $n messages to be generated in the EDI table $table_name!"; 
}
else {
	$ok_str .= " OK: There are no messages to be generated in the EDI table $table_name."; 
}

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
if($info_str ne '') {
	$message_str .= " $info_str";
}
################################################################################
#print "listening_socket$SisIYA_Config::FS<msg>$message_str</msg><datamsg></datamsg>\n";
#exit $statusid;
sisiya_exit($SisIYA_Config::FS, $service_name, $statusid, $message_str);
################################################################################
