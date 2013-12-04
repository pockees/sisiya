set linesize 200
set heading off
set newpage none
set numwidth 16
set feedback off
select ((sum(gets)-sum(waits))/sum(gets))*100 from v$rollstat;
exit
