%define name sisiyad

Summary: SisIYA daemon.
Name: %{name}
Version: 0.6.30.21
Release: 0
Source0: http://sourceforge.net/projects/sisiya/files/sisiya/%{version}/rpm/%{name}-%{version}.tar.gz
License: GPL
Vendor: Erdal Mutlu
Group: System Environment/Daemons
Packager: Erdal Mutlu <erdal@sisiya.org>
Url: http://www.sisiya.org
BuildRoot:%{_tmppath}/%{name}-%{version}-%{release}-root
%if 0%{?suse_version} 
BuildRequires: autoconf automake doxygen gcc-c++ mysql-devel postgresql-devel
Requires: libmysqlclient18 libpq5
%else
BuildRequires: autoconf automake doxygen gcc-c++ mysql-devel postgresql-devel
Requires: mysql-libs postgresql-libs
%endif
Requires: sisiya-edbc-libs

%description
The SisIYA daemon is a program which receives incomming SisIYA messages and records them
in a database system.

%prep 
%setup -n %{name}-%{version}

%build
./bootstrap create
./configure --prefix=/
make

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}
make "DESTDIR=%{buildroot}" install 
%if 0%{?rhel_version}
%if 0%{?rhel_version} < 700 
	%define sisiyad_service_dst_dir /etc/init.d
	%define sisiyad_service_src_file sisiyad_sysvinit
	%define sisiyad_service_dst_file sisiyad
%endif
%else
	%define sisiyad_service_dst_dir /etc/systemd/system
	%define sisiyad_service_src_file sisiyad_systemd
	%define sisiyad_service_dst_file sisiyad.service
%endif
mkdir -p %{buildroot}%{sisiyad_service_dst_dir}
cp etc/%{sisiyad_service_src_file} %{buildroot}%{sisiyad_service_dst_dir}/%{sisiyad_service_dst_file}

%post
if test $1 -ne 2 ; then
	exit 0
fi
%if 0%{?rhel_version}
%if 0%{?rhel_version} < 700 
	service sisiyad restart > /dev/null 
%endif
%else
	/usr/bin/systemctl daemon-reload
	/usr/bin/systemctl restart sisiyad 
%endif

%preun 
### if update
if test $1 -eq 1 ; then
	exit 0
fi
%if 0%{?rhel_version}
%if 0%{?rhel_version} < 700 
	service sisiyad stop > /dev/null 2>&1
	chkconfig --del sisiyad
%endif
%else
	/usr/bin/systemctl stop sisiyad
	/usr/bin/systemctl disable sisiyad
%endif

%clean 
rm -rf %{buildroot}

%files
%defattr(-,root,root)
#%attr(0644,root,root) 	%doc 			AUTHORS ChangeLog NEWS README
%attr(0700,root,root) 				/etc/sisiya
%attr(0700,root,root) 				/etc/sisiya/sisiyad
%attr(0700,root,root) 				/etc/systemd
%attr(0700,root,root) 				/etc/systemd/system
%attr(0600,root,root) 	%config(noreplace) 	/etc/sisiya/sisiyad/sisiyad.conf
%attr(0700,root,root) 				%{sisiyad_service_dst_dir}/%{sisiyad_service_dst_file}
%attr(0700,root,root) 				/usr/sbin/sisiyad
%attr(0644,root,root) 				/usr/share/man/man5/sisiyad.conf.5.gz
%attr(0644,root,root) 				/usr/share/man/man8/sisiyad.8.gz
