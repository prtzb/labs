#!/bin/bash

swapoff -a

modprobe overlay
modprobe br_netfilter

cat <<EOF | tee /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

cat <<EOF | tee /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sysctl --system

#apt-get update 
apt-get install -y containerd

#Configure containerd
mkdir -p /etc/containerd
cp containerd-config.toml /etc/containerd/config.toml


curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

#Add the Kubernetes apt repository
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF


#Update the package list 
apt-get update
VERSION=1.20.1-00
apt-get install -y kubelet=$VERSION kubeadm=$VERSION kubectl=$VERSION
apt-mark hold kubelet kubeadm kubectl containerd

systemctl enable kubelet.service
systemctl enable containerd.service

# Run on control plane:
# kubeadm token create --print-join-command

# Run on Nodes:
# kubeadm join $IP:$PORT --token $TOKEN --discovery-token-ca-cert-hash sha256:$CERT_HASH


