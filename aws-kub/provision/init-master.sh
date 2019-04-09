#!/bin/bash

set -o verbose
set -o errexit
set -o pipefail

export TF_HOSTNAME=${tf_hostname}
export TF_KUBEADM_TOKEN=${tf_kubeadm_token}
export TF_KUBEADM_HOST=${tf_kubeadm_host}
export TF_MASTER_IP=${tf_master_ip}

export KUBERNETES_VERSION="1.14.0"

# Set this only after setting the defaults
set -o nounset

sudo hostnamectl set-hostname --static $TF_HOSTNAME

# Install docker
sudo yum install -y docker
sudo yum install -y kubelet-$KUBERNETES_VERSION kubeadm-$KUBERNETES_VERSION kubectl-$KUBERNETES_VERSION


# Fix kubelet configuration
sudo sed -i 's/--cgroup-driver=systemd/--cgroup-driver=cgroupfs/g' /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo sed -i '/Environment="KUBELET_CGROUP_ARGS/i Environment="KUBELET_CLOUD_ARGS=--cloud-provider=aws"' /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf
sudo sed -i 's/$KUBELET_CGROUP_ARGS/$KUBELET_CLOUD_ARGS $KUBELET_CGROUP_ARGS/g' /usr/lib/systemd/system/kubelet.service.d/10-kubeadm.conf

# Fix certificates file on CentOS
if cat /etc/*release | grep ^NAME= | grep CentOS ; then
    sudo rm -rf /etc/ssl/certs/ca-certificates.crt/
    sudo cp /etc/ssl/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt
fi

# Start services
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


# Pull kubernetes system images
sudo kubeadm config images pull

sudo kubeadm reset --force

sudo kubeadm init \
  --pod-network-cidr=10.244.0.0/16 \
  --apiserver-advertise-address=$TF_MASTER_IP \
  --apiserver-cert-extra-sans=$TF_KUBEADM_HOST \
  --apiserver-cert-extra-sans=$TF_MASTER_IP \
  --token=$TF_KUBEADM_TOKEN \
  --token-ttl=0

# Use the local kubectl config for further kubectl operations
# export KUBECONFIG=/etc/kubernetes/admin.conf
mkdir -p /home/centos/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/centos/.kube/config
sudo chown centos:centos /home/centos/.kube/config

# add file-based auth for kubeapi
sudo cp -f /home/centos/provision/auth.csv /etc/kubernetes/pki/auth.csv
sudo sed -i '/- kube-apiserver/a \    - --token-auth-file=/etc/kubernetes/pki/auth.csv' /etc/kubernetes/manifests/kube-apiserver.yaml
#rm -f /home/centos/provision/auth.csv

# wait for port 6443 open
sudo yum install -y nc
while ! nc -z localhost 6443 </dev/null; do sleep 10; done
# just in case :)
sleep 15


# install flannel network
kubectl apply -f /home/centos/provision/flannel.yaml
#rm -f /home/centos/provision/flannel.yaml

# rbac
kubectl apply -f /home/centos/provision/rbac.yaml
#rm -f /home/centos/provision/rbac.yaml

# dashboard + security
kubectl create -f /home/centos/provision/dashboard.yaml
sleep 15
# kubectl delete sa kubernetes-dashboard -n kube-system
kubectl create -f /home/centos/provision/dashboard-secure.yaml

# restart kubelet
sudo systemctl restart kubelet


