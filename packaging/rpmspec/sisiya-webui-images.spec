%define name sisiya-webui-images

%define version __VERSION__
%define release __RELEASE__

%define install_dir /var/www/html/sisiya-webui-php/images/systems

Summary: Image collection for SisIYA web user interface. These images are used for assigning to systems.
Name:%{name} 
BuildArch: noarch
BuildRoot: %{_builddir}/%{name}-root
Version: %{version}
Release: %{release}
#Obsoletes: $version-$release
Source0: http://sourceforge.net/projects/sisiya/files/sisiya/%{version}/rpm/%{name}-%{version}-%{release}.tar.gz
License: GPL
Vendor: Erdal Mutlu
Group: System Environment/Tools
Packager: Erdal Mutlu <erdal@sisiya.org>
Url: http://www.sisiya.org
Requires: sisiya-webui-php
%description 
Image collection for SisIYA web GUI. These images are used for assigning to systems. These are mostly images of various hardware.

%prep 
%setup -n %{name}-%{version}-%{release}

#%build
#exit 0

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}
make "DESTDIR=%{buildroot} WEB_BASE_DIR=/var/www/html" install


#%clean
#exit 0

%files
%defattr(-,root,root)
%dir %attr(0775,root,root) 				%{install_dir}
%attr(0664,root,root) 					%{install_dir}/*
