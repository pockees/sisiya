%define name sisiya-webui-images

%if 0%{?rhel_version}
	%define web_base_dir /var/www/html
	%define www_user  apache
	%define www_group apache
%else
	%if 0%{?suse_version}
		%define web_base_dir /srv/www/htdocs
		%define www_user  wwwrun
		%define www_group www
	%else
		%define web_base_dir /var/www/html
		%define www_user  apache
		%define www_group apache
	%endif
%endif

%define install_dir %{web_base_dir}/sisiya-webui-php/images/systems

Summary: Image collection for SisIYA web user interface. These images are used for assigning to systems
Name:%{name} 
BuildArch: noarch
BuildRoot: %{_builddir}/%{name}-root
Version: __VERSION__
Release: 0
Source0: http://sourceforge.net/projects/sisiya/files/sisiya/%{version}/rpm/%{name}-%{version}.tar.gz
License: GPL
Vendor: Erdal Mutlu
Group: System Environment/Tools
Packager: Erdal Mutlu <erdal@sisiya.org>
Url: http://www.sisiya.org
Requires: sisiya-webui-php
%description 
Image collection for SisIYA web GUI. These images are used for assigning to systems. These are mostly images of various hardware.

%prep 
%setup -n %{name}-%{version}

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}
make "DESTDIR=%{buildroot}" "WEB_BASE_DIR=%{web_base_dir}" install

%post
# change ownership 
chown  -R  %{www_user}:%{www_group}	%{install_dir}/images/links

%files
%defattr(-,root,root)
%dir %attr(0775,root,root) 				%{install_dir}
%attr(0664,root,root) 					%{install_dir}/*
