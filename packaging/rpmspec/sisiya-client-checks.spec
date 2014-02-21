%define name sisiya-client-checks

%define install_dir /usr/share/%{name}

Summary: SisIYA client programs and checks
Name:%{name} 
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
%dir %attr(0755,root,root) 				/etc/cron.d
%attr(0600,root,root) 		%config(noreplace) 	/etc/cron.d/%{name}
%dir %attr(0755,root,root) 				/etc/sisiya
%dir %attr(0755,root,root) 				/etc/sisiya/%{name}
%dir %attr(0755,root,root) 				/etc/sisiya/%{name}/conf.d
%attr(0644,root,root) 		%config(noreplace)	/etc/sisiya/%{name}/conf.d/*
%attr(0644,root,root) 		%config(noreplace) 	/etc/sisiya/%{name}/SisIYA_Config.pm
%attr(0644,root,root) 		%config(noreplace) 	/etc/sisiya/%{name}/SisIYA_Config_local.conf
%dir %attr(0755,root,root) 				%{install_dir}
%dir %attr(0755,root,root) 				%{install_dir}/misc
%dir %attr(0755,root,root) 				%{install_dir}/scripts
%dir %attr(0755,root,root) 				%{install_dir}/utils
%attr(0644,root,root) 					%{install_dir}/misc/*
%attr(0755,root,root) 					%{install_dir}/scripts/*
%attr(0755,root,root) 					%{install_dir}/utils/*
%dir %attr(0755,root,root) 				/usr/share/doc/%{name}
%attr(0644,root,root) 		 			/usr/share/doc/%{name}/*
