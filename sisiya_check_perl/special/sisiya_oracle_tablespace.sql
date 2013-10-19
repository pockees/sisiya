set linesize 200
set heading off
set newpage none
set numwidth 16
set feedback off
select a.TABLESPACE_NAME, a.BYTES bytes_used, b.BYTES bytes_free, b.largest, round(((a.BYTES-b.BYTES)/a.BYTES)*100,2) percent_used from ( select TABLESPACE_NAME, sum(BYTES) BYTES from dba_data_files group by TABLESPACE_NAME) a, (select TABLESPACE_NAME, sum(BYTES) BYTES,max(BYTES) largest from dba_free_space group by TABLESPACE_NAME) b where  a.TABLESPACE_NAME=b.TABLESPACE_NAME order by ((a.BYTES-b.BYTES)/a.BYTES) desc;
exit 
