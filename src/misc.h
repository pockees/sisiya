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

#ifndef _misc_header_
#define _misc_header_

#if HAVE_CONFIG_H
  #include"config.h"
#endif

#include<stdio.h>

#if HAVE_UNISTD_H
 #ifdef DARWIN
  #include<sys/unistd.h>
 #else
  #include<unistd.h>
 #endif
#endif


int readn(int fd,char *ptr,int nbytes);
int writen(int fd,char *ptr,int nbytes);
int readline(int fd,char *ptr,int maxlen);
#endif
