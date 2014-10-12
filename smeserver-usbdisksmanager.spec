# $Id: smeserver-usbdisksmanager.spec,v 1.3 2013/07/15 00:14:27 unnilennium Exp $
# Authority: unnilennium
# Name: Jean-Philippe Pialasse 

Summary: smeserver-usbdisksmanager
%define name smeserver-usbdisksmanager

# Variable representing installation directories:
%define installdir_usbdisksmanager /etc/e-smith/web/functions
%define installdir_usbdisks_sh /usr/sbin

Name: %{name}
%define version 1.0
%define release 3 
Version: %{version}
Release: %{release}%{?dist}
License: GNU GPL version 2
Group: SMEserver/addon
Source: %{name}-%{version}.tgz
BuildRoot: /var/tmp/e-smith-buildroot
BuildRequires: e-smith-devtools >= 1.13.1-03
BuildArchitectures: noarch
Requires: smeserver-release >= 8.0
AutoReqProv: no

%changelog
* Sun Jul 14 2013 JP Pialasse <tests@pialasse.com> 1.0-3.sme
- apply locale 2013-07-14 patch
* Tue Jun 26 2012 JP PIALASSE tests@pialasse.com 1.0-2.sme
- manager interface display fix [SME 6989]
- blkid cache removed for manager listing [SME 6990]
- Apply local 2012-06-26
* Sat Jun 16 2012 JP PIALASSE tests@pialasse.com  1.0-1.sme
- Initial version

%description
Web interface to manage removable hard drive, and auto mount to a point script

%prep
%setup

%install

/bin/rm -rf $RPM_BUILD_ROOT
(cd root   ; /usr/bin/find . -depth -print | /bin/cpio -dump $RPM_BUILD_ROOT)
/bin/rm -f %{name}-%{version}-filelist
/sbin/e-smith/genfilelist $RPM_BUILD_ROOT > %{name}-%{version}-filelist

%files -f %{name}-%{version}-filelist
%defattr(750,root,root)
%{installdir_usbdisks_sh}/usbdisks.sh
%defattr(4750,root,admin)
%{installdir_usbdisksmanager}/usbdisks

%clean
rm -rf $RPM_BUILD_ROOT

