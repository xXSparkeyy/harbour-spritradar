# 
# Do NOT Edit the Auto-generated Part!
# Generated by: spectacle version 0.32
# 

Name:       harbour-spritradar

# >> macros
# << macros

%{!?qtc_qmake:%define qtc_qmake %qmake}
%{!?qtc_qmake5:%define qtc_qmake5 %qmake5}
%{!?qtc_make:%define qtc_make make}
%{?qtc_builddir:%define _builddir %qtc_builddir}
Summary:    A Gas price comparison app
Version:    0.2.0
Release:    1
Group:      Qt/Qt
License:    MIT
URL:        https://github.com/poetaster/SailGo
Source0:    %{name}-%{version}.tar.bz2
Requires:   sailfishsilica-qt5 >= 0.10.9
BuildRequires:  pkgconfig(sailfishapp) >= 1.0.2
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  desktop-file-utils
BuildRequires:  qt5-qttools-linguist

%description
A Gas price comparison App. Based on https://github.com/xXSparkeyy/harbour-spritradar

%if "%{?vendor}" == "chum"
PackageName: Spritradar
Type: desktop-application
Categories:
 - Uitility
DeveloperName: Mark Washeim (poetaster)
Custom:
 - Repo: https://github.com/poetaster/harbour-spritradar
Icon: https://raw.githubusercontent.com/poetaster/harbour-spritradar/master/icons/172x172/harbour-spritradar.png
Screenshots:
 - https://raw.githubusercontent.com/poetaster/harbour-spritradar/master/Screenshot_1.png
 - https://raw.githubusercontent.com/poetaster/harbour-spritradar/master/Screenshot_2.png
 - https://raw.githubusercontent.com/poetaster/harbour-spritradar/master/Screenshot_3.png
Url:
  Donation: https://www.paypal.me/poetasterFOSS
%endif

%prep
%setup -q -n %{name}-%{version}

# >> setup
# << setup

%build
# >> build pre
# << build pre

%qtc_qmake5 

%qtc_make %{?_smp_mflags}

# >> build post
# << build post

%install
rm -rf %{buildroot}
# >> install pre
# << install pre
%qmake5_install

# >> install post
# << install post

desktop-file-install --delete-original       \
  --dir %{buildroot}%{_datadir}/applications             \
   %{buildroot}%{_datadir}/applications/*.desktop

%files
%defattr(-,root,root,-)
%{_bindir}
%{_datadir}/%{name}
%{_datadir}/applications/%{name}.desktop
%{_datadir}/icons/hicolor/*/apps/%{name}.png
# >> files
# << files
