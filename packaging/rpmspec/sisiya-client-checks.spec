%define name sisiya-client-checks

%define version 0.5.31
%define release 2

%define install_dir /opt/%{name}

Summary: The SisIYA client programs and checks.
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
Requires: bash, gawk, perl, bc 
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
%attr(0600,root,root) 		%config(noreplace) 	/etc/cron.d/sisiya_client_checks
#%attr(0644,root,root) 		%doc 			README NEWS ChangeLog AUTHORS INSTALL TODO
%dir %attr(0755,root,root) 				%{install_dir}
%attr(0644,root,root) 					%{install_dir}/version.txt
%dir %attr(0755,root,root) 				%{install_dir}/bin
%dir %attr(0755,root,root) 				%{install_dir}/common
%dir %attr(0755,root,root) 				%{install_dir}/special
%attr(0644,root,root) 		%config(noreplace) 	%{install_dir}/sisiya_client.conf
%attr(0755,root,root) 					%{install_dir}/bin/*.sh
%attr(0755,root,root) 					%{install_dir}/bin/*.pl
%attr(0755,root,root) 					%{install_dir}/common/sisiya_*.sh
%attr(0755,root,root) 					%{install_dir}/special/sisiya_*.sh
