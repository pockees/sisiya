#!/bin/bash
#
# This script check if there was an update for system within the
# specified interval of minutes. if there was not, then it sends a 
# message describing the error.
#
# Created by Erdal Mutlu
#
#################################################################################

###################################################################################
### fuctons
###################################################################################
time_difference()
{
 time_str=$1
 year=${time_str:0:4}
 month=${time_str:4:2}
 day=${time_str:6:2}
 hour=${time_str:8:2}
 min=${time_str:10:2}
 sec=${time_str:12:2}
 #echo "$day.$month.$year $hour:$min:$sec"
 ### for now
 time_str=`date '+%Y%m%d%H%M%S'`
 now_year=${time_str:0:4}
 now_month=${time_str:4:2}
 now_day=${time_str:6:2}
 now_hour=${time_str:8:2}
 now_min=${time_str:10:2}
 now_sec=${time_str:12:2}
# echo "difference=$2 now=$time_str"
# echo "$now_hour:$now_min:$now_sec $now_day.$now_month.$now_year"
# echo "$hour:$min:$sec $day.$month.$year"
 date_str="$year$month$day"
 now_date_str="$now_year$now_month$now_day"
 if [ $now_date_str != $date_str ]; then
  #echo "no response since for the past $2 minutes (date_str $now_date_str != $date_str)"
  echo 0
  return
 fi 
 ###time_str="$hour$min"
 ###now_time_str="$now_hour$now_min"
 
 time_str=`(echo "$hour * 60 + $min")|bc`
 now_time_str=`(echo "$now_hour * 60 +$now_min")|bc`

 result_time=`expr $now_time_str - $time_str`
# echo "result_time=$result_time"
 if [ $result_time -gt $2 ]; then
  #echo "no response since for the past $2 minutes (time_str $result_time > $2)"
  echo 0
  return
 fi 
 echo 1
}
###################################################################################
### End of functions
###################################################################################

if [ $# -ne 2 ]; then
 echo "Usage : $0 sisiya_client.conf interval_in_min"
 exit 1
fi


client_conf_file=$1
interval=$2

if [ ! -f $client_conf_file ]; then
 echo "$0 : sisiya client configuration file $client_conf_file does not exist!"
 exit 1
fi

### source the config file
. $client_conf_file
host=$sisiya_hostname
#################################################################################
### system service id
serviceid=$system_serviceid  
##########################################################################
sql_str="select a.hostname,b.statusid,b.updatetime from systems a, systemstatus b where a.id=b.systemid and a.active=1;"
mysql -u sisiyauser -psisiyauser1 -D sisiya -NBt -e "$sql_str" | grep -v "^+" | while read -r line
do
 #echo $line
 system=`echo $line | awk -F "|" '{print $2}'`
 status=`echo $line | awk -F "|" '{print $3}'`
 str=`echo $line | awk -F "|" '{print $4}'`
 #echo "system=$system status=$status str=$str"
 retcode=`time_difference $str $interval`
 #echo "retcode=$retcode"
 if [ $retcode -eq 1 ]; then
  message_str="There is a response within $interval"
  #echo "system=$system message_str=$message_str"
 else
  statusid=$status_error
  message_str="There is no response for the past $interval minutes"
  #echo "system=$system conf=$client_conf_file serviceid=$serviceid statusid=$statusid message_str=$message_str"
  ${send_message_prog} $system $client_conf_file $serviceid $statusid "$message_str"
 fi
done
