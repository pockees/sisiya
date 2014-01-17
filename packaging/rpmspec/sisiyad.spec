%define name sisiyad

%define version __VERSION__
%define release __RELEASE__

Summary: SisIYA daemon.
Name: %{name}
Version: %{version}
Release: %{release}
Source0: %{name}-%{version}-%{release}.tar.gz
#Source1: http://download.sourceforge.net/sisiya/%{name}-%{version}-%{release}.tar.gz
License: GPL
Vendor: Erdal Mutlu
Group: System Environment/Daemons
Packager: Erdal Mutlu <erdal@sisiya.org>
Url: http://www.sisiya.org
BuildRoot:%{_tmppath}/%{name}-%{version}-%{release}-root

%description
The SisIYA daemon is a program which receives incomming SisIYA messages and records them
in a database system.

%prep 
%setup -n %{name}-%{version}-%{release}

%build
cd edbc/lib && ./bootstrap create && ./configure && make && cd ../../
cd %{name}  && ./bootstrap create && ./configure && make && cd ..

%install
rm -rf %{buildroot}
mkdir -p %{buildroot}
cd %{name} && make "DSTDIR=%{buildroot}" install 

%post
### if update, then restart
if test $1 -eq 2 ; then
	service sisiyad restart > /dev/null 
	exit 0
fi
chkconfig --add sisiyad
service sisiyad start > /dev/null 

%preun 
### if update
if test $1 -eq 1 ; then
	exit 0
fi
service sisiyad stop > /dev/null 2>&1
chkconfig --del sisiyad

%clean 
rm -rf %{buildroot}

%files
%defattr(-,root,root)
#%attr(0644,root,root) 	%doc 			AUTHORS ChangeLog NEWS README
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
