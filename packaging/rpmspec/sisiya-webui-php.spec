%define name sisiya-webui-php

%define version __VERSION__
%define release __RELEASE__


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

%define install_dir %{web_base_dir}/%{name}

Summary: PHP web UI for SisIYA.
Name:%{name} 
BuildArch: noarch
BuildRoot: %{_builddir}/%{name}-root
Version: %{version}
Release: %{release}
Source0: http://sourceforge.net/projects/sisiya/files/sisiya/%{version}/rpm/%{name}-%{version}-%{release}.tar.gz
License: GPL
Vendor: Erdal Mutlu
Group: System Environment/Tools
Packager: Erdal Mutlu <erdal@sisiya.org>
Url: http://www.sisiya.org
Requires: bash, httpd, php, php-mysql, php-gd, php-mbstring, nmap, sisiya-client-checks
%description 
PHP web UI for SisIYA.

%prep 
%setup -n %{name}-%{version}-%{release}

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}
make "DESTDIR=%{buildroot}" "WEB_BASE_DIR=%{web_base_dir}" install

%post
# change ownership 
chown  -R  %{www_user}:%{www_group}	%{install_dir}/images/links

#%clean
#exit 0

%files
%defattr(-,root,root)
%dir %attr(0755,root,root) 				/etc/cron.d
%attr(0600,root,root) 		%config(noreplace) 	/etc/cron.d/sisiya-alerts
%attr(0600,root,root) 		%config(noreplace) 	/etc/cron.d/sisiya-archive
%attr(0600,root,root) 		%config(noreplace) 	/etc/cron.d/sisiya-check-expired
%attr(0600,root,root) 		%config(noreplace) 	/etc/cron.d/sisiya-rss
%dir %attr(0755,root,root) 				%{install_dir}
%attr(0644,root,root) 					%{install_dir}/favicon.ico
%attr(0644,root,root) 					%{install_dir}/*.php
%attr(0644,root,root) 					%{install_dir}/README.txt
%attr(0644,root,root) 					%{install_dir}/INSTALL.txt
%dir %attr(0755,root,root) 				%{install_dir}/conf
%attr(0644,root,root) 		%config(noreplace)	%{install_dir}/conf/*.php
%attr(0644,root,root) 		%config(noreplace)	%{install_dir}/conf/*.conf
%dir %attr(0755,root,root) 				%{install_dir}/javascript
%attr(0644,root,root) 					%{install_dir}/javascript/*.js
%dir %attr(0755,root,root) 				%{install_dir}/lib
%attr(0644,root,root) 					%{install_dir}/lib/*.php
%dir %attr(0755,root,root) 				%{install_dir}/style
%attr(0644,root,root) 					%{install_dir}/style/*.css
%dir %attr(0755,root,root) 				%{install_dir}/autodiscover
%attr(0755,root,root) 					%{install_dir}/autodiscover/*.sh
%attr(0755,root,root) 					%{install_dir}/autodiscover/*.php
%dir %attr(0755,root,root) 				%{install_dir}/images
%dir %attr(0755,root,root) 				%{install_dir}/images/links
%dir %attr(0755,root,root) 				%{install_dir}/images/sisiya
%dir %attr(0755,root,root) 				%{install_dir}/images/systems
%dir %attr(0755,root,root) 				%{install_dir}/images/tmp
%attr(0644,root,root) 					%{install_dir}/images/sisiya/*.gif
%attr(0644,root,root) 					%{install_dir}/images/sisiya/*.png
%dir %attr(0755,root,root) 				%{install_dir}/install
			 				%{install_dir}/install/*
%dir %attr(0755,root,root) 				%{install_dir}/XMPPHP
%attr(0644,root,root) 					%{install_dir}/XMPPHP/*.php
%attr(0644,root,root) 					%{install_dir}/xmlconf
%dir %attr(0755,root,root) 				%{install_dir}/utils
%attr(0644,root,root) 					%{install_dir}/utils/*.php
