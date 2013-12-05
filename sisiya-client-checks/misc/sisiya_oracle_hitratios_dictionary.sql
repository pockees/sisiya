set linesize 200
set heading off
set newpage none
set numwidth 16
set feedback off
select (1-(sum(getmisses)/sum(gets)))*100 from v$rowcache;
exit
