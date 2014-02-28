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
%define install_dir %{web_base_dir}/%{name}
BuildArch: noarch
BuildRoot: %{_builddir}/%{name}-root
Version: __VERSION__
Release: 0
Source0: http://sourceforge.net/projects/sisiya/files/sisiya/%{version}/rpm/%{name}-%{version}.tar.gz
License: GPL-2.0+
Vendor: Erdal Mutlu
Group: System Environment/Tools
Packager: Erdal Mutlu <erdal@sisiya.org>
Requires: bash, httpd, php, php-mysql, php-gd, php-mbstring, nmap, sisiya-client-checks
%description 
PHP web user and administration interface for SisIYA.

%prep 
%setup -n %{name}-%{version}

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}
make "DESTDIR=%{buildroot}" install

#%post
# change ownership 
#chown  -R  %{www_user}:%{www_group}	%{install_dir}/images/links

%build

%files
%defattr(-,%{www_user},%{www_group})
%dir			%{install_dir}
%dir			%{install_dir}/conf
%dir			%{install_dir}/javascript
%dir			%{install_dir}/lib
%dir			%{install_dir}/style
%dir			%{install_dir}/images
%dir			%{install_dir}/images/links
%dir			%{install_dir}/images/sisiya
%dir			%{install_dir}/images/systems
%dir			%{install_dir}/install
%dir			%{install_dir}/images/tmp
%dir			%{install_dir}/XMPPHP
%dir			%{install_dir}/utils
%config(noreplace) 	/etc/cron.d/sisiya-alerts
%config(noreplace) 	/etc/cron.d/sisiya-archive
%config(noreplace) 	/etc/cron.d/sisiya-check-expired
%config(noreplace) 	/etc/cron.d/sisiya-rss
			%{install_dir}/favicon.ico
			%{install_dir}/*.php
			%{install_dir}/README.txt
			%{install_dir}/INSTALL.txt
%config(noreplace)	%{install_dir}/conf/*.php
%config(noreplace)	%{install_dir}/conf/*.conf
			%{install_dir}/javascript/*.js
			%{install_dir}/lib/*.php
			%{install_dir}/style/*.css
			%{install_dir}/images/sisiya/*.*
			%{install_dir}/install/*
			%{install_dir}/XMPPHP/*.php
			%{install_dir}/utils/*.php
			%{install_dir}/utils/*.sh

%changelog
