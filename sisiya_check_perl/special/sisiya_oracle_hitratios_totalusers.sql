set linesize 200
set heading off
set newpage none
set numwidth 16
SET FEEDBACK OFF
select count(*) from v$session where username is not null;
exit
