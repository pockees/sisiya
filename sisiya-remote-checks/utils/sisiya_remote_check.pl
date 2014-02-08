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
use IO::Socket;
use SisIYA_Config;
use SisIYA_Remote_Config;
#use diagnostics;

if( ($#ARGV < 0) || ($#ARGV > 1) ) {
	print "Usage : $0 check_name expire\n";
	print "Usage : $0 expire\n";
	print "The expire parameter must be given in minutes.\n";
	print "When run only with one parameter eg expire then all remote checks which are enabled for auto run in the SisIYA_Remote_Config.pm\n";
       	print "(or overwritten in the SisIYA_Remote_Config_local.pl) are excecuted.\n";
	exit 1;
}

if(-f $SisIYA_Remote_Config::local_conf) {
	require $SisIYA_Remote_Config::local_conf;
}
#if(-f $SisIYA_Remote_Config::client_conf) {
#	require $SisIYA_Remote_Config::client_conf;
#}
if(-f $SisIYA_Remote_Config::client_local_conf) {
	require $SisIYA_Remote_Config::client_local_conf;
}
if(-f $SisIYA_Config::functions) {
	require $SisIYA_Config::functions;
}

# Parameter	: check name, expire
# Return	: xml message string
sub run_script
{
	my ($check_name, $expire) = @_;
	my $script_file = "$SisIYA_Remote_Config::scripts_dir/$SisIYA_Remote_Config::checks{$check_name}{'script'}";
	my $systems_file = "$SisIYA_Remote_Config::conf_d_dir/$SisIYA_Remote_Config::checks{$check_name}{'conf'}";
	my ($service_id, $s);

	#print STDERR "[$_[0]] ...\n";
	chomp($s = `$SisIYA_Remote_Config::external_progs{'perl'} -I$SisIYA_Remote_Config::conf_dir -I$SisIYA_Config::conf_dir $script_file $systems_file $expire`);
	#my $status_id = $? >> 8;
	#print STDERR "statusid = $status_id message=$s\n";
	return $s;	
}

# Parameter	: expire
# Return	: XML string
sub process_checks
{
	my $expire  = $_[0];
	my ($status_id, $service_id);
	my $s = '';

	foreach my $check_name (keys %SisIYA_Remote_Config::checks) {	
		if( $SisIYA_Remote_Config::checks{$check_name}{'auto'} == 1 ) {
			#print STDERR "Checking $check_name ...\n";
			# excecute $0 in background
			system("$SisIYA_Remote_Config::external_progs{'bash'} -c \"$SisIYA_Remote_Config::external_progs{'perl'} -I$SisIYA_Config::conf_dir -I$SisIYA_Remote_Config::conf_dir $0  $check_name $expire\" &");
		} #else {
		#	print STDERR "Skipping $check_name ...\n";
		#}
	}
	return $s;
}

# record the start time
my $date_str = get_timestamp();
my $xml_s_str = '';

if($#ARGV == 1) {
	$xml_s_str = run_script($ARGV[0], $ARGV[1]);
}
else {
	$xml_s_str  = process_checks($ARGV[0]);
}

if ($#ARGV == 0) {
	exit 0;
}

if($xml_s_str eq '') {
	#print STDERR "There is no SisIYA message to be send!\n";
	exit 1;
}

my $xml_str = '<?xml version="1.0" encoding="utf-8"?>';
$xml_str .= '<sisiya_messages><timestamp>'.$date_str.'</timestamp>';
$xml_str .= $xml_s_str;
$xml_str .= '</sisiya_messages>';

#print STDERR $xml_str;

send_message_data($xml_str);

exit 0;
