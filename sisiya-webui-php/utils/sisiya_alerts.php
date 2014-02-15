<?php
/*
    Copyright (C) 2003 - __YEAR__ Erdal Mutlu

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

*/
#session_start();
error_reporting(E_ALL);

if (count($argv) != 2) {
	echo "Usage   : $argv[0] web_root_dir\n";
	echo "Example : $argv[0] /srv/http/sisiya-webui-php\n";
	exit(1);
}

if (! defined('STDIN')) {
	echo "This script should not be run from web!";
	exit(1);
}
global $rootDir,$progName;
$progName = $argv[0];
$rootDir = $argv[1];

include_once($rootDir.'/conf/sisiya_common_conf.php');
include_once($rootDir.'/conf/sisiya_gui_conf.php');
include_once($rootDir.'/XMPPHP/XMPP.php');

$xmpp_conn = null;
$connectedFlag = false;
# used in the Jabber class
$_SERVER = array(
	'SERVER_SOFTWARE'  => "Linux OS",
	'REMOTE_ADDR'  => "localhost"
);

### not ready!!!
function send_sms_xml($phone_number,$msg)
{
/*
<?xml version = "1.0" encoding="UTF-8"?>
<SendSms>
  <Version>1.0</Version>
  <Kullanici>test</Kullanici>
  <Sifre>test</Sifre>
  <Baslik>TEST</Baslik>
  <SmsList>
    <GsmList>
      <Gsm>5320000000</Gsm>
    </GsmList>
    <MesajList>
      <Mesaj>Deneme 1</Mesaj>
    </MesajList>
  </SmsList>
  <Tarih></Tarih>
  <Saat></Saat>
  <Gecerlilik></Gecerlilik>
</SendSms>
*/

# http://api.teknomart.com.tr/xmlpost/
# http://195.33.233.154/xmlpost/

	$SMS_SERVER = 'api.teknomart.com.tr';
	$SMS_USER = 'altintest';
	$SMS_PASSWORD = 'altin1234';
	$SMS_TITLE = 'MESAJSERVSI';
	
	$xml_str = '<?xml version="1.0" encoding="UTF-8"?>';
	$xml_str. = '<SendSms><Version>1.0</Version>';
	$xml_str. = '<Kullanici>'.$SMS_USER.'</Kullanici>';
	$xml_str. = '<Sifre>'.$SMS_PASSWORD.'</Sifre>';
	$xml_str. = '<Baslik>'.$SMS_TITLE.'</Baslik>';
	$xml_str. = '<SmsList><GsmList>';
	$xml_str. = '<Gsm>'.$phone_number.'</Gsm>';
	$xml_str. = '</GsmList><MesajList>';
	$xml_str. = '<Mesaj>'.$msg.'</Mesaj>';
	$xml_str. = '</MesajList></SmsList><Tarih></Tarih><Saat></Saat><Gecerlilik></Gecerlilik></SendSms>';
	$url  =  'http://'.$SMS_SERVER.'/xmlpost/';
    	echo $contents = file_get_contents($url);
}

function send_sms($phone_number,$msg)
{
#	http://195.33.233.154/direct/?cmd = sendsms&kullanici=altintest&sifre=altin1234&baslik=MESAJSERVSI&gsm=5320000000&mesaj=Test
	$SMS_SERVER = '195.33.233.154';
	$SMS_USER = 'altintest';
	$SMS_PASSWORD = 'altin1234';
	$SMS_TITLE = 'MESAJSERVSI';
	

	$params  =  array (
        	'cmd'		 => 'sendsms',
		'kullanici'	 => $SMS_USER,
		'sifre'		 => $SMS_PASSWORD,
		'baslik'	 => $SMS_TITLE,
		'gsm'		 => $phone_number,
		'mesaj'		 => $msg
        );
	$encoded_params  =  array();
	foreach (array_keys($params) as $key) {
		array_push($encoded_params,urlencode($key)." = ".urlencode($params[$key]));
        }
	$data = implode("&",$encoded_params);

	 #$url  =  "http://195.33.233.154/direct/?cmd=sendsms&kullanici=altintest&sifre=altin1234&baslik=MESAJSERVSI&gsm=5339538713&mesaj=".urlencode("SisIYA dan merhaba");
	 $url  =  'http://'.$SMS_SERVER.'/direct/?'.$data;
    	echo $contents = file_get_contents($url);
}

function send_jabber_message($jabberid,$msg)
{
	global $jabber_server,$jabber_port,$jabber_user,$jabber_password,$connectedFlag,$jabber;

	### use send_xmpp_message
	return(send_xmpp_message($jabberid,$msg));


#	echo "Sending message: ".$msg." to ".$jabberid."\n";


	### connect from the Jabber server
	if ($connectedFlag  == false) { 
		$jabber = new Jabber; 

		$jabber->server = $jabber_server;
		$jabber->port = $jabber_port; 
		$jabber->username = $jabber_user; 
		$jabber->password = $jabber_password;
		$jabber->resource = 'ClassJabberPHP';
		#$jabber->resource = NULL;
 
		#$jabber->enable_logging = TRUE; 
		#$jabber->log_filename = 'logfile.txt'; 
 
 
		#$jabber->CruiseControl(60); 
 
		if ($jabber->Connect()  == false) {
			echo "sisiya_alerts::send_jabber_message: Could not connect to Jabber server!";
			return;
		}
		$connectedFlag = true;
#	echo "sisiya_alerts::send_jabber_message: Connected to Jabber server."."\n";

		if ($jabber->SendAuth()  == false) {
			echo "sisiya_alerts::send_jabber_message: Could not authenticate to Jabber server!";
			return;
		}
		$jabber->SendPresence(NULL, NULL, "online"); 
	}
	if ($jabber->SendMessage($jabberid,"normal",NULL,array("body"  => $msg)) == true)
		return true;
	return false;
}

function send_xmpp_message($jabberid,$msg)
{
	global $jabber_server,$jabber_port,$jabber_user,$jabber_password,$connectedFlag,$xmpp_conn;


	if ($connectedFlag  == false) { 
		try {
			#Use XMPPHP_Log::LEVEL_VERBOSE to get more logging for error reports
			#If this doesn't work, are you running 64-bit PHP with < 5.2.6?
			#$conn  =  new XMPPHP_XMPP('talk.google.com', 5222, 'username', 'password', 'xmpphp', 'gmail.com', $printlog=false, $loglevel=XMPPHP_Log::LEVEL_INFO);
			$xmpp_conn  =  new XMPPHP_XMPP($jabber_server,$jabber_port,$jabber_user,$jabber_password, 'xmpphp', 'gmail.com', $printlog=false, $loglevel=XMPPHP_Log::LEVEL_INFO);
			$xmpp_conn->connect();
			$xmpp_conn->processUntil('session_start');
			$xmpp_conn->presence();
		} catch(XMPPHP_Exception $e) {
		echo "getMessage()";
		return false;
		}
		$connectedFlag = true;
	}
	else {
		$xmpp_conn->message($jabberid,$msg);
	}
	return true;
}

function format_datetime($s)
{
	return $s{8}.$s{9}.':'.$s{10}.$s{11}.':'.$s{12}.$s{13}.' '.$s{6}.$s{7}.'.'.$s{4}.$s{5}.'.'.$s{0}.$s{1}.$s{2}.$s{3};
}

function format_message_old($service_id,$msg)
{
#	echo "serviceid = ".$service_id."Formated:".$msg;
	if ($service_id  == 5014) {
		$a = split('[ ]',$msg);
		$str = "";
		foreach($a as $key =>$value) {
			$str. = $value."\n";
		}
		return $str;
	}
	else
		return $msg;
}

function alert_systems()
{
	global $db,$defaultLanguage;

	$nowTime = date('YmdHis');
#	$sql_str = "select b.name,b.surname,b.email,c.changetime,c.str,d.hostname,e.str,a.alerttime,a.expire,a.userid,a.systemid,a.alerttypeid,a.statusid,f.str,c.str,g.str from usersystemalert a,users b,systemstatus c,systems d,status e,userproperties f,systemtypes g where d.active='t' and a.userid=b.id and a.systemid=c.systemid and a.statusid=c.statusid and a.systemid=d.id and a.statusid=e.id and a.enabled='t' and a.userid=f.userid and d.systemtypeid=g.id order by a.userid";
	###		  0	  1	    2	      3		4	5	 6	7	    8	      9		10	  11
	$sql_str = "select b.name,b.surname,b.email,c.changetime,c.str,d.hostname,i.str,a.alerttime,a.expire,a.userid,a.systemid,a.alerttypeid";
	###		12	13	14 
	$sql_str. = ",a.statusid,f.str,c.str from usersystemalert a,users b,systemstatus c,systems d,status e,userproperties f,";
	$sql_str. = "interface i,strkeys s,languages l where d.active='t' and a.userid=b.id and a.systemid=c.systemid ";
	$sql_str. = "and a.statusid=c.statusid and a.systemid=d.id and a.statusid=e.id and a.enabled='t' and a.userid=f.userid and ";
	$sql_str. = "e.keystr=s.keystr and s.id=i.strkeyid and i.languageid=l.id and l.code='".$defaultLanguage."'";
	$sql_str. = " order by a.userid";
	$result = $db->query($sql_str);
	$row_count = $db->getRowCount($result);	
	for($i = 0;$i<$row_count;$i++) {
		$row = $db->fetchRow($result,$i);
		### check whether we should alert or not
		#echo 'changeTime = '.$row[]."\n";
		#echo 'alertTime  = '.$row[7]."\n";
		#echo 'changeTime - alertTime  =  '.($changeTime - $row[7])."\n";
		#echo 'nowTime  = '.$nowTime."\n";
		#echo 'expire = '.$row[8]."\n";
		#echo '(alertTime+row[8]*60) -nowTime  = '.(($row[7]+$row[8]*60)-$nowTime)."\n";
		$alert_type = $row[11];
		$user_property = $row[13];
#echo "alert_type = ".$alert_type."\n";
		if ($row[3] > $row[7] || ($row[8] > 0 && (($row[7]+$row[8]*60) < $nowTime))) {
			$updateFlag = false;
			switch($alert_type) {
				case 2 :
					mail($row[2],'SisIYA Alert: The status of '.$row[5].' is '.$row[6].'!','Message: '.$row[4].' Alert time: '.format_datetime($nowTime));
					$updateFlag = true;
					break;
			case 3 :
					$str = $row[5].':'.$row[4];
					send_sms($user_property,$str);
					$updateFlag = true;
					break;

				case 4 :
					if (send_jabber_message($user_property,'SisIYA Alert: The status of '.$row[5].' is '.$row[6].' ! Message: '.$row[4]. ' Alert time:'.format_datetime($nowTime))  == true)
						$updateFlag = true;
					break;
				default :
					continue;
					break;
			}
			if ($updateFlag  == true) {
				##update alerttime
				$sql_str = "update usersystemalert set alerttime='".$nowTime."' where userid=".$row[9].' and systemid='.$row[10].' and alerttypeid='.$row[11].' and statusid='.$row[12];
				$db->query($sql_str);
			}
		}
#		else {
#			echo 'alertTime +expire*60 =='.($row[7]+$row[8]*60);
#			echo 'There is not need to alert now. '.$row[5].' is '.$row[6].'!','Message: '.$row[4]."\n";
#		}
	}
}

function alert_systemservice()
{
	global $db,$defaultLanguage;

	$nowTime = date('YmdHis');
	#$sql_str = "select b.name,b.surname,b.email,c.changetime,c.str,d.hostname,e.str,a.alerttime,a.expire,a.userid,a.systemid,a.alerttypeid,a.statusid,f.str,a.serviceid,g.str from usersystemservicealert a,users b,systemservicestatus c,systems d,status e,services f,userproperties g where d.active='t' and a.userid=b.id and a.systemid=c.systemid and a.serviceid=c.serviceid and a.statusid=c.statusid and a.systemid=d.id and a.statusid=e.id and a.serviceid=f.id and a.enabled='t' and a.userid=g.userid order by a.userid";
	###		  0	  1	    2	      3		4	5	 6	7	    8	      9		10	  11
	$sql_str = "select b.name,b.surname,b.email,c.changetime,c.str,d.hostname,i.str,a.alerttime,a.expire,a.userid,a.systemid,a.alerttypeid";
	###		12	13	14   	  15
	$sql_str. = ",a.statusid,i2.str,a.serviceid,g.str from usersystemservicealert a,users b,systemservicestatus c,systems d,status e,";
	$sql_str. = "services f,userproperties g,interface i,strkeys s,languages l,interface i2,strkeys s2,languages l2";
	$sql_str. = " where d.active='t' and a.userid=b.id and a.systemid=c.systemid and a.serviceid=c.serviceid and a.statusid=c.statusid";
	$sql_str. = " and a.systemid=d.id and a.statusid=e.id and a.serviceid=f.id and a.enabled='t' and a.userid=g.userid";
	$sql_str. = " and a.userid=g.userid";
	$sql_str. = " and e.keystr=s.keystr and s.id=i.strkeyid and i.languageid=l.id and l.code='".$defaultLanguage."'";
	$sql_str. = " and f.keystr=s2.keystr and s2.id=i2.strkeyid and i2.languageid=l2.id and l2.id=l.id";
	$sql_str. = " order by a.userid";

	$result = $db->query($sql_str);
	$row_count = $db->getRowCount($result);	
	for($i = 0;$i<$row_count;$i++) {
		$row = $db->fetchRow($result,$i);
		### check whether we should alert or not
		#echo 'changeTime = '.$changeTime."\n";
		#echo 'alertTime  = '.$alertTime."\n";
		#echo 'changeTime - alertTime  =  '.($changeTime - $alertTime)."\n";
		#echo 'nowTime  = '.$nowTime."\n";
		#echo 'expire = '.$expire."\n";
		#echo '(alertTime+expire*60) -nowTime  = '.(($alertTime+$expire*60)-$nowTime)."\n";
		$alert_type = $row[11];
		$user_property = $row[15];
#echo "alert_type = ".$alert_type."\n";
		if ($row[3] > $row[7] || ($row[8] > 0 && (($row[7]+$row[8]*60) < $nowTime))) {
			#echo 'Sending alert..'."\n";
			$updateFlag = false;
			switch($alert_type) {
				case 2 :
					mail($row[2],'SisIYA Alert: The status of '.$row[13].' for '.$row[5].' is '.$row[6].'!','Message: '.format_message($row[14],$row[4]).' Alert time: '.format_datetime($nowTime));
					$updateFlag = true;
					break;
				case 3 :
					#$str = 'Message: '.format_message($row[14],$row[4]).' Alert time: '.format_datetime($nowTime);
					#$str = 'Message: '.$row[
					$str = $row[5].':'.$row[4];
					send_sms($user_property,$str);
					$updateFlag = true;
					break;
				case 4 :
					if (send_jabber_message($user_property,'SisIYA Alert: The status of '.$row[13].' for '.$row[5].' is '.$row[6].'!','Message: '.format_message($row[14],$row[4]).' Alert time: '.format_datetime($nowTime))  == true)
						$updateFlag = true;
					break;
				default :
					continue;
					break;
			}
			if ($updateFlag  == true) {
				##update alerttime
				$sql_str = 'update usersystemservicealert set alerttime=\''.$nowTime.'\' where userid='.$row[9].' and systemid='.$row[10].' and alerttypeid='.$row[11].' and serviceid='.$row[14].' and statusid='.$row[12];
				$db->query($sql_str);
			}
		}
#		else {
#	echo "user = ".$row[0]." formated:".format_message($row[14],$row[4]);
		#	echo 'There is not need to alert now. '.$row[5].' '.$row[13].' is '.$row[6].'!','Message: '.$row[4]."\n";
#		}
	}
}

date_default_timezone_set($defaultTimezone);

alert_systems();
alert_systemservice();

### disconnect from the Jabber server
if ($connectedFlag  == true) { 
	#sleep(1);
#	$jabber->Disconnect(); 
	$xmpp_conn->disconnect();
}
