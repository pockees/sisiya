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

#ifdef HAVE_CONFIG_H
 #include"config.h"
#endif

#include"sisiya.h"
#include"sisiya_conf.h"
#include"inet.h"
#include"resolve.h"

#if HAVE_UNISTD_H
 #ifdef DARWIN
  #include<sys/unistd.h>
 #else
  #include<unistd.h>
 #endif
#endif


static void remove_spaces(char *line);
static int get_conf_option(char *line,char *option,char *value);
static void get_conf_option_key(char *line,char *key,char *value);

/***********************************************************************/
static void get_conf_option_key(char *line,char *key,char *value)
{
 int i=0,j=0;
 //fprintf(stderr,"line=[%s]",line); 
 while(line[i] != '\0' && line[i] != '=') {
  key[i]=line[i];
  i++;
 }
 if(i > 0 && line[i] == '=') {
  key[i]='\0';
// fprintf(stderr,"key=[%s]",key); 

  i++; /* advance 1 because of = character */
  while(line[i] != '\0') {
   value[j++]=line[i++];
  }
  value[j]='\0';
 //fprintf(stderr,"value=[%s]",value); 
 }
 else { /* there was no =. So there cann't be a key value*/
  key[0]='\0';
  value[0]='\0';
 }
};

/*
 get_conf_option: Gets the specified configuration option
*/
static int get_conf_option(char *line,char *option,char *value)
{
 /*int length;*/
 char tmp_option_str[MAX_STR],tmp_value_str[MAX_STR];

 /*length=strlen(line);*/
 get_conf_option_key(line,tmp_option_str,tmp_value_str);
 if(strcmp(tmp_option_str,option) == 0) {
     strcpy(value,tmp_value_str);
     return(TRUE);
 }
 return(FALSE);
};

static void remove_spaces(char *line)
{
 char str[MAX_STR];
 int i,j,length;

 length=strlen(line);
 if(length >= MAX_STR)
   return;
 if(line[length-1] == '\n')
   line[length-1]='\0';
 j=0;
 for(i=0;i<length;i++) {
  if(line[i] == ' ' || line[i] == '\t')
    continue;
  str[j]=line[i];
  j++; 
 }
 str[j]='\0';
 strcpy(line,str);
}

int read_conf(char *file_name)
{
 int i;
 char str[MAX_STR];
 char line[MAX_STR];/*,tmp_option_str[MAX_STR],tmp_value_str[MAX_STR];*/
 FILE *file_ptr;

 file_ptr=fopen(file_name,"r");
 if(file_ptr == NULL) {
  syslog(LOG_ERR,"can't open configuration file %s for reading!",file_name);
  return(FALSE);
 }
 while(!feof(file_ptr)) {
   fgets(line,MAX_STR-1,file_ptr);
   if(line[0] == '\n' ) 
     continue;
   remove_spaces(line);
   if(line[0] == '#') 
     continue;
   for(i=0;i<NUMCONFIGS;i++) {
     if(get_conf_option(line,configs[i][0],str) == TRUE) {
       if(i == 1 && strcmp(str,"any") != 0 && strcmp(str,"127.0.0.1") != 0 && strcmp(str,"localhost") != 0 
          && strcmp(str,"0.0.0.0") != 0)  
         get_ip(str,configs[i][1],MAX_STR);
       else
         strcpy(configs[i][1],str); 
     }
   }
 }
 fclose(file_ptr);
 return(TRUE);
}
