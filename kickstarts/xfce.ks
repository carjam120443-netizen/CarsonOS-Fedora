%include /usr/share/spin-kickstarts/fedora-live-base.ks

# CarsonOS-Fedora — Xfce edition
lang en_US.UTF-8
keyboard --vckeymap=us --xlayouts='us'
timezone America/Detroit --utc
network --bootproto=dhcp --activate
rootpw --lock
firewall --enabled --service=mdns
selinux --enforcing
services --enabled=NetworkManager,lightdm
bootloader --timeout=5
shutdown

%packages
@xfce-desktop-environment
anaconda
anaconda-live
liveinst
lightdm
lightdm-gtk
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
EDITION="Xfce"
BASE="Fedora Linux"
EOF
systemctl set-default graphical.target
%end
