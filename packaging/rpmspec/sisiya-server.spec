%define sisiya_Release 20
%define sisiya_Version 0.5

%define sisiya_edbc_Version 0.1

%define sisiya_ServerVersion %{sisiya_Version}.17
%define sisiya_ServerRelease %{sisiya_Release}

%define sisiya_WebGuiVersion %{sisiya_Version}.20
%define sisiya_WebGuiRelease %{sisiya_Release}

%define sisiya_ClientChecksVersion %{sisiya_Version}.30
%define sisiya_ClientChecksRelease %{sisiya_Release}

%define sisiya_ClientSystemsVersion %{sisiya_Version}.7
%define sisiya_ClientSystemsRelease %{sisiya_Release}

%define sisiya_ServerChecksVersion %{sisiya_Version}.21
%define sisiya_ServerChecksRelease %{sisiya_Release}

%define sisiya_DBscriptsVersion %{sisiya_Version}.16
%define sisiya_DBscriptsRelease %{sisiya_Release}

%define sisiya_EDBCVersion %{sisiya_edbc_Version}.3
%define sisiya_EDBCRelease %{sisiya_Release}

%define sisiya_server_checks_dir /opt/sisiya_server_checks
Summary: SisIYA a system monitoring tool.
Name: sisiya
Version: %{sisiya_Version}
Release: %{sisiya_Release}
#Obsoletes: $Version-$Release
Source0: sisiya-%{version}-%{release}.tar.gz
Source1: http://download.sourceforge.net/sisiya/sisiya-%{version}-%{release}.tar.gz
License: GPL
Vendor: Erdal Mutlu
Group: System Environment/Daemons
Packager: Erdal Mutlu <emutlu@users.sourceforge.net>
Url: http://sisiya.sourceforge.net
BuildRoot:%{_tmppath}/%{name}-%{version}-%{release}-root

%description
SisIYA a system monitoring and administration tool is a tool for
monitoring the various networked systems, such as Linux/UNIX, MacOS X and
Windows servers, network switches, routers and other networked devices.
It is based on the client/server architecture. It has its own protocol
of communication. The idea is to inform the system administrators or
operators about the systems in use, about their current status (INFO, OK, WARNING, ERROR).
Mostly client systems send messages to a central server, who
places them in a database. But, there are also cases where the server self
collects some data from clients. At the same time, there is a web interface
to the data stored in the database system, which show the status of the monitored systems.
The project is written in C++, Bash, Java and Php. I plan to rewrite the Java part in C++.
The project uses edbc (JDBC) like, database driver. The supported DBs at the moment are MySQL 
and PostgreSQL.

%package server 
Version: %{sisiya_ServerVersion}
Release: %{sisiya_ServerRelease}
Summary : The SisIYA server.
Group: System Environment/Daemons
#Requires: mysql, gawk 
Requires: sisiya-edbc-libs >= 0.1
%description server
The SisIYA server.
SisIYA a system monitoring and administration tool is a tool for
monitoring the various networked systems, such as Linux/UNIX, MacOS X and
Windows servers, network switches, routers and other networked devices.
It is based on the client/server architecture. It has its own protocol
of communication. The idea is to inform the system administrators or
operators about the systems in use, about their current status (INFO, OK, WARNING, ERROR).
Mostly client systems send messages to a central server, who
places them in a database. But, there are also cases where the server self
collects some data from clients. At the same time, there is a web interface
to the data stored in the database system, which show the status of the monitored systems.
The project is written in C++, Bash, Java and Php. I plan to rewrite the Java part in C++.
The project uses edbc (JDBC) like, database driver. The supported DBs at the moment are MySQL 
and PostgreSQL.


%package server-checks
BuildArch: noarch
Version: %{sisiya_ServerChecksVersion}
Release: %{sisiya_ServerChecksRelease}
Summary: The SisIYA check programs that are run from a central server. This is normally the server where SisIYA daemon runs.
Group: System Environment/Daemons
Requires: sisiya-client-checks >= 0.4, sisiya-dbscripts >= 0.4, gawk,net-snmp net-snmp-utils, expect
%description server-checks
The SisIYA check programs that are run from a central server. This is normally the server where SisIYA daemon runs.

%package client-checks
BuildArch: noarch
Version: %{sisiya_ClientChecksVersion}
Release: %{sisiya_ClientChecksRelease}
Summary: The SisIYA client programs and checks.
Group: System Environment/Tools
%description client-checks
The SisIYA client programs and checks. This package is installed on every server that is going to be monitored by SisIYA.

%package client-systems
Version: %{sisiya_ClientSystemsVersion}
Release: %{sisiya_ClientSystemsRelease}
Summary: The systems directory for SisIYA client programs and checks.
Group: System Environment/Tools
Requires: sisiya-client-checks >= 0.4, gawk
%description client-systems
The systems directory for SisIYA client programs and checks. This package is site dependent.
In other words, the systems directory contains directories with hostnames, which contain special 
checks and configuration files for that particular host. Every site has its own set of hostnames/checks 
in the systems directory.

%package webgui
BuildArch: noarch
Version: %{sisiya_WebGuiVersion}
Release: %{sisiya_WebGuiRelease}
Summary: The SisIYA web GUI, php scripts and images for viewing the data from DB.
Group: System Environment/Tools
Requires: httpd, php, php-pgsql, php-mysql, php-gd
%description webgui
The SisIYA web GUI, php scripts and images for viewing the data from DB. You need this
package on the server on which the Apache with php is running.

%package dbscripts 
BuildArch: noarch
Version: %{sisiya_DBscriptsVersion}
Release: %{sisiya_DBscriptsRelease}
Summary: The SisIYA scripts for creating the necessery tables and inserting the default values.
Group: System Environment/Tools
%if 0%{?suse_version}
Requires: gawk
%else
Requires: mysql,mysql-server, gawk
%endif
#Requires: postgresql-server, postgresql, gawk
%description dbscripts
The SisIYA scripts for creating the necessery tables and inserting the default values.
You need these scripts on the server on which the database systems is running.

%package edbc-devel 
Version: %{sisiya_EDBCVersion}
Release: %{sisiya_EDBCRelease}
Requires: postgresql-libs, mysql
Summary: The SisIYA EDBC development environment.
Group: Application/Devepment
%description edbc-devel
This package contains the SisIYA EDBC headers and libraries.

%package edbc-docs
Version: %{sisiya_EDBCVersion}
Release: %{sisiya_EDBCRelease}
Summary: The SisIYA EDBC documentation.
Group: Application/Docs
%description edbc-docs
This package contains the SisIYA EDBC documentation.

%package edbc-libs
Version: %{sisiya_EDBCVersion}
Release: %{sisiya_EDBCRelease}
Summary: The SisIYA EDBC libraries.
Requires: postgresql-libs, mysql
Group: Application/Libraries
%description edbc-libs
This package contains the SisIYA EDBC libraries.

%prep 
%setup -q -n sisiya-%{sisiya_Version}-%{sisiya_Release}

%build
### configure & compile
make 

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}
#make "install_root=$RPM_BUILD_ROOT" install

cd src/ && make "install_root=%{buildroot}" install && cd ..

### install server
cd sisiya_server && make "install_root=%{buildroot}" install && cd ..

### install edbc
cd edbc && make "install_root=%{buildroot}" install && cd ..

### remove Helvetica.ttf font file which is auto generated by doxygen
rm -f %{buildroot}/opt/sisiya_edbc_docs/latex/Helvetica.ttf

%pre
str=`grep -i suse /etc/issue.net`
if test -n "$str" ; then
	%define www_user wwwrun
	%define www_group www
else
	%define www_user apache
	%define www_group apache 
fi

%post server
### if update, then restart
if test $1 -eq 2 ; then
	service sisiyad restart > /dev/null 
	exit 0
fi
chkconfig --add sisiyad
service sisiyad start > /dev/null 


%preun server
### if update
if test $1 -eq 1 ; then
	exit 0
fi
#service sisiyaqd stop > /dev/null 2>&1
service sisiyad stop > /dev/null 2>&1
#chkconfig --del sisiyaqd
chkconfig --del sisiyad

%clean 
rm -rf %{buildroot}

%post webgui 

%preun webgui
                                                                                                                            
### there is no main package
#%files

%files server
%defattr(-,root,root)
%attr(0644,root,root) 	%doc 			README NEWS ChangeLog AUTHORS INSTALL TODO
%attr(0600,root,root) 	%config(noreplace) 	/etc/sisiyad.conf
#%attr(0600,root,root) 	%config(noreplace) 	/etc/sisiyaqd.conf
%attr(0700,root,root) 				/etc/init.d/sisiyad
#%attr(0700,root,root) 				/etc/init.d/sisiyaqd
%attr(0700,root,root) 				/usr/sbin/sisiyad
#%attr(0700,root,root) 				/usr/sbin/sisiyaqd
%attr(0644,root,root) 				/usr/share/man/man5/sisiyad.conf.5.gz
#%attr(0644,root,root) 				/usr/share/man/man5/sisiyaqd.conf.5.gz
%attr(0644,root,root) 				/usr/share/man/man8/sisiyad.8.gz
#%attr(0644,root,root) 				/usr/share/man/man8/sisiyaqd.8.gz

%files server-checks 
%dir %attr(0755,root,root) 				/etc/cron.d
%attr(0600,root,root) 		%config(noreplace) 	/etc/cron.d/sisiya_remote_checks
%attr(0600,root,root) 		%config(noreplace) 	/etc/cron.d/sisiya_db_checks
%attr(0644,root,root) 		%doc 			README NEWS ChangeLog AUTHORS INSTALL TODO
%attr(0750,root,%{www_group}) 	%dir 			%{sisiya_server_checks_dir}
%attr(0750,root,root) 		%dir			%{sisiya_server_checks_dir}/bin
%attr(0750,root,%{www_group})	%dir			%{sisiya_server_checks_dir}/conf
%attr(0750,root,root) 		%dir			%{sisiya_server_checks_dir}/lib
%attr(0750,root,root) 		%dir 			%{sisiya_server_checks_dir}/scripts
%attr(0750,root,root) 		%dir			%{sisiya_server_checks_dir}/utils
%attr(0700,root,root)					%{sisiya_server_checks_dir}/bin/*
%attr(0660,root,root) 		%config(noreplace)	%{sisiya_server_checks_dir}/conf/class_path
%attr(0660,root,%{www_group})	%config(noreplace) 	%{sisiya_server_checks_dir}/conf/sisiya_server_checks.conf
%attr(0660,root,%{www_group})		 		%{sisiya_server_checks_dir}/conf/sisiya_server_checks_defaults.conf
%attr(0660,root,%{www_group})	%config(noreplace) 	%{sisiya_server_checks_dir}/conf/*.properties
%attr(0660,root,%{www_group})	%config(noreplace) 	%{sisiya_server_checks_dir}/conf/*.xml
%attr(0660,root,root)					%{sisiya_server_checks_dir}/lib/*.*
%attr(0700,root,root) 					%{sisiya_server_checks_dir}/scripts/*.*
%attr(0700,root,root) 					%{sisiya_server_checks_dir}/utils/*.*

%files client-checks
%defattr(-,root,root)
%dir %attr(0755,root,root) 				/etc/cron.d
%attr(0600,root,root) 		%config(noreplace) 	/etc/cron.d/sisiya_client_checks
%attr(0644,root,root) 		%doc 			README NEWS ChangeLog AUTHORS INSTALL TODO
%dir %attr(0755,root,root) 				/opt/sisiya_client_checks
#/opt/sisiya_checks
%dir %attr(0755,root,root) 				/opt/sisiya_client_checks/bin
%dir %attr(0755,root,root) 				/opt/sisiya_client_checks/common
%dir %attr(0755,root,root) 				/opt/sisiya_client_checks/special
%attr(0644,root,root) 		%config(noreplace) 	/opt/sisiya_client_checks/sisiya_client.conf
%attr(0755,root,root) 					/opt/sisiya_client_checks/bin/*.sh
%attr(0755,root,root) 					/opt/sisiya_client_checks/bin/*.pl
%attr(0755,root,root) 					/opt/sisiya_client_checks/common/sisiya_*.sh
%attr(0755,root,root) 					/opt/sisiya_client_checks/special/sisiya_*.sh

%files client-systems
%defattr(-,root,root)
%dir %attr(0700,root,root) /opt/sisiya_client_checks/systems
/opt/sisiya_client_checks/systems/*

%files webgui
%defattr(-,root,root)
%dir %attr(0755,root,root) 				/etc/cron.d
%attr(0600,root,root) 		%config(noreplace) 	/etc/cron.d/sisiya_alerts
%attr(0600,root,root) 		%config(noreplace) 	/etc/cron.d/sisiya_archive
%attr(0600,root,root) 		%config(noreplace) 	/etc/cron.d/sisiya_check_expired
%attr(0600,root,root) 		%config(noreplace) 	/etc/cron.d/sisiya_rss
%attr(0644,root,root) 		%doc 			README NEWS ChangeLog AUTHORS INSTALL TODO
%dir %attr(0755,root,root) 				/etc/httpd/conf.d
%attr(0644,root,root) 		%config 		/etc/httpd/conf.d/sisiya.conf
%dir %attr(0755,root,root) 				/var/www/html/sisiya
%attr(0644,root,root) 					/var/www/html/sisiya/*.php
%dir %attr(0755,root,root) 				/var/www/html/sisiya/conf
%attr(0644,root,root) 		%config 		/var/www/html/sisiya/conf/*.php
%dir %attr(0755,root,root) 				/var/www/html/sisiya/javascript
%attr(0644,root,root) 					/var/www/html/sisiya/javascript/*.js
%dir %attr(0755,root,root) 				/var/www/html/sisiya/lib
%attr(0644,root,root) 					/var/www/html/sisiya/lib/*.php
%dir %attr(0755,root,root) 				/var/www/html/sisiya/style
%attr(0644,root,root) 					/var/www/html/sisiya/style/*.css
%dir %attr(0755,root,root) 				/var/www/html/sisiya/autodiscover
%attr(0755,root,root) 					/var/www/html/sisiya/autodiscover/*.sh
%attr(0755,root,root) 					/var/www/html/sisiya/autodiscover/*.php
%dir %attr(0755,root,root) 				/var/www/html/sisiya/images
%dir %attr(0755,root,root) 				/var/www/html/sisiya/images/links
%dir %attr(0755,root,root) 				/var/www/html/sisiya/images/sisiya
%dir %attr(0755,root,root) 				/var/www/html/sisiya/images/systems
%dir %attr(0755,root,root) 				/var/www/html/sisiya/images/tmp
%attr(0644,root,root) 					/var/www/html/sisiya/images/sisiya/*.ico
%attr(0644,root,root) 					/var/www/html/sisiya/images/sisiya/*.gif
%attr(0644,root,root) 					/var/www/html/sisiya/images/sisiya/*.png
%attr(0644,root,root) 					/var/www/html/sisiya/images/systems/*.gif
%dir %attr(0755,root,root) 				/var/www/html/sisiya/XMPPHP
%attr(0644,root,root) 					/var/www/html/sisiya/XMPPHP/*.php

%files dbscripts
%defattr(-,root,root)
%dir %attr(0700,root,root) 				/opt/sisiya_dbscripts
%attr(0700,root,root) 					/opt/sisiya_dbscripts/dbscript.sh
%attr(0700,root,root) 					/opt/sisiya_dbscripts/exec_MySQL.sh
%attr(0700,root,root) 					/opt/sisiya_dbscripts/exec_PostgreSQL.sh
#%attr(0700,root,root) 					/opt/sisiya_dbscripts/make_history_archive_PostgreSQL.sh
#%attr(0700,root,root) 					/opt/sisiya_dbscripts/make_history_archive_MySQL.sh
%attr(0600,root,root) 					/opt/sisiya_dbscripts/INSTALL
%attr(0600,root,root) 					/opt/sisiya_dbscripts/README
%attr(0600,root,root) 					/opt/sisiya_dbscripts/Makefile
%attr(0600,root,root) 					/opt/sisiya_dbscripts/db_MySQL.conf
%attr(0600,root,root) 					/opt/sisiya_dbscripts/db_PostgreSQL.conf
%attr(0600,root,root) 					/opt/sisiya_dbscripts/create_tables.sql
%attr(0600,root,root) 					/opt/sisiya_dbscripts/drop_tables.sql
%attr(0600,root,root) 					/opt/sisiya_dbscripts/populate_db.sql
%attr(0700,root,root) 					/opt/sisiya_dbscripts/language.sh
%attr(0700,root,root) 					/opt/sisiya_dbscripts/update_languages.sh
%attr(0600,root,root) 					/opt/sisiya_dbscripts/language_*.xml

%files edbc-devel
%defattr(-,root,root)
%attr(644,root,root) 					/opt/sisiya_edbc/include/*.hpp
%attr(644,root,root) 					/opt/sisiya_edbc/lib/*.a


%files edbc-docs
%defattr(-,root,root)
/opt/sisiya_edbc_docs

%files edbc-libs
%defattr(-,root,root)
#%attr(0644,root,root) %doc README NEWS ChangeLog AUTHORS INSTALL TODO
%attr(0755,root,root) 					/opt/sisiya_edbc/lib/*.so
%attr(-,root,root) 					/opt/sisiya_edbc/lib/*.so.%{sisiya_EDBCVersion}
