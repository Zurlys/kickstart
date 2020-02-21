# Ubuntu server 64bit example kickstart/seed that reboots upon completion
# and runs post install steps to fix console access

# virt-install --name ubuntu --description "Ubuntu" -r 2048 --vcpus=1 --disk path=/dev/hoster/ubuntu-root --virt-type kvm --os-type linux --os-variant ubuntu18.04 --graphics none --network bridge=br1411 --location 'http://ubuntu.mirror.vu.lt/ubuntu/dists/bionic/main/installer-amd64/' --initrd-inject=/tmp/ubuntu.ks --extra-args "ks=file:/ubuntu.ks console=tty0 console=ttyS0,115200n8"

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
# python -c 'import crypt,getpass;pw=getpass.getpass();print(crypt.crypt(pw) if (pw==getpass.getpass("Confirm: ")) else exit())'
user ubuntu --fullname "" --iscrypted --password=$6$tA/MV4ZksW2IX61P$tLdsSlenEjndM0E0dwe/tNJ27W9uBUcXZmWvFWwnsbuZddK.iNaUXXOqUugfxSp6U/olW4nhtmQMjLTfjDtTq0
#user ubuntu --fullname "" --password ubuntu
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
url --url http://lt.archive.ubuntu.com/ubuntu
#url --url http://mirror.vpsnet.com/ubuntu
#url --url http://ubuntu.mirror.vu.lt/ubuntu

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
bash-completion

# update grub after installation so that we can see the console later
# The new filesystem is under /target. e.g. /root is now /target/root
# and https://help.ubuntu.com/community/KickstartCompatibility
#%post --nochroot
#(
#    sed -i "s;quiet;quiet console=ttyS0;" /target/etc/default/grub
#    sed -i "s;quiet;quiet console=ttyS0;g" /target/boot/grub/grub.cfg
#
#) 1> /target/root/post_install.log 2>&1

%post

locale-gen en_US.UTF-8
update-locale LANG="en_US.UTF-8"
echo 'LANG=en_US.UTF-8' >> /etc/environment
echo 'LC_ALL=en_US.UTF-8' >> /etc/environment

apt-get autoremove -y

sed -i "s;quiet;quiet console=ttyS0;" /etc/default/grub
sed -i "s;quiet;quiet console=ttyS0;g" /boot/grub/grub.cfg
update-grub

mkdir -p -m0700 /root/.ssh/
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDn3ZwMou6btQ823s8zP3hehpZhoK3JBefP5qiOHATdJulXjbEaaPSrAtpA1brrlWbmV/ckRzeZ/M7Fg1lBjFSHdMupMfSV73B8YRSnkMwQlvsNyWxTGQTEikLEnH7oO+GAdEpUjMS8W2YvctU1GZd8NxZtpqAxhXWqqFEIT6MEjncqZi0deSAR9T1Jc/RY6l01xcO/frZgKD9T2dK1uR7MExJYDZQY8XPd01kBUHKEaWGsr9yQDLNCEdxDVYgg1elAxmzKltuMtunPzaHzfoQNkCEGn7/Sk7caJglgxVU/TVlqJVztRgcfmpCEENI3I24qDrFdxbaZqqc3QN3HE4PX4mHaeZW7Vtjj7JbhGPOvyum4ZNakf9BPzNQOuOFF/RakRuTDHgnh+0BqMmzI/X/rwpta+mEcCCyhh0OeDMxkgErtBARJxWrnQTnJVzpdEO+TmvWU7BPEw2kk5XRVDvNUGwPuf0fO0GMqZyDcf3OMC9nzWrVXZWQeZqotFz0kL08s54hm+FOWmdBzJ/uRsnkqKBhrF89CJbwKFPRdmrDdczxvQjw+K23aSG3Ww/4912/Ifj3L2GDOahnfmG8OJO6AItjr6mIsoaS4BrAKp8Ml3SJ9J8bhg/239xubh7oqflOCmphehxr4FWlChhuJenoLp0X/QFIuYW5gbKR4Eb2t4w== mantas@mba' > /root/.ssh/authorized_keys
chmod 0600 /root/.ssh/authorized_keys

echo 'ubuntu ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/users

%end
