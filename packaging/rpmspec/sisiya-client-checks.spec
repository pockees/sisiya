%define name sisiya-client-checks

%define version __VERSION__
%define release __RELEASE__

%define install_dir /opt/%{name}

Summary: The SisIYA client checks.
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
Packager: Erdal Mutlu <erdal@sisiya.org>
Url: http://www.sisiya.org
Requires: bash, perl
%description 
The SisIYA client programs and checks. This package is installed on every server that is going to be monitored by SisIYA.

%prep 
%setup -n %{name}-%{version}-%{release}

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}
make "DESTDIR=%{buildroot}" install_sisiya_client_checks 

%files
%defattr(-,root,root)
%dir %attr(0755,root,root) 				/etc/cron.d
%attr(0600,root,root) 		%config(noreplace) 	/etc/cron.d/sisiya-client-checks
#%attr(0644,root,root) 		%doc 			README NEWS ChangeLog AUTHORS INSTALL TODO
%dir %attr(0755,root,root) 				%{install_dir}
%attr(0644,root,root) 					%{install_dir}/version.txt
%dir %attr(0755,root,root) 				%{install_dir}/misc
%dir %attr(0755,root,root) 				%{install_dir}/common
%dir %attr(0755,root,root) 				%{install_dir}/special
%dir %attr(0755,root,root) 				%{install_dir}/utils
%attr(0644,root,root) 		%config(noreplace) 	%{install_dir}/SisIYA_Config.pm
%attr(0644,root,root) 		%config(noreplace) 	%{install_dir}/SisIYA_Config_local.pl
%attr(0755,root,root) 					%{install_dir}/common/*
%attr(0644,root,root) 					%{install_dir}/misc/*
%attr(0755,root,root) 					%{install_dir}/special/*
%attr(0755,root,root) 					%{install_dir}/utils/*
