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


Summary: SisIYA client programs and checks
Name: sisiya-client-checks
%define install_dir /usr/share/%{name}
BuildArch: noarch
BuildRoot: %{_builddir}/%{name}-root
Version: __VERSION__
Release: 0
#Obsoletes: $version-$release
Source0: http://sourceforge.net/projects/sisiya/files/sisiya/%{version}/rpm/%{name}-%{version}.tar.gz
License: GPL
Vendor: Erdal Mutlu
Group: System Environment/Daemons
Packager: Erdal Mutlu <erdal@sisiya.org>
Url: http://www.sisiya.org
Requires: perl, sysstat
%description 
The SisIYA client programs and checks. This package is installed on every server that is going to be monitored by SisIYA.

%prep 
%setup -n %{name}-%{version}

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}
make "DESTDIR=%{buildroot}" install 

%files
%defattr(-,root,root)
%attr(0755,root,root) 		%dir			/etc/cron.d
%attr(0600,root,root) 		%config(noreplace) 	/etc/cron.d/%{name}
%attr(0755,root,root) 		%dir			/etc/sisiya
%attr(0755,root,root) 		%dir			/etc/sisiya/%{name}
%attr(0755,root,root) 		%dir			/etc/sisiya/%{name}/conf.d
%attr(0644,root,root) 		%config(noreplace)	/etc/sisiya/%{name}/conf.d/*
%attr(0644,root,root) 		%config(noreplace) 	/etc/sisiya/%{name}/SisIYA_Config.pm
%attr(0644,root,root) 		%config(noreplace) 	/etc/sisiya/%{name}/SisIYA_Config_local.conf
%attr(0755,root,root) 		%dir			%{install_dir}
%attr(0755,root,root) 		%dir			%{install_dir}/misc
%attr(0755,root,root) 		%dir			%{install_dir}/scripts
%attr(0755,root,root) 		%dir			%{install_dir}/utils
%attr(0644,root,root) 					%{install_dir}/misc/*
%attr(0755,root,root) 					%{install_dir}/scripts/*
%attr(0755,root,root) 					%{install_dir}/utils/*
%attr(0755,root,root) 		%dir			/usr/share/doc/%{name}
%attr(0644,root,root) 		 			/usr/share/doc/%{name}/*
