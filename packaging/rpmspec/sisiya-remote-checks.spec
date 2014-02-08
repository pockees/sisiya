%define name sisiya-remote-checks

%define version __VERSION__
%define release __RELEASE__

%define install_dir /usr/share/%{name}

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

Summary: The SisIYA remote check programs that are run from a central server. 
Name:%{name} 
BuildArch: noarch
BuildRoot: %{_builddir}/%{name}-root
Version: %{version}
Release: %{release}
#Obsoletes: $version-$release
Source0: http://sourceforge.net/projects/sisiya/files/sisiya/%{version}/rpm/%{name}-%{version}-%{release}.tar.gz
License: GPL
Vendor: Erdal Mutlu
Group: System Environment/Daemons
Packager: Erdal Mutlu <erdal@sisiya.org>
Url: http://www.sisiya.org
Requires: bash, bind-utils, curl, ftp, iputils, net-snmp, net-snmp-utils, perl, perl-XML-Simple, samba-client, sisiya-client-checks
%description 
Summary: The SisIYA server / remote check programs that are run from a central server. This is normally the server where SisIYA daemon runs.

%prep 
%setup -n %{name}-%{version}-%{release}

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}
make "DESTDIR=%{buildroot}" install

%post
# change ownership of some files and directories so that sisiya-webui package can access them in order to change conf files
chgrp    %{www_group}	/etc/sisiya/sisiya-remote-checks
chgrp -R %{www_group}	/etc/sisiya/sisiya-remote-checks/conf.d

%files
%dir %attr(0755,root,root) 				/etc/cron.d
#%attr(0600,root,root) 		%config(noreplace) 	/etc/cron.d/sisiya_db_checks
%attr(0600,root,root) 		%config(noreplace) 	/etc/cron.d/sisiya-remote-checks
%attr(0750,root,root)	 	%dir 			%{install_dir}
%attr(0755,root,root) 		%dir			/etc/sisiya/%{name}/conf.d
%attr(0644,root,root) 		%config(noreplace)	/etc/sisiya/%{name}/conf.d/*
%attr(0644,root,root) 		%config(noreplace) 	/etc/sisiya/%{name}/SisIYA_Remote_Config.pm
%attr(0644,root,root) 		%config(noreplace) 	/etc/sisiya/%{name}/SisIYA_Remote_Config_local.conf
%attr(0750,root,root) 		%dir 			%{install_dir}/lib
%attr(0750,root,root)		%dir			%{install_dir}/misc
%attr(0750,root,root) 		%dir 			%{install_dir}/scripts
%attr(0750,root,root) 		%dir 			%{install_dir}/src
%attr(0750,root,root) 		%dir			%{install_dir}/utils
%attr(0660,root,root)		%config(noreplace) 	%{install_dir}/conf/*.properties
%attr(0660,root,root)		%config(noreplace) 	%{install_dir}/conf/*.example
%attr(0660,root,root)		%config(noreplace) 	%{install_dir}/conf/*.xml
%attr(0600,root,root) 					%{install_dir}/lib/*.*
%attr(0700,root,root) 					%{install_dir}/misc/*.*
%attr(0700,root,root) 					%{install_dir}/scripts/*.*
%attr(0600,root,root) 					%{install_dir}/src/*.*
%attr(0700,root,root) 					%{install_dir}/utils/*.*
%attr(0644,root,root) 		 			/usr/share/doc/%{name}/changelog
%attr(0644,root,root) 		 			/usr/share/doc/%{name}/copyright
%attr(0644,root,root) 		 			/usr/share/doc/%{name}/version.txt
