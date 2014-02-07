%define name sisiya-client-checks

%define version __VERSION__
%define release __RELEASE__

%define install_dir /usr/share/%{name}

Summary: The SisIYA client checks.
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
Requires: perl
%description 
The SisIYA client programs and checks. This package is installed on every server that is going to be monitored by SisIYA.

%prep 
%setup -n %{name}-%{version}-%{release}

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}
make "DESTDIR=%{buildroot}" install 

%files
%defattr(-,root,root)
%dir %attr(0755,root,root) 				/etc/cron.d
%attr(0600,root,root) 		%config(noreplace) 	/etc/cron.d/sisiya-client-checks
%dir %attr(0755,root,root) 				/etc/sisiya/%{name}
%dir %attr(0755,root,root) 				/etc/sisiya/%{name}/conf.d
%attr(0644,root,root) 		%config(noreplace)	/etc/sisiya/%{name}/conf.d/*
%attr(0644,root,root) 		%config(noreplace) 	/etc/sisiya/%{name}/SisIYA_Config.pm
%attr(0644,root,root) 		%config(noreplace) 	/etc/sisiya/%{name}/SisIYA_Config_local.conf
%attr(0644,root,root) 		%doc 			copyright changelog
%dir %attr(0755,root,root) 				%{install_dir}
%attr(0644,root,root) 					%{install_dir}/version.txt
%dir %attr(0755,root,root) 				%{install_dir}/misc
%dir %attr(0755,root,root) 				%{install_dir}/scripts
%dir %attr(0755,root,root) 				%{install_dir}/utils
%attr(0644,root,root) 					%{install_dir}/misc/*
%attr(0755,root,root) 					%{install_dir}/scripts/*
%attr(0755,root,root) 					%{install_dir}/utils/*
