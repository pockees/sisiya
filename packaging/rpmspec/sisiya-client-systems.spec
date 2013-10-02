%define name sisiya-client-systems

%define version 0.5.7
%define release 22

%define install_dir /opt/sisiya-client-checks/systems

Summary: The systems directory for SisIYA client programs and checks.
Name:%{name} 
BuildArch: noarch
BuildRoot: %{_builddir}/%{name}-root
Version: %{version}
Release: %{release}
#Obsoletes: $version-$release
Source0: %{name}-%{version}-%{release}.tar.gz
#Source1: http://download.sourceforge.net/sisiya/%{name}-%{version}-%{release}.tar.gz
License: GPL
Vendor: Erdal Mutlu
Group: System Environment/Daemons
Packager: Erdal Mutlu <emutlu@users.sourceforge.net>
Url: http://sisiya.sourceforge.net
Requires: sisiya-client-checks
%description 
The systems directory for SisIYA client programs and checks. This package is site dependent.
In other words, the systems directory contains directories with hostnames, which contain special 
checks and configuration files for that particular host. Every site has its own set of hostnames/checks 
in the systems directory.

%prep 
#%setup ###-q -n sisiya-%{sisiya_Version}-%{sisiya_Release}
%setup -n %{name}-%{version}-%{release}

#%build
#exit 0

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}
make "install_root=%{buildroot}" install_sisiya_client_systems

%post
### clean up: remove all systems directories exept for this system
host_name=`hostname`
str=`echo $host_name | grep "."`
if test -n "$str" ; then
	short_host_name=`echo $host_name | cut -d "." -f 1`
else
	short_host_name=$host_name
fi
cd %{install_dir}
for d in *
do
       d_short=`echo $d | cut -d "." -f 1`
       if test "$d" == "$host_name" || test "$d" == "$short_host_name" || test "$d_short" == "$short_host_name"; then
               continue
       fi
       rm -rf $d
done

#%clean
#exit 0

%files
%defattr(-,root,root)
%dir %attr(0700,root,root) %{install_dir}
%{install_dir}/*
