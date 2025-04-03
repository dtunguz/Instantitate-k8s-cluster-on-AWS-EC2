#!/bin/bash
apt install net-tools
hostnamectl set-hostname cp
wget https://cm.lf.training/LFS258/LFS258_V2024-03-14_SOLUTIONS.tar.xz --user=<user> --password=<password>
tar -xvf LFS258_V2024-03-14_SOLUTIONS.tar.xz
apt-get update && apt-get upgrade -y
apt-get install -y vim
apt install curl apt-transport-https vim git wget software-properties-common lsb-release ca-certificates  -y
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
mkdir -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key \
| gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' \
|  tee /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubeadm=1.32.1-1.1 kubelet=1.32.1-1.1 kubectl=1.32.1-1.1
apt-mark hold kubelet kubeadm kubectl
hostname -i
my_var=$(ifconfig enX0 | grep "inet " | awk -F'[: ]+' '{ print $3 }')
cat >> /etc/hosts << EOF
$my_var k8scp
EOF
touch kubeadm-config.yaml
cat >> kubeadm-config.yaml << EOF
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
kubernetesVersion: 1.28.1               
controlPlaneEndpoint: "k8scp:6443"
EOF
kubeadm init --config=kubeadm-config.yaml --upload-certs --ignore-preflight-errors=all | tee kubeadm-init.out
exit
mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
find $HOME -name cilium-cni.yaml
kubectl apply -f LFS258/SOLUTIONS/s_03/cilium-cni.yaml
apt-get install bash-completion -y
source <(kubectl completion bash)
echo "source <(kubectl completion bash)" >> $HOME/.bashrc
sudo systemctl restart kubelet
#after installation if workers are added later
kubeadm token list
kubeadm token create
openssl x509 -pubkey \
-in /etc/kubernetes/pki/ca.crt | openssl rsa \
-pubin -outform der 2>/dev/null | openssl dgst \
-sha256 -hex | sed 's/ˆ.* //'

sudo crictl config --set \
runtime-endpoint=unix:///run/containerd/containerd.sock \
--set image-endpoint=unix:///run/containerd/containerd.sock


