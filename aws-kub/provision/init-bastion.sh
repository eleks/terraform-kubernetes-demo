#!/bin/bash

#exec 3>&1 1>>/var/log/cloud-init-instance.log 2>&1

set -o verbose
set -o errexit
set -o pipefail

export TF_HOSTNAME=${tf_hostname}

export KUBERNETES_VERSION="1.14.0"

# Set this only after setting the defaults
set -o nounset

sudo hostnamectl set-hostname --static $TF_HOSTNAME

sudo chmod 0600 /home/centos/.ssh/id_rsa
sudo chown centos:centos /home/centos/.ssh/id_rsa

sudo yum install -y nfs-utils unzip kubectl-$KUBERNETES_VERSION

# make nfs available on bastion
# useful for demos and not only...
sudo systemctl enable nfs-server.service 
sudo systemctl start nfs-server.service
sudo chmod 646 /etc/exports
sudo mkdir /var/nfs
sudo chown centos:adm /var/nfs
sudo chmod 775 /var/nfs
sudo echo '/var/nfs        *(rw,sync,no_subtree_check)' >> /etc/exports
sudo exportfs -a
mkdir -p /var/nfs/persistent

chmod +x /home/centos/provision/kub.sh
sudo ln -s /home/centos/provision/kub.sh /usr/bin/kub
