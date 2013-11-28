set linesize 2000
set colsep "|"
set heading off
set newpage none
set numwidth 16
set feedback off
select t$cjob,t$jsta,t$desc,to_char(t$edte,'DD.MM.YYYY HH:MI:SS'),to_char(t$ldat,'DD.MM.YYYY HH:MI:SS') from baan.tttaad500300;
exit
