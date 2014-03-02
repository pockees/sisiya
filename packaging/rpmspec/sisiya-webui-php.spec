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
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA


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


Name: sisiya-webui-php
%define web_base_dir /usr/share/%{name}
Summary: PHP web UI for SisIYA
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
Requires: bash, httpd, php, php-mysql, php-gd, php-mbstring, nmap, sisiya-client-checks, sisiya-remote-checks, sisiya-webui-images
%description 
PHP web user and administration interface for SisIYA.

%prep 
%setup -n %{name}-%{version}

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}
make "DESTDIR=%{buildroot}" install

%post
# change ownership 
#chown  -R  %{www_user}:%{www_group}	%{web_base_dir}/images/links
mkdir -p /var/tmp/%{name}
chown -R %{www_user}:%{www_group} /var/tmp/%{name}

ln -s /etc/sisiya/sisiya-remote-checks/conf.d /usr/share/%{name}/xmlconf
ln -s /var/lib/%{name}/sisiya_rss.xml /usr/share/%{name}/sisiya_rss.xml
ln -s /var/lib/%{name}/packages /usr/share/%{name}/packages
# images dir links
ln -s /var/lib/%{name}/links /usr/share/%{name}/images/links
ln -s /var/lib/sisiya-webui-images /usr/share/%{name}/images/systems
ln -s /var/tmp/%{name} /usr/share/%{name}/images/tmp

%build

%files
%defattr(-,%{www_user},%{www_group})
%dir			/etc/sisiya/%{name}
%dir			%{web_base_dir}
%dir			%{web_base_dir}/javascript
%dir			%{web_base_dir}/lib
%dir			%{web_base_dir}/style
%dir			%{web_base_dir}/images
%dir			%{web_base_dir}/images/links
%dir			%{web_base_dir}/images/sisiya
%dir			%{web_base_dir}/images/systems
%dir			%{web_base_dir}/install
%dir			%{web_base_dir}/images/tmp
%dir			/var/lib/%{name}/packages
%dir			%{web_base_dir}/packages
%dir			%{web_base_dir}/XMPPHP
%dir			%{web_base_dir}/utils
%config(noreplace) 	/etc/cron.d/sisiya-alerts
%config(noreplace) 	/etc/cron.d/sisiya-archive
%config(noreplace) 	/etc/cron.d/sisiya-check-expired
%config(noreplace) 	/etc/cron.d/sisiya-rss
%config(noreplace)	/etc/sisiya/%{name}/*.php
%config(noreplace)	/etc/sisiya/%{name}/*.conf
			%{web_base_dir}/favicon.ico
			%{web_base_dir}/*.*
			%{web_base_dir}/README.txt
			%{web_base_dir}/INSTALL.txt
			%{web_base_dir}/javascript/*.js
			%{web_base_dir}/lib/*.php
			%{web_base_dir}/style/*.css
			%{web_base_dir}/images/sisiya/*.*
			%{web_base_dir}/install/*
			%{web_base_dir}/packages
			/var/lib/%{name}/packages/*.*
			%{web_base_dir}/XMPPHP/*.php
			%{web_base_dir}/utils/*.php
			%{web_base_dir}/utils/*.sh

%changelog
