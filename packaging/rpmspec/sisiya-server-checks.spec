%define name sisiya-server-checks

%define version 0.5.22
%define release 9

%define install_dir /opt/%{name}

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

Summary: The SisIYA server / remote check programs that are run from a central server. This is normally the server where SisIYA daemon runs.
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
Group: System Environment/Daemons
Packager: Erdal Mutlu <emutlu@users.sourceforge.net>
Url: http://sisiya.sourceforge.net
Requires: bash, sisiya-client-checks >= 0.5, bind-utils, curl, expect, ftp, gawk, iputils, net-snmp, net-snmp-utils, samba-client, wget
%description 
Summary: The SisIYA server / remote check programs that are run from a central server. This is normally the server where SisIYA daemon runs.

%prep 
%setup -n %{name}-%{version}-%{release}

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}
make "install_root=%{buildroot}" install_sisiya_server_checks 

%post
# change ownership of some files and directories so that sisiya-webui package can access them in order to change conf files
chgrp    %{www_group}	%{install_dir}
chgrp -R %{www_group}	%{install_dir}/conf

%files
%dir %attr(0755,root,root) 				/etc/cron.d
%attr(0600,root,root) 		%config(noreplace) 	/etc/cron.d/sisiya_db_checks
%attr(0600,root,root) 		%config(noreplace) 	/etc/cron.d/sisiya_remote_checks
#%attr(0644,root,root) 		%doc 			README NEWS ChangeLog AUTHORS INSTALL TODO
%attr(0750,root,root)	 	%dir 			%{install_dir}
#%attr(0750,root,root) 		%dir			%{install_dir}/bin
%attr(0750,root,root)		%dir			%{install_dir}/conf
%attr(0750,root,root) 		%dir			%{install_dir}/lib
%attr(0750,root,root) 		%dir 			%{install_dir}/scripts
%attr(0750,root,root) 		%dir			%{install_dir}/utils
#%attr(0700,root,root)					%{install_dir}/bin/*
%attr(0660,root,root) 		%config(noreplace)	%{install_dir}/conf/class_path
%attr(0660,root,root)		%config(noreplace) 	%{install_dir}/conf/sisiya_server_checks.conf
%attr(0660,root,root)			 		%{install_dir}/conf/sisiya_server_checks_defaults.conf
%attr(0660,root,root)		%config(noreplace) 	%{install_dir}/conf/*.properties
%attr(0660,root,root)		%config(noreplace) 	%{install_dir}/conf/*.xml
%attr(0660,root,root)					%{install_dir}/lib/*.*
%attr(0700,root,root) 					%{install_dir}/scripts/*.*
%attr(0700,root,root) 					%{install_dir}/utils/*.*
