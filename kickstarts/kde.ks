%include /usr/share/spin-kickstarts/fedora-live-base.ks

# CarsonOS-Fedora — KDE Plasma edition
lang en_US.UTF-8
keyboard --vckeymap=us --xlayouts='us'
timezone America/Detroit --utc
network --bootproto=dhcp --activate
rootpw --lock
firewall --enabled --service=mdns
selinux --enforcing
services --enabled=NetworkManager,sddm
bootloader --timeout=5
shutdown

%packages
@kde-desktop-environment
anaconda
anaconda-live
liveinst
sddm
firefox
fastfetch
git
nano
vim-minimal
dnf5
NetworkManager-wifi
isomd5sum
%end

%post
mkdir -p /etc/carsonos
cat > /etc/carsonos-release <<'EOF'
NAME="CarsonOS-Fedora"
EDITION="KDE Plasma"
BASE="Fedora Linux"
EOF
systemctl set-default graphical.target
%end
