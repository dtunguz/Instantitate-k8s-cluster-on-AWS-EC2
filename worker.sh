#!/bin/bash
apt install net-tools
hostnamectl set-hostname worker1
apt-get update && apt-get upgrade -y
apt install curl apt-transport-https vim git wget \
 software-properties-common lsb-release ca-certificates  -y
swapoff -a
modprobe overlay
modprobe br_netfilter
cat << EOF 
| tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
| sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update &&  apt-get install containerd.io -y
containerd config default | tee /etc/containerd/config.toml
sed -e 's/SystemdCgroup = false/SystemdCgroup = true/g' -i /etc/containerd/config.toml
systemctl restart containerd
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key \
| gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' \
|  tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubeadm=1.28.1-1.1 kubelet=1.28.1-1.1 kubectl=1.28.1-1.1
apt-mark hold kubeadm kubelet kubectl
#change ip address of control plane before this command!!!
cat >> /etc/hosts << EOF
<master_ip_address> k8scp 
EOF

#changing parameters ip address, token, ca-cert-hash and control plane certificate key
kubeadm join <master_ip_address>:6443 --token <token>  --discovery-token-ca-cert-hash sha256:3421bc8ecf7610dee2c3c5c1a819dee3587ac713e0e199474a542ba93c1abcf3 --control-plane --certificate-key 4fe7684f09b4d686d4cf7ae1842f477a73434779b2075bd9ce15fd289160bcc4 --ignore-preflight-errors=all

sudo systemctl restart kubelet


sudo crictl config --set \
runtime-endpoint=unix:///run/containerd/containerd.sock \
--set image-endpoint=unix:///run/containerd/containerd.sock





