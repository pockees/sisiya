set linesize 200
set heading off
set newpage none
set numwidth 16
set feedback off
select sum(value) from v$sga;
exit
