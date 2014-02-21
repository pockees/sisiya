%define name sisiya-edbc-libs

### define distro
#%define is_redhat 	%(test -e /etc/redhat-release 	&& echo 1 || echo 0)
%define is_mandrake 	%(test -e /etc/mandrake-release && echo 1 || echo 0)
%define is_suse 	%(test -e /etc/SuSE-release 	&& echo 1 || echo 0)
%define is_fedora 	%(test -e /etc/fedora-release 	&& echo 1 || echo 0)


Summary: Libraries written in C++ for Database connectivity like JDBC.
Name:%{name} 
BuildRoot: %{_builddir}/%{name}-root
Version: __VERSION__
Release: 0
Source0: http://sourceforge.net/projects/sisiya/files/sisiya/%{version}/rpm/%{name}-%{version}.tar.gz
License: GPL
Vendor: Erdal Mutlu
Group: System Environment/Daemons
Packager: Erdal Mutlu <erdal@sisiya.org>
Url: http://www.sisiya.org
BuildRequires: autoconf automake doxygen gcc-c++ mysql-devel postgresql-devel
%if 0%{?suse_version} 
Requires: libmysqlclient18 libpq5
%else
Requires: mysql-libs postgresql-libs
%endif
%description 
This package contains the SisIYA EDBC libraries.

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

%pre

%clean 
rm -rf %{buildroot}

%files
%defattr(-,root,root)
#%attr(0644,root,root) %doc README NEWS ChangeLog AUTHORS INSTALL TODO
/usr/lib/*.so*
