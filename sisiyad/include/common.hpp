/*
    Copyright (C) 2005  Erdal Mutlu

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

/*
In order for a C++ program to use a library compiled with a C compiler, it is necessary
for any symbols exported from the C library to be declared between `extern "C" {' and `}'.
This code is important, because a C++ compiler mangles(7) all variable and function names,
where as a C compiler does not. On the other hand, a C compiler will not understand these
lines, so you must be careful to make them invisible to the C compiler.
*/

#ifdef __cplusplus
	#define BEGIN_C_DECLS extern "C" {
	#define END_C_DECLS   }
#else /* !__cplusplus */
	#define BEGIN_C_DECLS
	#define END_C_DECLS
#endif /* __cplusplus */
