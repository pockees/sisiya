set linesize 200
set heading off
set newpage none
set numwidth 16
set feedback off
select (1-(sum(decode(name,'physical reads',value,0))/(sum(decode(name,'db block gets',value,0))+sum(decode(name,'consistent gets',value,0)))))*100  from v$sysstat;
exit
