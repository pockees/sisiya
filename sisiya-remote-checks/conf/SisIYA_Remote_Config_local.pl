##!/usr/bin/perl -w
#
#
## This file is the local config for SisIYA remote check programs.
##
##    Copyright (C) Erdal Mutlu
##
##    This program is free software; you can redistribute it and/or modify
##    it under the terms of the GNU General Public License as published by
##    the Free Software Foundation; either version 2 of the License, or
##    (at your option) any later version.
##
##    This program is distributed in the hope that it will be useful,
##    but WITHOUT ANY WARRANTY; without even the implied warranty of
##    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
##    GNU General Public License for more details.
##
##    You should have received a copy of the GNU General Public License
##    along with this program; if not, write to the Free Software
##    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
##
##
##################################################################################
package SisIYA_Remote_Config;

# In order to disable the automatic (via cron) running of a specific script uncomment
# the corresponding line. All scripts are set to be run automaticaly in the SisIYA_Remote_Config.pm
#$checks{'dns'}{'auto'}		= 0;
#$checks{'http'}{'auto'}	= 0;
#$checks{'hpilo2'}{'auto'}	= 0;
#$checks{'https'}{'auto'}	= 0;
#$checks{'imap'}{'auto'}	= 0;
#$checks{'ping'}{'auto'}	= 0;
#$checks{'pop3'}{'auto'}	= 0;
#$checks{'printer'}{'auto'}	= 0;
#$checks{'qnap'}{'auto'}	= 0;
#$checks{'sensor'}{'auto'}	= 0;
#$checks{'smb'}{'auto'}		= 0;
#$checks{'smtp'}{'auto'}	= 0;
#$checks{'ssh'}{'auto'}		= 0;
#$checks{'switch'}{'auto'}	= 0;
#$checks{'telekutu'}{'auto'}	= 0;
#$checks{'telnet'}{'auto'}	= 0;
#$checks{'ups_cs121'}{'auto'}	= 0;
#$checks{'ups_netagent'}{'auto'} = 0;
#$checks{'ups'}{'auto'}i	= 0;
#$checks{'vmware'}{'auto'}	= 0;
1;
