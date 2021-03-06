#!/usr/bin/perl -w
#
# Common functions
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
use Socket;

######################################################################################################
# An alternative to the Net:SMTP, but without timeout option. We can switch version if we implement it
# with timeout option.
######################################################################################################
sub get_snmp_value
{
	my ($options, $hostname, $version, $community, $mib, $username, $password) = @_;

	my $str = `$SisIYA_Remote_Config::external_progs{'snmpget'} $options -v $version -c $community $hostname $mib 2>&1`;
	my $retcode = $? >>=8;
	if ($retcode != 0) {
		return '';
	}
	chomp($str = $str);
	return "$str";
}

## generate a temporary file name in the $SisIYA_Remote_Config::tmp_dir directory
#sub get_temp_file_name 
#{
#	my $fh = File::Temp->new(TEMPLATE => 'tempXXXXX', DIR => $SisIYA_Remote_Config::tmp_dir, SUFFIX => '.tmp');
#
#	return $fh->filename;
#}

sub check_uptime
{
	my ($statusid_ref, $up_in_minutes, $uptime_warning, $uptime_error) = @_;
	my $s;

	if ($up_in_minutes <= $uptime_error) {
		$$statusid_ref = $SisIYA_Config::statusids{'error'};
		$s = "ERROR: The systems was restarted ".minutes2string($up_in_minutes). " (<= ".minutes2string($uptime_error).") ago!";
	} elsif ($up_in_minutes <= $uptime_warning) {
		$$statusid_ref = $SisIYA_Config::statusids{'warning'};
		$s = "WARNING: The systems was restarted ".minutes2string($up_in_minutes). " (<= ".minutes2string($uptime_warning).") ago!";
	} else {
		$$statusid_ref = $SisIYA_Config::statusids{'ok'};
		$s = "OK: The system is up for ".minutes2string($up_in_minutes). ".";
	}
	return $s;
}

sub check_snmp_system
{
	my ($expire, $hostname, $snmp_version, $community, $username, $password) = @_;
	my $serviceid = get_serviceid('system');
	my $statusid = $SisIYA_Config::statusids{'ok'};
	my $s = '';
	my $str = get_snmp_value('-OvQ', $hostname, $snmp_version, $community, 'system.sysDescr.0', $username, $password);
	if ($str eq '') {
		return '';
	}
	my ($system_description, $system_location);  
	if (grep(/No Such Object available/, $str)) {
		return '';
	} elsif (grep(/No more variables/, $str)) {
		return '';
	}
	chomp($system_description = $str);
	$str = `$SisIYA_Remote_Config::external_progs{'snmpget'} -OvQ -v $snmp_version $hostname -c $community system.sysLocation.0 2>&1`;
	$retcode = $? >>=8;
	if ($retcode == 0) {
		chomp($system_location = $str);
	}
	$str = `$SisIYA_Remote_Config::external_progs{'snmpget'} -OvQ -v $snmp_version $hostname -c $community system.sysUpTime.0 2>&1`;
	$retcode = $? >>=8;
	if ($retcode == 0) {
		my @a = split(/:/, $str);
		my $up_in_minutes = $a[0] * 1440  + $a[1] * 60 + $a[2];
		$s = check_uptime(\$statusid, $up_in_minutes, $uptimes{'warning'}, $uptimes{'error'});
	}
	$s = "$s Description: $system_description Location: $system_location.";
	return "<message><serviceid>$serviceid</serviceid><statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message>";
}

sub connect_to_socket_and_read_line
{
	my ($server, $port, $timeout, $proto_name) = @_;
	# create the socket, connect to the port
	if (socket(SOCKET, PF_INET, SOCK_STREAM, (getprotobyname($proto_name))[2]) == -1) {
		print STDERR "connect_to_socket_and_read_line: ERROR: Could not create socket of type $proto_name!";
		return '';
	}
	my $line;
	if (!connect( SOCKET, pack_sockaddr_in($port, inet_aton($server)))) {
		print STDERR "connect_to_socket_and_read_line: ERROR: Could not connect to $server:$port!";
		return '';
	} else {
		$line = <SOCKET>;
		close SOCKET;
		chomp($line = $line);
		$line =~ s/\r//g;
		#print STDERR "[$line]\n";
	}
	return $line;
}

sub get_http_protocol_description
{
	my %http_protocol_str = ( 
				200 => 'The request has succeeded.',
				201 => 'Created',
				202 => 'Accepted.',
				203 => 'Non-Authoritative Information.',
				204 => 'No content.',
				205 => 'Reset content.',
				206 => 'Partial content.',
				300 => 'Multiple choices.',
				301 => 'Moved permanently.',
				302 => 'Found.',
				303 => 'See other.',
				304 => 'Not modified.',
				305 => 'Use proxy.',
				306 => 'Unused.',
				307 => 'Temporary redirect.',
				400 => 'Client error: Bad request!',
				401 => 'Client error: Unauthorized!',
				402 => 'Client error: Payment required!',
				403 => 'Client error: Forbidden!',
				404 => 'Client error: Not found!',
				405 => 'Client error: Method not allowed!',
				406 => 'Client error: Not acceptable!',
				407 => 'Client error: Proxy authontication required!',
				408 => 'Client error: Request timeout!',
				409 => 'Client error: Conflict!',
				410 => 'Client error: Gone!',
				411 => 'Client error: Length is required!',
				412 => 'Client error: Precondicion failed!',
				413 => 'Client error: Request entity too large!',
				414 => 'Client error: Request URI too large!',
				415 => 'Client error: Unsupported media type!',
				416 => 'Client error: Requested range not satisfiable!',
				417 => 'Client error: Expectation failed!',
				500 => 'Internal server error!',
				501 => 'Server error: Not implemented!',
				502 => 'Server error: Bad gateway!',
				503 => 'Server error: Service unavailable!',
				504 => 'Server error: Gateway timeout!',
				505 => 'Server error: HTTP version not supported!'
			 );
	if ( exists($http_protocol_str{$_[0]})) {
		return "HTTP code $_[0]: $http_protocol_str{$_[0]}";
	}
	else {
		return 'Unknown HTTP status code: $_[0]';
	}
}

sub check_http_protocol
{
	my ($isactive, $serviceid, $expire, $system_name, $virtual_host, $index_file, $http_port, $username, $password, $ssl) = @_;

	if ($isactive eq 'f' ) {
		return '';
	}
	#print STDERR "check_http: Checking system_name=[$system_name] isactive=[$isactive] virtual_host=[$virtual_host] index_file=[$index_file] http_port=[$http_port] username=[$username] password=[$password]...\n";

	my $x_str = "<system><name>$system_name</name><message><serviceid>$serviceid</serviceid>";
	#############################################################
	#HTTP/1.1 200 OK
	#Date: Thu, 12 Dec 2013 07:24:06 GMT
	#Server: Apache
	#Last-Modified: Wed, 11 Sep 2013 14:27:45 GMT
	#ETag: "101513-ca7-4e61c6cc7b001"
	#Accept-Ranges: bytes
	#Content-Length: 3239
	#Connection: close
	#Content-Type: text/html; charset=UTF-8
	#############################################################
	my $params = '--max-time 4 --include';
	if (grep(/^HASH/, $username) == 0) {
	       $params = "$params --user \"$username:$password\"";
	}	       
	my @a;
       	if ($ssl == 1) {
		#print STDERR "$SisIYA_Remote_Config::external_progs{'curl'} $params https://$virtual_host:$http_port$index_file\n";
		#@a = `$SisIYA_Remote_Config::external_progs{'curl'} $params https://$virtual_host:$http_port$index_file 2>/dev/null`;
		$params .= ' --insecure';
		@a = `$SisIYA_Remote_Config::external_progs{'curl'} $params https://$virtual_host:$http_port$index_file 2>/dev/null`;
	}
	else {
		#print STDERR "$SisIYA_Remote_Config::external_progs{'curl'} $params http://$virtual_host:$http_port$index_file\n";
		@a = `$SisIYA_Remote_Config::external_progs{'curl'} $params http://$virtual_host:$http_port$index_file 2>/dev/null`;
	}
	my $s = '';
	my $statusid;
	my $retcode = $? >>=8;
	if ($retcode != 0) {
		$statusid = $SisIYA_Config::statusids{'error'};
		$s = "ERROR: The service is not running! retcode=$retcode";
	}
	else {
		my $info_str = '';
		my @b = grep(/^Server:/, @a);
		if ( $#b != -1 ) {
			$info_str = (split(/:/, $b[0]))[1];
			chomp($info_str = $info_str);
			$info_str =~ s/\r//g;
			$info_str = "INFO:$info_str";
			#print STDERR "info=[$info_str]\n";
		}
		my $http_status_code = (split(/\s+/, (grep(/^HTTP\//, @a))[0]))[1];
		#if (($http_status_code >= 200) && ($http_status_code < 300)) {
		if (($http_status_code >= 200) && ($http_status_code < 400)) {
			$statusid = $SisIYA_Config::statusids{'ok'};
			$s = "OK: ".get_http_protocol_description($http_status_code);
		}
		#elsif ( ($http_status_code >= 300) && ($http_status_code < 400)) {
		#	$statusid = $SisIYA_Config::statusids{'warning'};
		#	$s = "WARNING: The service is not running! ".get_http_protocol_description($http_status_code)." retcode=$retcode";
		#}
		else {
			#$statusid = $SisIYA_Config::statusids{'error'};
			#$s = "ERROR: The service has problem ! ".get_http_protocol_description($http_status_code)." retcode=$retcode";
			$statusid = $SisIYA_Config::statusids{'warning'};
			$s = "WARNING: The service has problems! ".get_http_protocol_description($http_status_code)." retcode=$retcode";
		}
		$s .= $info_str;
	}
	$x_str .= "<statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message></system>";
	return $x_str;
}

sub lock_check
{
	my ($check_name) = @_;

	my $script_name = $SisIYA_Remote_Config::checks{$check_name}{'script'};
	my $pid_file = "$SisIYA_Remote_Config::tmp_dir/".$script_name.".lock";
	my $ps_prog = $SisIYA_Remote_Config::external_progs{'ps'};

	return lock_using_pid_file($script_name, $pid_file, $ps_prog);
}

sub unlock_check
{
	my ($check_name) = @_;

	my $script_name = $SisIYA_Remote_Config::checks{$check_name}{'script'};
	my $pid_file = "$SisIYA_Remote_Config::tmp_dir/".$script_name.".lock";
	return unlock_using_pid_file($pid_file);
}

1;
