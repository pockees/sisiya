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


Name: sisiya-webui-php
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
make "DESTDIR=%{buildroot}" "WEB_BASE_DIR=%{web_base_dir}" install

%post
# change ownership 
chown  -R  %{www_user}:%{www_group}	%{install_dir}/images/links

%build

%files
%defattr(-,root,root)
%attr(0755,root,root)		%dir			%{install_dir}
%attr(0755,root,root) 		%dir			%{install_dir}/conf
%attr(0755,root,root)		%dir			%{install_dir}/javascript
%attr(0755,root,root) 		%dir			%{install_dir}/lib
%attr(0755,root,root) 		%dir			%{install_dir}/style
%attr(0755,root,root) 		%dir			%{install_dir}/autodiscover
%attr(0755,root,root) 		%dir			%{install_dir}/images
%attr(0755,root,root) 		%dir			%{install_dir}/images/links
%attr(0755,root,root) 		%dir			%{install_dir}/images/sisiya
%attr(0755,root,root) 		%dir			%{install_dir}/images/systems
%attr(0755,root,root)		%dir			%{install_dir}/install
%attr(0755,root,root) 		%dir			%{install_dir}/images/tmp
%attr(0755,root,root) 		%dir			%{install_dir}/XMPPHP
%attr(0755,root,root) 		%dir			%{install_dir}/utils
%attr(0600,root,root) 		%config(noreplace) 	/etc/cron.d/sisiya-alerts
%attr(0600,root,root) 		%config(noreplace) 	/etc/cron.d/sisiya-archive
%attr(0600,root,root) 		%config(noreplace) 	/etc/cron.d/sisiya-check-expired
%attr(0600,root,root) 		%config(noreplace) 	/etc/cron.d/sisiya-rss
%attr(0755,root,root) 					%{install_dir}/autodiscover/*.sh
%attr(0755,root,root) 					%{install_dir}/autodiscover/*.php
%attr(0644,root,root) 					%{install_dir}/favicon.ico
%attr(0644,root,root) 					%{install_dir}/*.php
%attr(0644,root,root) 					%{install_dir}/README.txt
%attr(0644,root,root) 					%{install_dir}/INSTALL.txt
%attr(0644,root,root) 		%config(noreplace)	%{install_dir}/conf/*.php
%attr(0644,root,root) 		%config(noreplace)	%{install_dir}/conf/*.conf
%attr(0644,root,root) 					%{install_dir}/javascript/*.js
%attr(0644,root,root) 					%{install_dir}/lib/*.php
%attr(0644,root,root) 					%{install_dir}/style/*.css
%attr(0644,root,root) 					%{install_dir}/images/sisiya/*.gif
%attr(0644,root,root) 					%{install_dir}/images/sisiya/*.png
			 				%{install_dir}/install/*
%attr(0644,root,root) 					%{install_dir}/XMPPHP/*.php
%attr(0644,root,root) 					%{install_dir}/utils/*.php

%changelog
