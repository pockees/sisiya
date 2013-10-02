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

### source the conf file
. $conf_file

exec_sql_prog=exec_${dbtype}.sh
if [ ! -x $exec_sql_prog ]; then
 echo "SQL script prog $exec_sql_prog does not exist!"
 exit 1
fi

tmp_file=tmp_$$.tmp
tmp_sql_file=tmp_sql_$$.tmp
html_dir=html
index_html_file=${html_dir}/index.html
shs_html_file=${html_dir}/shs.html
sss_html_file=${html_dir}/sss.html
for f in $index_html_file $shs_html_file $sss_html_file  
do
 rm -f $f
 touch $f
done
touch $tmp_file $tmp_sql_file

echo "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\">" >> $index_html_file
echo "<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=iso-8859-9\">" >> $index_html_file
echo "<meta NAME=\"GENERATOR\" CONTENT=\"generate_reports.sh\">"  >> $index_html_file 
echo "<title>System Monitoring Tool (by Erdal Mutlu)</title></head><body>" >> $index_html_file
echo "<center><h1><img src=\"images/SisIYA.gif\" alt=\"SisIYA's logo\"></img>System Status</h1><center>" >> $index_html_file


### For systemstatus table
sql_str="select c.hostname as Server,b.str as Status,a.str as Description,a.updatetime,a.changetime from systemstatus a,status b,systems c where a.statusid=b.id and a.systemid=c.id order by c.hostname;"
#echo "$sql_str" > $tmp_sql_file
#echo "Results of : $sql_str"
#$exec_sql_prog $tmp_sql_file $dbuser $dbname $conf_file > $tmp_file
echo "<center><h1>systemstatus</h1></center>" >> $index_html_file
mysql -H -u $dbuser -p$dbpassword $dbname -e "$sql_str" >> $index_html_file
#echo "-----------------------------------------------------------------"


### For systemservicestatus table
sql_str="select c.hostname as Server,d.str as Service,b.str as Status,a.str as Description,a.updatetime,a.changetime from systemservicestatus a,status b,systems c,services d where a.statusid=b.id and a.systemid=c.id and a.serviceid=d.id order by c.hostname,b.str;"
#echo "$sql_str" > $tmp_sql_file
#echo "Results of : $sql_str"
#$exec_sql_prog $tmp_sql_file $dbuser $dbname $conf_file > $tmp_file
echo "<center><h1>systemservicestatus</h1></center>" >> $index_html_file
mysql -H -u $dbuser -p$dbpassword $dbname -e "$sql_str" >> $index_html_file 
#echo "-----------------------------------------------------------------"

### For systemhistorystatus table
sql_str="select a.sendtime as SendTime,c.hostname as Server,d.str as Service,b.str as Status,a.str as Description,a.recievetime as RecieveTime from systemhistorystatus a,status b,systems c,services d where a.statusid=b.id and a.systemid=c.id and a.serviceid=d.id order by a.sendtime desc;"
#echo "$sql_str" > $tmp_sql_file
#echo "Results of : $sql_str"
#$exec_sql_prog $tmp_sql_file $dbuser $dbname $conf_file > $tmp_file
echo "<center><h1>systemhistorystatus</h1></center>" >> $index_html_file
mysql -H -u $dbuser -p$dbpassword $dbname -e "$sql_str" >> $index_html_file 
#echo "-----------------------------------------------------------------"
echo "</body></html>" >> $index_html_file
rm -f $tmp_file $tmp_sql_file
