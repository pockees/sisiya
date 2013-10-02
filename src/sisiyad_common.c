/*
    Copyright (C) 2003  Erdal Mutlu

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#include"sisiyad1.h"
#include"sisiyad_common.h"

/* 
 write_pid : Writes the given PID the the specified file. 
 Returns TRUE on success or FALSE on error.
*/
int write_pid(char *file_name,pid_t pid)
{
 FILE *file_ptr;
 
 file_ptr=fopen(file_name,"w");  
 if(file_ptr == NULL) {
  syslog(LOG_ERR,"can't open PID file %s for writing!",file_name);
  return(FALSE);
 }
 if(fprintf(file_ptr,"%d",pid) < 0) {
  syslog(LOG_ERR,"error occured while writing the PID=%d to file %s !",pid,file_name);
  return(FALSE);
 } 
 if(fclose(file_ptr)) {
  syslog(LOG_ERR,"error occured while closing file %s !",file_name);
  return(FALSE);
 } 
 return(TRUE);
};

void sisiya_showconf(void)
{
 int i;

 for(i=0;i<NUMCONFIGS;i++) 
   if(strcmp(configs[i][0],"DB_PASSWORD") != 0)
     syslog(LOG_INFO,"Configuration option : %s=%s",configs[i][0],configs[i][1]);
    else
     syslog(LOG_INFO,"Configuration option for %s is not viewed!",configs[i][0]);
}
