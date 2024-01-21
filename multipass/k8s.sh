# multipass launch --name master --cpus 2 --memory 4G --disk 20G
# multipass launch --name worker1 --cpus 2 --memory 2G --disk 20G
# multipass launch --name worker2 --cpus 2 --memory 2G --disk 20G


# 마스터
swapoff -a
sudo sed -i '/swap/ s/^/#/' /etc/fstab

cat <<-'EOF' | sudo tee /etc/modules-load.d/kubernetes.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<-'EOF' | sudo tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

#echo "192.168.56.10 master" | sudo tee -a /etc/hosts
#for (( i=1; i<=2; i++ )); do 
#  echo "192.168.56.1$i worker$i" | sudo tee -a /etc/hosts
#done

sudo sysctl --system

sudo apt update
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt update
sudo apt install -y containerd.io

containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd

#cat <<-'EOF' | sudo tee /etc/default/kubelet
#KUBELET_EXTRA_ARGS=--node-ip=192.168.56.10
#EOF

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo kubeadm init --pod-network-cidr=192.168.0.0/16

mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml
kubectl completion bash >/etc/bash_completion.d/kubectl
echo 'alias k=kubectl' | sudo tee -a $HOME/.bashrc



# 워커노드
swapoff -a
sudo sed -i '/swap/ s/^/#/' /etc/fstab

cat <<-'EOF' | sudo tee /etc/modules-load.d/kubernetes.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<-'EOF' | sudo tee /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF

#echo "192.168.56.10 master" | sudo tee -a /etc/hosts
#for (( i=1; i<=$1; i++ )); do
#  echo "192.168.56.1$i worker$i" | sudo tee -a /etc/hosts
#done

#echo "KUBELET_EXTRA_ARGS=--node-ip=192.168.56.#{10 + i}" | sudo tee /etc/default/kubelet

sudo sysctl --system

sudo apt update
sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates

sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt update
sudo apt install -y containerd.io

containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

sudo systemctl restart containerd
sudo systemctl enable containerd

echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl




# sudo kubeadm join 172.21.109.9:6443 --token js4y3w.40r81ozfwlztg5zv --discovery-token-ca-cert-hash sha256:be9b6cdfb3350025f57fdc5dda0af3307c6bca53f4e22c598d0b1281e5aa28c4