%define name sisiya-webgui

%define version 0.5.20
%define release 29

%define install_dir /var/www/html/sisiya

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


Summary: The SisIYA web GUI, php scripts for viewing and administering SisIYA data from DB.
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
Requires: bash, httpd, php, php-mysql, php-gd, php-mbstring, sisiya-server-checks, sisiya-client-checks
%description 
The SisIYA web GUI, php scripts and images for viewing the data from DB. You need this
package on the server on which the Apache with php is running.

%prep 
#%setup ###-q -n sisiya-%{sisiya_Version}-%{sisiya_Release}
%setup -n %{name}-%{version}-%{release}

#%build
#exit 0

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}
make "install_root=%{buildroot}" install_sisiya_webgui

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
#%attr(0644,root,root) 		%doc 			README NEWS ChangeLog AUTHORS INSTALL TODO
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
%attr(0644,root,root) 					%{install_dir}/xmlconf
