%include /usr/share/spin-kickstarts/fedora-live-base.ks

# CarsonOS-Fedora — experimental Hyprland edition
# Hyprland is a Wayland compositor, not a complete desktop environment.
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
hyprland
xdg-desktop-portal
xdg-desktop-portal-hyprland
waybar
wofi
kitty
dunst
polkit-gnome
qt5-qtwayland
qt6-qtwayland
sddm
anaconda
anaconda-live
liveinst
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
EDITION="Hyprland"
BASE="Fedora Linux"
STATUS="Experimental"
EOF
systemctl set-default graphical.target
%end
