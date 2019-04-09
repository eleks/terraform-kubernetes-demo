#!/bin/bash

# script used to make basic initialization of all nodes
# when centos image is old at aws, then `yum update` takes quite long time 


TF_HOSTNAME=$1

# let it'll be work directory for provisioning
mkdir /home/centos/provision
chown centos:centos /home/centos/provision

exec &> /home/centos/provision/init-common.log

set -o verbose
set -o errexit
set -o pipefail
set -o nounset

# setenforce returns non zero if already SE Linux is already disabled
is_enforced=$(getenforce)
if [[ $is_enforced != "Disabled" ]]; then
  setenforce 0
  sed -i 's/SELINUX=enforcing/SELINUX=permissive/g' /etc/sysconfig/selinux
fi

# Install Kubernetes components
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
        https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

# Fix certificates file on CentOS
if cat /etc/*release | grep ^NAME= | grep CentOS ; then
    rm -rf /etc/ssl/certs/ca-certificates.crt/
    cp /etc/ssl/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt
fi

yum update -y
# notify success init. 
touch /tmp/signal
echo SUCCESS
