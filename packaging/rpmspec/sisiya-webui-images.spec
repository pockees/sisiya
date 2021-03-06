#    Copyright (C) Erdal Mutlu
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA


%if 0%{?rhel_version}
	%define www_user  apache
	%define www_group apache
%else
	%if 0%{?suse_version}
		%define www_user  wwwrun
		%define www_group www
	%else
		%define www_user  apache
		%define www_group apache
	%endif
%endif


Name: sisiya-webui-images
Summary: Image collection for SisIYA web user interface
%define install_dir /var/lib/%{name}
Url: http://www.sisiya.org
BuildArch: noarch
BuildRoot: %{_builddir}/%{name}-root
Version: __VERSION__
Release: 0
Source0: http://sourceforge.net/projects/sisiya/files/sisiya/%{version}/rpm/%{name}-%{version}.tar.gz
License: GPL-2.0+
Vendor: Erdal Mutlu
Group: System Environment/Tools
Packager: Erdal Mutlu <erdal@sisiya.org>
#Requires: 
%description 
Image collection for SisIYA web GUI. These images are used for assigning to systems. These are mostly images of various hardware.

%prep 
%setup -n %{name}-%{version}

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}
make "DESTDIR=%{buildroot}" install

#%post
# change ownership 
#chown  -R  %{www_user}:%{www_group}	%{install_dir}

%build

%files
%defattr(-,%{www_user},%{www_group})
%dir			%{install_dir}
%{install_dir}/*

%changelog
