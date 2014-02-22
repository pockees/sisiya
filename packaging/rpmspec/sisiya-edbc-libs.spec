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

Name: sisiya-edbc-libs
Url: http://www.sisiya.org
Summary: Libraries written in C++ for Database connectivity like JDBC
BuildRoot: %{_builddir}/%{name}-root
Version: __VERSION__
Release: 0
Source0: http://sourceforge.net/projects/sisiya/files/sisiya/%{version}/rpm/%{name}-%{version}.tar.gz
License: GPL-2.0+
Vendor: Erdal Mutlu
Group: System Environment/Daemons
Packager: Erdal Mutlu <erdal@sisiya.org>
BuildRequires: autoconf automake doxygen gcc-c++ mysql-devel postgresql-devel
#%if 0%{?suse_version} 
#Requires: libmysqlclient18 libpq5
#%else
#Requires: mysql-libs postgresql-libs
#%endif
%description 
Libraries written in C++ for Database connectivity like JDBC used
by the SisIYA daemon.

%prep 
%setup -n %{name}-%{version}

%build
./bootstrap create
./configure --prefix=
make

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}

make "DESTDIR=%{buildroot}" install 

%post
/sbin/ldconfig

%postun
/sbin/ldconfig

%clean 
rm -rf %{buildroot}

%files
%defattr(-,root,root)
/usr/lib/*.so*
/usr/lib/*.so

%changelog
