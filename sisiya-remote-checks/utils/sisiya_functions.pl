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
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
#######################################################################################

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
	my $isactive 		= $_[0];
	if ($isactive eq 'f' ) {
		return '';
	}
	my $serviceid 		= $_[1];
	my $expire 		= $_[2];
	my $ssl 		= $_[3];
	my $system_name 	= $_[4];
	my $virtual_host	= $_[5];
	my $index_file		= $_[6];
	my $http_port		= $_[7];
	my $username 		= $_[8];
	my $password		= $_[9];
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
		print STDERR "$SisIYA_Remote_Config::external_progs{'curl'} $params https://$virtual_host:$http_port$index_file\n";
		@a = `$SisIYA_Remote_Config::external_progs{'curl'} $params https://$virtual_host:$http_port$index_file 2>/dev/null`;
	}
	else {
		print STDERR "$SisIYA_Remote_Config::external_progs{'curl'} $params http://$virtual_host:$http_port$index_file\n";
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
		if ( grep(/^Server/, @a) != 0 ) {
			$info_str = (grep(/^Server/, @a))[0];
			#print "info=[$info_str]\n";
			$info_str = (split(/:/, (grep(/^Server/, @a))[0]))[1];
			#print "info=[$info_str]\n";
		}
		if ($info_str ne '') {
			$info_str = "INFO: $info_str";
			chomp($info_str = $info_str);
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
	}
	$x_str .= "<statusid>$statusid</statusid><expire>$expire</expire><data><msg>$s</msg><datamsg></datamsg></data></message></system>";
	return $x_str;
}

1;
