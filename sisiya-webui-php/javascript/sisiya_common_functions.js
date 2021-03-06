/*
    Copyright (C) 2003 - __YEAR__  Erdal Mutlu

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
    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA

*/
/*
Creates a hidden input on the specified form. 
*/
function createHiddenInput(formID,input_name,input_value) {
	var form=document.getElementById(formID);
	var input = document.createElement('input');
	input.type = 'hidden';
	input.name = input_name;
	input.value = input_value;
	form.appendChild(input);
}

function timedRefresh(timeoutPeriod) {
	setTimeout("location.reload(true);",timeoutPeriod);
}
