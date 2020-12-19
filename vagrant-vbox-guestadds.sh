#!/bin/bash
################################################################################
# Bash script add VirtualBox Guest Additions for vagrant into minimal install of CentOS 7
#
# initial version by:	fernandoaleman
# (add list of bunch of commands to copy & paste -or manually type-)
# https://gist.github.com/fernandoaleman/5083680
#
# derivative by:	clivewalkden
# (change version from centos6 to centos7)
# https://gist.github.com/clivewalkden/b4df0074fc3a84f5bc0a39dc4b344c57
#
# derivative by:	jonasschultzmblox
# (convert to a runnable bash shell script with hardcoded VBox versions)
# https://gist.github.com/jonasschultzmblox/f15fe3c10769d5f269635a54394c84d4
#
# derivative by:	gvnm
# (remove hardcoded versions; on-the-fly obtain latest vbox version & use it)
# https://github.com/gvnm/vagrant-vbox-guestadds
################################################################################
vagrant init centos/7
vagrant up
vagrant ssh -c "sudo yum -y update && sudo reboot"
SLEEP_TIME=15
echo STARTED post-yum-update, sleeping for $SLEEP_TIME seconds to allow the vagrant box to reboot...
sleep $SLEEP_TIME
echo COMPLETED sleeping $SLEEP_TIME seconds. Resuming...

vagrant ssh -c "sudo yum -y install wget kernel-headers kernel-devel gcc make perl"
SLEEP_TIME=5
echo STARTED post-software-installation sleeping for $SLEEP_TIME seconds...
sleep $SLEEP_TIME
echo COMPLETED sleeping $SLEEP_TIME seconds. Resuming...

# Obtain version info from remote repo & use it to download matching (latest) version GuestAdditions (always overwrite)
vagrant ssh -c "sudo \
wget --output-document=/opt/VBoxGuestAdditions_$(curl -s 'http://download.virtualbox.org/virtualbox/LATEST.TXT').iso \
http://download.virtualbox.org/virtualbox/$(curl -s 'http://download.virtualbox.org/virtualbox/LATEST.TXT')/VBoxGuestAdditions_$(curl -s 'http://download.virtualbox.org/virtualbox/LATEST.TXT').iso && \
sudo mount /opt/VBoxGuestAdditions_$(curl -s 'http://download.virtualbox.org/virtualbox/LATEST.TXT').iso -o loop /mnt && \
sudo sh /mnt/VBoxLinuxAdditions.run --nox11 && \
sudo umount /mnt && \
sudo rm /opt/VBoxGuestAdditions_$(curl -s 'http://download.virtualbox.org/virtualbox/LATEST.TXT').iso && \
sudo yum clean all && \
sudo rm -rf /var/cache/yum && \
cat /dev/null > ~/.bash_history"

# Test halt & boot
vagrant halt
SLEEP_TIME=10
echo STARTED post-vagrant-halt sleeping for $SLEEP_TIME seconds...
sleep $SLEEP_TIME
echo COMPLETED sleeping $SLEEP_TIME seconds. Resuming...
#
vagrant up
SLEEP_TIME=10
echo STARTED post-vagrant-up sleeping for $SLEEP_TIME seconds...
sleep $SLEEP_TIME
echo COMPLETED sleeping $SLEEP_TIME seconds. Resuming...

# Halt again and package
vagrant halt
SLEEP_TIME=10
echo STARTED post-vagrant-halt sleeping for $SLEEP_TIME seconds...
sleep $SLEEP_TIME
echo COMPLETED sleeping $SLEEP_TIME seconds. Resuming...
#
vagrant package

# And finally rename & clean up 
mv package.box centos7vb.box
rm Vagrantfile
