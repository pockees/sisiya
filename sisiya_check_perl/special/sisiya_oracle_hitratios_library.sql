set linesize 200
set heading off
set newpage none
set numwidth 16
set feedback off
select sum(Pins)/(sum(pins)+sum(Reloads))*100 from v$librarycache;
exit
