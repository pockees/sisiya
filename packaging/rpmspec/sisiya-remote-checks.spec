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
#    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

%define www_user  apache
%define www_group apache

%if %is_suse
%define www_user  wwwrun
%define www_group www
%endif

Name: sisiya-remote-checks
Summary: SisIYA remote check programs that are run from a central server 
Url: http://www.sisiya.org
%define install_dir /usr/share/%{name}
Version: __VERSION__
Release: 0
BuildArch: noarch
BuildRoot: %{_builddir}/%{name}-root
Source0: http://sourceforge.net/projects/sisiya/files/sisiya/%{version}/rpm/%{name}-%{version}.tar.gz
License: GPL-2.0+
Vendor: Erdal Mutlu
Group: System Environment/Daemons
Packager: Erdal Mutlu <erdal@sisiya.org>
Requires: bash, bind-utils, curl, ftp, iputils, net-snmp, net-snmp-utils, perl, perl-XML-Simple, samba-client, sisiya-client-checks
%description 
Summary: The SisIYA server / remote check programs that are run from a central server. This is normally the server where SisIYA daemon runs.

%prep 
%setup -n %{name}-%{version}

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}
make "DESTDIR=%{buildroot}" install

%post
# change ownership of some files and directories so that sisiya-webui package can access them in order to change conf files
chgrp    %{www_group}	/etc/sisiya/sisiya-remote-checks
chgrp -R %{www_group}	/etc/sisiya/sisiya-remote-checks/conf.d

%files
%attr(0755,root,root)		%dir			/etc/cron.d
%attr(0755,root,root)		%dir			/etc/sisiya
%attr(0755,root,root) 		%dir			/etc/sisiya/%{name}
%attr(0755,root,root) 		%dir			/etc/sisiya/%{name}/conf.d
%attr(0750,root,root)	 	%dir 			%{install_dir}
%attr(0750,root,root) 		%dir 			%{install_dir}/lib
%attr(0750,root,root)		%dir			%{install_dir}/misc
%attr(0750,root,root) 		%dir 			%{install_dir}/scripts
%attr(0750,root,root) 		%dir 			%{install_dir}/src
%attr(0750,root,root) 		%dir			%{install_dir}/utils
%attr(0755,root,root)		%dir 			/usr/share/doc/%{name}
#%attr(0600,root,root) 		%config(noreplace) 	/etc/cron.d/sisiya_db_checks
%attr(0600,root,root) 		%config(noreplace) 	/etc/cron.d/sisiya-remote-checks
%attr(0664,root,root) 		%config(noreplace)	/etc/sisiya/%{name}/conf.d/*
%attr(0644,root,root) 		%config(noreplace) 	/etc/sisiya/%{name}/SisIYA_Remote_Config.pm
%attr(0644,root,root) 		%config(noreplace) 	/etc/sisiya/%{name}/SisIYA_Remote_Config_local.conf
%attr(0600,root,root) 					%{install_dir}/lib/*.*
%attr(0700,root,root) 					%{install_dir}/misc/*.*
%attr(0700,root,root) 					%{install_dir}/scripts/*.*
%attr(0600,root,root) 					%{install_dir}/src/*.*
%attr(0700,root,root) 					%{install_dir}/utils/*.*
%attr(0644,root,root) 		 			/usr/share/doc/%{name}/*
