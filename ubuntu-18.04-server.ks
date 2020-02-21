# Ubuntu server 64bit example kickstart/seed that reboots upon completion
# and runs post install steps to fix console access

# virt-install --name ubuntu --description "Ubuntu" -r 2048 --vcpus=2 --disk path=/dev/hoster/ubuntu-root --virt-type kvm --os-type linux --os-variant ubuntu18.04 --graphics none --network bridge=br1411 --location 'http://ubuntu.mirror.vu.lt/ubuntu/dists/bionic/main/installer-amd64/' --initrd-inject=/tmp/ubuntu.ks --extra-args "ks=file:/ubuntu.ks console=tty0 console=ttyS0,115200n8"

# System language
lang en_US

# Language modules to install
langsupport en_US

# System keyboard
keyboard us

# System mouse
#mouse

# System timezone
timezone Europe/Vilnius

# Root password
rootpw --disabled

# Initial user
user ubuntu --fullname "" --password ubuntu
preseed user-setup/allow-password-weak boolean true

# pick only one of these actions to take after installation completed
reboot
#shutdown
#halt
#poweroff

# Use text mode install
text

# Install OS instead of upgrade
install

# Use http installation media
#url --url http://lt.archive.ubuntu.com/ubuntu
url --url http://ubuntu.mirror.vu.lt/ubuntu

# System bootloader configuration
bootloader --location=mbr

# Clear the Master Boot Record
zerombr yes

# Partition clearing information
clearpart --all --initlabel

# Partition setup
part / --fstype ext4 --size 1 --grow
#part /boot --fstype ext2 --size 200 --asprimary
#part swap  --size 1024
#part pv.01 --size 1 --grow
#volgroup rootvg pv.01
#logvol / --fstype ext4 --vgname=rootvg --size=1 --grow --name=rootvol
#preseed partman-lvm/confirm_nooverwrite boolean true

# If you have swap commented out/not specified then you need to have this line.
preseed --owner partman-basicfilesystems partman-basicfilesystems/no_swap boolean false

# System authorization infomation
auth  --useshadow  --enablemd5

# Firewall configuration
firewall --disabled

# Do not configure the X Window System
skipx

# Make sure to install the acpid package so that virsh commands such
# as virsh shutdown will take effect
# @ is for groups - http://landoflinux.com/linux_kickstart_keywords.html
%packages
@ ubuntu-server
openssh-server
acpid
libpam-systemd
dbus
byobu
vim

# update grub after installation so that we can see the console later
# The new filesystem is under /target. e.g. /root is now /target/root
# and https://help.ubuntu.com/community/KickstartCompatibility
%post --nochroot
(
    sed -i "s;quiet;quiet console=ttyS0;" /target/etc/default/grub
    sed -i "s;quiet;quiet console=ttyS0;g" /target/boot/grub/grub.cfg

) 1> /target/root/post_install.log 2>&1
%end
