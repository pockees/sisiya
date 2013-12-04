#!/bin/bash

###
# This script is used for generating HTML reports for the SMT system
# Created by Erdal Mutlu 05.12.2003
###

### funcions
echo_usage()
{
 echo "Usage : $0 db.conf"
}

str_to_time()
{
 time_str=$1
 year=${time_str:0:4}
 month=${time_str:4:2}
 day=${time_str:6:2}
 hour=${time_str:8:2}
 min=${time_str:10:2}
 sec=${time_str:12:2}
 #echo "$day.$month.$year $hour:$min:$sec"
 echo "$hour:$min:$sec $day.$month.$year"
}

### end of functions


if [ $# -ne 1 ]; then
 echo_usage
 exit 1
fi

conf_file=$1

if [ ! -f $conf_file ]; then
 echo "Database configuration file $conf_file does not exist!"
 exit 1
fi

. $conf_file

exec_sql_prog=exec_${dbtype}.sh
if [ ! -x $exec_sql_prog ]; then
 echo "SQL script prog $exec_sql_prog does not exist!"
 exit 1
fi

tmp_file=tmp_$$.tmp
tmp_sql_file=tmp_sql_$$.tmp
html_dir=html
all_html_file=${html_dir}/all.html
index_html_file=${html_dir}/index.html
shs_html_file=${html_dir}/shs.html
sss_html_file=${html_dir}/sss.html
for f in $all_html_file $index_html_file $shs_html_file $sss_html_file  
do
 rm -f $f
 touch $f
done
touch $tmp_file $tmp_sql_file

echo "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">" >> $all_html_file
echo "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-9\">" >> $all_html_file
echo "<meta NAME=\"GENERATOR\" CONTENT=\"generate_reports.sh\">"  >> $all_html_file 
echo "<title>System Monitoring Tool (by Erdal Mutlu)</title></head><body>" >> $all_html_file
echo "<img src=\"images/company_logo.gif\" alt=\"Company's logo\"></img>" >> $all_html_file
echo "<center><h1>SMT</h1><center>" >> $all_html_file
echo "<center><a href=\"sss.html\">Server - Service Status (All systems)</a>&nbsp;&nbsp;<a href=\"shs.html\">Server - History Status (All systems)</a></center>" >> $all_html_file


echo "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">" >> $index_html_file
echo "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-9\">" >> $index_html_file
echo "<meta NAME=\"GENERATOR\" CONTENT=\"generate_reports.sh\">"  >> $index_html_file 
echo "<title>System Monitoring Tool (by Erdal Mutlu)</title></head><body>" >> $index_html_file
echo "<img src=\"images/company_logo.gif\" alt=\"Company's logo\"></img>" >> $index_html_file
echo "<center><h1>SMT</h1><center>" >> $index_html_file
echo "<center><a href=\"sss.html\">Server - Service Status (All systems)</a>&nbsp;&nbsp;<a href=\"shs.html\">Server - History Status (All systems)</a></center>" >> $index_html_file

### For systemstatus table
echo -n "Generating [Server Status] ..."
#
sql_str="select c.hostname as Server,b.str as Status,a.str as Description,a.updatetime,a.changetime from systemstatus a,status b,systems c where a.statusid=b.id and a.systemid=c.id order by c.hostname;"
echo "$sql_str" > $tmp_sql_file
#echo "Results of : $sql_str"
#$exec_sql_prog $tmp_sql_file $dbuser $dbname $conf_file > $tmp_file
echo "<center><h1>System Status</h1></center>" >> $index_html_file
#mysql -H -u $dbuser -p$dbpassword $dbname -e "$sql_str" >> $index_html_file
#echo "-----------------------------------------------------------------"
######
echo "<center><table border=1>" >> $all_html_file 
echo "<tr><th>Server</th><th>Status</th><th>Description</th><th>Update Time</th><th>Change Time</th></tr>" >> $all_html_file 

echo "<center><table border=1>" >> $index_html_file 
echo "<tr><th>Server</th><th>Status</th><th>Description</th><th>Update Time</th><th>Change Time</th></tr>" >> $index_html_file 
mysql -u $dbuser -p$dbpassword -D $dbname -NBt < $tmp_sql_file | grep -v "^+" | while read -r line
do
# echo $line
 system=`echo $line | awk -F "|" '{print $2}'`
 system=`echo $system | awk '{print $1}'`
 status=`echo $line | awk -F "|" '{print $3}'`
 status=`echo $status | awk '{print $1}'`
 message=`echo $line | awk -F "|" '{print $4}'`
 str=`echo $line | awk -F "|" '{print $5}'`
 updatetime=`str_to_time $str`
 str=`echo $line | awk -F "|" '{print $6}'`
 changetime=`str_to_time $str`
 echo "<tr><td><a href=\"${system}_sss.html\">$system</a></td><td><img src=\"images/${status}.gif\">$status</img></td><td>$message</td><td>$updatetime</td><td>$changetime</td></tr>" >> $all_html_file 
 echo "<tr><td><a href=\"${system}_sss.html\">$system</a></td><td><img src=\"images/${status}.gif\">$status</img></td><td>$message</td><td>$updatetime</td><td>$changetime</td></tr>" >> $index_html_file 
done
echo "</table></center>" >> $all_html_file 
echo "</table></center>" >> $index_html_file 
echo "<br><center><h1>System Monitoring Tool (SMT) &copy; Erdal Mutlu</h1><center>" >> $index_html_file
echo "</body></html>"    >> $index_html_file
echo "OK"
######

### For systemservicestatus table
echo -n "Generating [Server Service Status] ..."
#
echo "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">" >> $sss_html_file
echo "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-9\">" >> $sss_html_file
echo "<meta NAME=\"GENERATOR\" CONTENT=\"generate_reports.sh\">"  >> $sss_html_file 
echo "<title>System Monitoring Tool (by Erdal Mutlu)</title></head><body>" >> $sss_html_file
echo "<center><h1><img src=\"images/company_logo.gif\" alt=\"Company's logo\"></img>SMT</h1><center>" >> $sss_html_file
echo "<center><a href=\"index.html\">Server Status</a>&nbsp;&nbsp;<a href=\"shs.html\">Server - History Status (All systems)</a></center>" >> $sss_html_file


sql_str="select c.hostname as Server,d.str as Service,b.str as Status,a.str as Description,a.updatetime,a.changetime, d.id from systemservicestatus a,status b,systems c,services d where a.statusid=b.id and a.systemid=c.id and a.serviceid=d.id order by c.hostname,d.str;"
echo "$sql_str" > $tmp_sql_file
#echo "Results of : $sql_str"
#$exec_sql_prog $tmp_sql_file $dbuser $dbname $conf_file > $tmp_file
echo "<center><h1>systemservicestatus</h1></center>" >> $sss_html_file
echo "<center><h1>systemservicestatus</h1></center>" >> $all_html_file
#mysql -H -u $dbuser -p$dbpassword $dbname -e "$sql_str" >> $index_html_file 
#echo "-----------------------------------------------------------------"
#######
echo "<center><table border=1>" >> $sss_html_file 
echo "<center><table border=1>" >> $all_html_file 
echo "<tr><th>Server</th><th>Service</th><th>Status</th><th>Description</th><th>Update Time</th><th>Change Time</th></tr>" >> $sss_html_file 
echo "<tr><th>Server</th><th>Service</th><th>Status</th><th>Description</th><th>Update Time</th><th>Change Time</th></tr>" >> $all_html_file 
mysql -u $dbuser -p$dbpassword -D $dbname -NBt < $tmp_sql_file | grep -v "^+" | while read -r line
do
# echo $line
 system=`echo $line | awk -F "|" '{print $2}'`
 system=`echo $system | awk '{print $1}'`
 service=`echo $line | awk -F "|" '{print $3}'`
 status=`echo $line | awk -F "|" '{print $4}'`
 status=`echo $status | awk '{print $1}'`
 message=`echo $line | awk -F "|" '{print $5}'`
 str=`echo $line | awk -F "|" '{print $6}'`
 updatetime=`str_to_time $str`
 str=`echo $line | awk -F "|" '{print $7}'`
 changetime=`str_to_time $str`
 sid=`echo $line | awk -F "|" '{print $8}'`
 sid=`echo $sid | awk '{print $1}'`
 echo "<tr><td><a href=\"${system}_sss.html\">$system</a></td><td><a href=\"${system}_service_${sid}.html\">$service</a></td><td><img src=\"images/${status}.gif\">$status</img></td><td>$message</td><td>$updatetime</td><td>$changetime</td></tr>" >> $sss_html_file 
 echo "<tr><td><a href=\"${system}_sss.html\">$system</a></td><td><a href=\"${system}_service_${sid}.html\">$service</a></td><td><img src=\"images/${status}.gif\">$status</img></td><td>$message</td><td>$updatetime</td><td>$changetime</td></tr>" >> $all_html_file 
done
echo "</table></center>" >> $sss_html_file 
echo "</body></html>"    >> $sss_html_file
echo "</table></center>" >> $all_html_file 
echo "OK"
#######

#### For systemhistorystatus table
echo -n "Generating [Server History Status] ..."
#
echo "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">" >> $shs_html_file
echo "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-9\">" >> $shs_html_file
echo "<meta NAME=\"GENERATOR\" CONTENT=\"generate_reports.sh\">"  >> $shs_html_file 
echo "<title>System Monitoring Tool (by Erdal Mutlu)</title></head><body>" >> $shs_html_file
echo "<center><h1><img src=\"images/company_logo.gif\" alt=\"Company's logo\"></img>SMT</h1><center>" >> $shs_html_file
echo "<center><a href=\"index.html\">Server Status</a>&nbsp;&nbsp;<a href=\"sss.html\">Server - Service Status (All systems)</a></center>" >> $shs_html_file



sql_str="select a.sendtime as SendTime,c.hostname as Server,d.str as Service,b.str as Status,a.str as Description,a.recievetime as RecieveTime,d.id from systemhistorystatus a,status b,systems c,services d where a.statusid=b.id and a.systemid=c.id and a.serviceid=d.id order by a.sendtime desc;"
echo "$sql_str" > $tmp_sql_file
##echo "Results of : $sql_str"
##$exec_sql_prog $tmp_sql_file $dbuser $dbname $conf_file > $tmp_file
echo "<center><h1>systemhistorystatus</h1></center>" >> $all_html_file
echo "<center><h1>systemhistorystatus</h1></center>" >> $shs_html_file
#mysql -H -u $dbuser -p$dbpassword $dbname -e "$sql_str" >> $index_html_file 
#echo "-----------------------------------------------------------------"

######
echo "<center><table border=1>" >> $all_html_file 
echo "<center><table border=1>" >> $shs_html_file 
echo "<tr><th>Send Time</th><th>Server</th><th>Service</th><th>Status</th><th>Description</th><th>Recieve Time</th></tr>" >> $all_html_file 
echo "<tr><th>Send Time</th><th>Server</th><th>Service</th><th>Status</th><th>Description</th><th>Recieve Time</th></tr>" >> $shs_html_file 
mysql -u $dbuser -p$dbpassword -D $dbname -NBt < $tmp_sql_file | grep -v "^+" | while read -r line
do
# echo $line
 str=`echo $line | awk -F "|" '{print $2}'`
 sendtime=`str_to_time $str`
 system=`echo $line | awk -F "|" '{print $3}'`
 system=`echo $system | awk '{print $1}'`
 service=`echo $line | awk -F "|" '{print $4}'`
 status=`echo $line | awk -F "|" '{print $5}'`
 status=`echo $status | awk '{print $1}'`
 message=`echo $line | awk -F "|" '{print $6}'`
 str=`echo $line | awk -F "|" '{print $7}'`
 recievetime=`str_to_time $str`
 sid=`echo $line | awk -F "|" '{print $8}'`
 sid=`echo $sid | awk '{print $1}'`
 echo "<tr><td>$sendtime</td><td><a href=\"${system}_sss.html\">$system</a></td><a href=\"${system}_service_${sid}.html\">$service</a><td><img src=\"images/${status}.gif\">$status</img></td><td>$message</td><td>$recievetime</td></tr>" >> $all_html_file 
 echo "<tr><td>$sendtime</td><td><a href=\"${system}_sss.html\">$system</a></td><a href=\"${system}_service_${sid}.html\">$service</a><td><img src=\"images/${status}.gif\">$status</img></td><td>$message</td><td>$recievetime</td></tr>" >> $shs_html_file 
done
echo "</table></center>" >> $all_html_file 
echo "</table></center>" >> $shs_html_file 
echo "</body></html>"    >> $shs_html_file
echo "OK"
#####
echo "</body></html>" >> $all_html_file


### Every host's systemservicestatus file
echo -n "Generating [Server Service Status for every host] ..."
#
sql_str="select c.hostname as Server,d.str as Service,b.str as Status,a.str as Description,a.updatetime,a.changetime,d.id from systemservicestatus a,status b,systems c,services d where a.statusid=b.id and a.systemid=c.id and a.serviceid=d.id order by c.id,d.str;"
echo "$sql_str" > $tmp_sql_file
##echo "Results of : $sql_str"
##$exec_sql_prog $tmp_sql_file $dbuser $dbname $conf_file > $tmp_file
old_system=""
mysql -u $dbuser -p$dbpassword -D $dbname -NBt < $tmp_sql_file | grep -v "^+" | while read -r line
do
# echo $line
 system=`echo $line | awk -F "|" '{print $2}'`
 system=`echo $system | awk '{print $1}'`
 service=`echo $line | awk -F "|" '{print $3}'`
 status=`echo $line | awk -F "|" '{print $4}'`
 status=`echo $status | awk '{print $1}'`
 message=`echo $line | awk -F "|" '{print $5}'`
 str=`echo $line | awk -F "|" '{print $6}'`
 updatetime=`str_to_time $str`
 str=`echo $line | awk -F "|" '{print $7}'`
 changetime=`str_to_time $str`
 sid=`echo $line | awk -F "|" '{print $8}'`
 sid=`echo $sid | awk '{print $1}'`
 if [ "${system}" != "${old_system}" ]; then
  ### this is for the first case when old_system is ""
  if [ -n "${old_system}" ]; then
   echo "</table></center>" >> $html_file
   echo "</body></html>"    >> $html_file
  fi 
  old_system=$system
  html_file=${html_dir}/${system}_sss.html 
  rm -f $html_file
  touch $html_file
  ### header
  echo "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">" >> $html_file
  echo "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-9\">" >> $html_file
  echo "<meta NAME=\"GENERATOR\" CONTENT=\"generate_reports.sh\">"  >> $html_file 
  echo "<title>System Monitoring Tool (by Erdal Mutlu)</title></head><body>" >> $html_file
  echo "<center><h1><img src=\"images/company_logo.gif\" alt=\"Company's logo\"></img>SMT</h1><center>" >> $html_file
  echo "<center><a href=\"index.html\">Server Status</a>&nbsp;&nbsp;<a href=\"sss.html\">Server - Service Status (All systems)</a></center><br>" >> $html_file
  if [ -f ${html_dir}/images/${system}.gif ]; then
   echo "<center><img src=\"images/${system}.gif\"><a href=\"${system}_shs.html\">Server Status History for [${system}]</a></center><br>" >> $html_file
  else
   echo "<center><a href=\"${system}_shs.html\">Server Status History for [${system}]</a></center><br>" >> $html_file
  fi
  echo "<center><table border=1>" >> $html_file 
  echo "<tr><th>Service</th><th>Status</th><th>Description</th><th>Update Time</th><th>Change Time</th></tr>" >> $html_file 
 fi 
 ### content
 echo "<tr><td><a href=\"${system}_service_${sid}.html\">$service</a></td><td><img src=\"images/${status}.gif\">$status</img></td><td>$message</td><td>$updatetime</td><td>$changetime</td></tr>" >> $html_file 
done
echo "OK"


### Every host's systemhistorystatus file
echo -n "Generating [Server History Status for every host] ..."
#
sql_str="select a.sendtime as SendTime,c.hostname as Server,d.str as Service,b.str as Status,a.str as Description,a.recievetime as RecieveTime,d.id from systemhistorystatus a,status b,systems c,services d where a.statusid=b.id and a.systemid=c.id and a.serviceid=d.id order by a.sendtime desc;"
echo "$sql_str" > $tmp_sql_file
##echo "Results of : $sql_str"
##$exec_sql_prog $tmp_sql_file $dbuser $dbname $conf_file > $tmp_file
old_system=""
mysql -u $dbuser -p$dbpassword -D $dbname -NBt < $tmp_sql_file | grep -v "^+" | while read -r line
do
# echo $line
 str=`echo $line | awk -F "|" '{print $2}'`
 sendtime=`str_to_time $str`
 system=`echo $line | awk -F "|" '{print $3}'`
 system=`echo $system | awk '{print $1}'`
 service=`echo $line | awk -F "|" '{print $4}'`
 status=`echo $line | awk -F "|" '{print $5}'`
 status=`echo $status | awk '{print $1}'`
 message=`echo $line | awk -F "|" '{print $6}'`
 str=`echo $line | awk -F "|" '{print $7}'`
 sid=`echo $line | awk -F "|" '{print $8}'`
 sid=`echo $sid | awk '{print $1}'`
 recievetime=`str_to_time $str`
 if [ "${system}" != "${old_system}" ]; then
  ### this is for the first case when old_system is ""
  if [ -n "${old_system}" ]; then
   echo "</table></center>" >> $html_file
   echo "</body></html>"    >> $html_file
  fi 
  old_system=$system
  html_file=${html_dir}/${system}_shs.html 
  rm -f $html_file
  touch $html_file
  ### header
  echo "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">" >> $html_file
  echo "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-9\">" >> $html_file
  echo "<meta NAME=\"GENERATOR\" CONTENT=\"generate_reports.sh\">"  >> $html_file 
  echo "<title>System Monitoring Tool (by Erdal Mutlu)</title></head><body>" >> $html_file
  echo "<center><h1><img src=\"images/company_logo.gif\" alt=\"Company's logo\"></img>SMT</h1><center>" >> $html_file
  echo "<center><a href=\"index.html\">Server Status</a>&nbsp;&nbsp;<a href=\"sss.html\">Server - Service Status (All systems)</a></center><br>" >> $html_file
  if [ -f ${html_dir}/images/${system}.gif ]; then
   echo "<center><img src=\"images/${system}.gif\"><a href=\"${system}_sss.html\">Server - Service Status for [${system}]</a></center><br>" >> $html_file
  else
   echo "<center><a href=\"${system}_sss.html\">Server - Service Status for [${system}]</a></center><br>" >> $html_file
  fi
  echo "<center><table border=1>" >> $html_file 
  echo "<tr><th>Send Time</th><th>Service</th><th>Status</th><th>Description</th><th>Recieve Time</th></tr>" >> $html_file 

 fi 
 ### content
 echo "<tr><td>$sendtime</td><td><a href=\"${system}_service_${sid}.html\">$service</a></td><td><img src=\"images/${status}.gif\">$status</img></td><td>$message</td><td>$recievetime</td></tr>" >> $html_file 
done
echo "OK"

### Every host's systemhistorystatus file for a specific service 
echo -n "Generating [Server History Status for every host and service] ..."
#
sql_str="select a.sendtime as SendTime,c.hostname as Server,d.str as Service,b.str as Status,a.str as Description,a.recievetime as RecieveTime,d.id from systemhistorystatus a,status b,systems c,services d where a.statusid=b.id and a.systemid=c.id and a.serviceid=d.id order by c.id,d.id,a.sendtime desc;"
echo "$sql_str" > $tmp_sql_file
##echo "Results of : $sql_str"
##$exec_sql_prog $tmp_sql_file $dbuser $dbname $conf_file > $tmp_file
old_system=""
old_sid=""
mysql -u $dbuser -p$dbpassword -D $dbname -NBt < $tmp_sql_file | grep -v "^+" | while read -r line
do
# echo $line
 str=`echo $line | awk -F "|" '{print $2}'`
 sendtime=`str_to_time $str`
 system=`echo $line | awk -F "|" '{print $3}'`
 system=`echo $system | awk '{print $1}'`
 service=`echo $line | awk -F "|" '{print $4}'`
 status=`echo $line | awk -F "|" '{print $5}'`
 status=`echo $status | awk '{print $1}'`
 message=`echo $line | awk -F "|" '{print $6}'`
 str=`echo $line | awk -F "|" '{print $7}'`
 sid=`echo $line | awk -F "|" '{print $8}'`
 sid=`echo $sid | awk '{print $1}'`
 recievetime=`str_to_time $str`
 if [ "${system}" != "${old_system}" -o "${sid}" != "${old_sid}" ]; then
  if [ -n "${old_system}" ]; then
   echo "</table></center>" >> $html_file
   echo "</body></html>"    >> $html_file
  fi 
  if [ "${system}" != "${old_system}" ]; then
   old_system=$system
   old_sid=$sid
  fi 
  if [ "${sid}" != "${old_sid}" ]; then
   old_sid=$sid
  fi

  html_file=${html_dir}/${system}_service_${sid}.html 
  rm -f $html_file
  touch $html_file
  ### header
  echo "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">" >> $html_file
  echo "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-9\">" >> $html_file
  echo "<meta NAME=\"GENERATOR\" CONTENT=\"generate_reports.sh\">"  >> $html_file 
  echo "<title>System Monitoring Tool (by Erdal Mutlu)</title></head><body>" >> $html_file
  echo "<center><h1><img src=\"images/company_logo.gif\" alt=\"Company's logo\"></img>SMT</h1><center>" >> $html_file
  echo "<center><a href=\"index.html\">Server Status</a>&nbsp;&nbsp;<a href=\"sss.html\">Server - Service Status (All systems)</a></center><br>" >> $html_file
  echo "<center><a href=\"${system}_sss.html\">Server - Service Status for [${system}]</a></center><br>" >> $html_file
  echo "<center>Service : $service</center><br>" >> $html_file
  echo "<center><table border=1>" >> $html_file 
  echo "<tr><th>Send Time</th><th>Status</th><th>Description</th><th>Recieve Time</th></tr>" >> $html_file 
 fi 
 ### content
 echo "<tr><td>$sendtime</td><td><img src=\"images/${status}.gif\">$status</img></td><td>$message</td><td>$recievetime</td></tr>" >> $html_file 
done
echo "OK"
#
####
rm -f $tmp_file $tmp_sql_file
