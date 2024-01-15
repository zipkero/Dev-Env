# 마스터 노드 모두
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.29/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.29/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# 마스터만
OUTPUT_FILE=/vagrant/join.sh && \
rm -rf $OUTPUT_FILE && \
rm -rf /vagrant/.kube && \
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --control-plane-endpoint=192.168.56.10 --apiserver-advertise-address=192.168.56.10 && \
sudo kubeadm token create --print-join-command > $OUTPUT_FILE && \
chmod +x $OUTPUT_FILE 

sudo chown -R vagrant:vagrant /home/vagrant/.kube
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml
kubectl completion bash >/etc/bash_completion.d/kubectl
echo 'alias k=kubectl' >>/home/vagrant/.bashrc