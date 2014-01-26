%define name sisiya-webui-php

%define version __VERSION__
%define release __RELEASE__

%define install_dir /var/www/html/%{name}

### define distro
#%define is_redhat 	%(test -e /etc/redhat-release 	&& echo 1 || echo 0)
%define is_mandrake 	%(test -e /etc/mandrake-release && echo 1 || echo 0)
%define is_suse 	%(test -e /etc/SuSE-release 	&& echo 1 || echo 0)
%define is_fedora 	%(test -e /etc/fedora-release 	&& echo 1 || echo 0)

%define www_user  apache
%define www_group apache

%if %is_suse
%define www_user  wwwrun
%define www_group www
%endif


Summary: SisIYA' PHP web UI.
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
SisIYA's PHP web UI.

%prep 
#%setup ###-q -n sisiya-%{sisiya_Version}-%{sisiya_Release}
%setup -n %{name}-%{version}-%{release}

#%build
#exit 0

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}
make "DESTDIR=%{buildroot}" "WEB_BASE_DIR=/var/www/html" install

%post
# change ownership 
chown  -R  %{www_user}:%{www_group}	%{install_dir}/images/links

#%clean
#exit 0

%files
%defattr(-,root,root)
%dir %attr(0755,root,root) 				/etc/cron.d
%attr(0600,root,root) 		%config(noreplace) 	/etc/cron.d/sisiya_alerts
%attr(0600,root,root) 		%config(noreplace) 	/etc/cron.d/sisiya_archive
%attr(0600,root,root) 		%config(noreplace) 	/etc/cron.d/sisiya_check_expired
%attr(0600,root,root) 		%config(noreplace) 	/etc/cron.d/sisiya_rss
%dir %attr(0755,root,root) 				/etc/httpd/conf.d
%attr(0644,root,root) 		%config 		/etc/httpd/conf.d/sisiya.conf
%dir %attr(0755,root,root) 				%{install_dir}
%attr(0644,root,root) 					%{install_dir}/favicon.ico
%attr(0644,root,root) 					%{install_dir}/*.php
%dir %attr(0755,root,root) 				%{install_dir}/conf
%attr(0644,root,root) 		%config(noreplace)	%{install_dir}/conf/*.php
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
%dir %attr(0755,root,root) 				%{install_dir}/XMPPHP
%attr(0644,root,root) 					%{install_dir}/XMPPHP/*.php
#%attr(0644,root,root) 					%{install_dir}/xmlconf
