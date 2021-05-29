#!/bin/bash

wget https://docs.projectcalico.org/manifests/calico.yaml

kubeadm config print init-defaults | tee ClusterConfiguration.yaml


#Change the address of the localAPIEndpoint.advertiseAddress to the Control Plane Node's IP address
MY_IP=$(ip addr | grep inet | grep eth0 | awk '{print $2}' | cut -d '/' -f 1)
sed -i "s/  advertiseAddress: 1.2.3.4/  advertiseAddress: $MY_IP/" ClusterConfiguration.yaml


#Set the CRI Socket to point to containerd
sed -i 's/  criSocket: \/var\/run\/dockershim\.sock/  criSocket: \/run\/containerd\/containerd\.sock/' ClusterConfiguration.yaml


#Set the cgroupDriver to systemd...matching that of your container runtime, containerd
cat <<EOF | cat >> ClusterConfiguration.yaml
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd
EOF

kubeadm init \
	--config=ClusterConfiguration.yaml \
    --cri-socket /run/containerd/containerd.sock

#Configure our account on the Control Plane Node to have admin access to the API server from a non-privileged account.
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config


#1 - Creating a Pod Network
#Deploy yaml file for your pod network.
kubectl apply -f calico.yaml