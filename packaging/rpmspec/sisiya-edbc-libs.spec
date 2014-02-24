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

%define is_fedora %(test -e /etc/fedora-release && echo 1 || echo 0)
%define is_redhat %(test -e /etc/redhat-release && echo 1 || echo 0)
#%define is_mandrake %(test -e /etc/mandrake-release && echo 1 || echo 0)
%define is_suse %(test -e /etc/SuSE-release && echo 1 || echo 0)


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
#%if 0%{?is_suse} 
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

#%if %is_suse 
%if 0%{?suse_version} 
%ifarch x86_64
	mkdir %{buildroot}/usr/lib64
	mv %{buildroot}/usr/lib/libedbc* %{buildroot}/usr/lib64
%endif
%endif

%post
/sbin/ldconfig

%postun
/sbin/ldconfig

%clean 
rm -rf %{buildroot}

%files
%defattr(-,root,root)
#%if %is_suse 
%if 0%{?suse_version} 
%ifarch x86_64
/usr/lib64/*.so*
/usr/lib64/*.so
%else
/usr/lib/*.so*
/usr/lib/*.so
%endif
%else
/usr/lib/*.so*
/usr/lib/*.so
%endif

%changelog
