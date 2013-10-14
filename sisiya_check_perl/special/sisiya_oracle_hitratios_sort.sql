set linesize 200
set heading off
set newpage none
set numwidth 16
set feedback off
select round((100*b.value)/decode((a.value+b.value),0,1,(a.value+b.value)),2) from v$sysstat a, v$sysstat b where a.name='sorts (disk)' and b.name='sorts (memory)';
exit
