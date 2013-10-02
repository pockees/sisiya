%define name sisiya-webgui-systems-images

%define version 0.5.20
%define release 1

%define install_dir /var/www/html/sisiya/images/systems

Summary: Image collection for SisIYA web GUI. These images are used for assigning to systems.
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
Group: System Environment/Tools
Packager: Erdal Mutlu <emutlu@users.sourceforge.net>
Url: http://sisiya.sourceforge.net
Requires: sisiya-webgui
%description 
Image collection for SisIYA web GUI. These images are used for assigning to systems. These are mostly images of various hardware.

%prep 
#%setup ###-q -n sisiya-%{sisiya_Version}-%{sisiya_Release}
%setup -n %{name}-%{version}-%{release}

#%build
#exit 0

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}
make "install_root=%{buildroot}"


#%clean
#exit 0

%files
%defattr(-,root,root)
%dir %attr(0775,root,root) 				%{install_dir}
%attr(0664,root,root) 					%{install_dir}/*.gif
