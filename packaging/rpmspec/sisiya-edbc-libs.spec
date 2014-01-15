%define name sisiya-edbc-libs

%define version __VERSION__
%define release __RELEASE__

Summary: The SisIYA server / remote check programs that are run from a central server. This is normally the server where SisIYA daemon runs.
Name:%{name} 
#BuildArch: noarch
BuildRoot: %{_builddir}/%{name}-root
Version: %{version}
Release: %{release}
#Obsoletes: $version-$release
Source0: %{name}-%{version}-%{release}.tar.gz
#Source1: http://download.sourceforge.net/sisiya/%{name}-%{version}-%{release}.tar.gz
License: GPL
Vendor: Erdal Mutlu
Group: System Environment/Daemons
Packager: Erdal Mutlu <erdal@sisiya.org>
Url: http://www.sisiya.org
BuildRequires: doxygen mysql-devel postgresql-devel
Requires: mysql-libs postgresql-libs
%description 
This package contains the SisIYA EDBC libraries.

%prep 
%setup -n %{name}-%{version}-%{release}

%build
### configure & compile
make 

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}

make "DSTDIR=%{buildroot}" install 

%pre

%clean 
rm -rf %{buildroot}

%files
%defattr(-,root,root)
#%attr(0644,root,root) %doc README NEWS ChangeLog AUTHORS INSTALL TODO
%attr(0755,root,root) 					/usr/lib/*.so*
