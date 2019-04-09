#!/bin/bash

set -o verbose
set -o errexit
set -o pipefail

export TF_HOSTNAME=${tf_hostname}
export TF_KUBEADM_TOKEN=${tf_kubeadm_token}
export TF_MASTER_HOST=${tf_master_host}

export KUBERNETES_VERSION="1.14.0"

# Set this only after setting the defaults
set -o nounset

sudo hostnamectl set-hostname --static $TF_HOSTNAME

# Install docker
sudo yum install -y docker kubelet-$KUBERNETES_VERSION kubeadm-$KUBERNETES_VERSION

# Fix kubelet configuration
sudo sed -i 's/--cgroup-driver=systemd/--cgroup-driver=cgroupfs/g' /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo sed -i '/Environment="KUBELET_CGROUP_ARGS/i Environment="KUBELET_CLOUD_ARGS=--cloud-provider=aws"' /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo sed -i 's/$KUBELET_CGROUP_ARGS/$KUBELET_CLOUD_ARGS $KUBELET_CGROUP_ARGS/g' /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf

# start services
sudo systemctl enable docker
sudo systemctl start docker
sudo systemctl enable kubelet
sudo systemctl start kubelet

# net settings needed by docker
sudo touch /etc/sysctl.d/k8s.conf
sudo chown centos:centos /etc/sysctl.d/k8s.conf

cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl net.bridge.bridge-nf-call-iptables=1
sudo sysctl net.bridge.bridge-nf-call-ip6tables=1

sudo sysctl --system


sudo kubeadm reset --force
sudo kubeadm join $TF_MASTER_HOST:6443 --token $TF_KUBEADM_TOKEN --discovery-token-unsafe-skip-ca-verification
