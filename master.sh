#!/bin/bash -v

exec 3>&1 4>&2
trap 'exec 2>&4 1>&3' 0 1 2 3
exec 1>startup_log.out 2>&1

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

cat << EOF | tee /etc/apt/sources.list.d/kubernetes.list
deb https://apt.kubernetes.io/ kubernetes-xenial main
EOF

apt-get update
apt-get install -y docker-ce
apt-mark hold docker-ce
apt-get install -y kubelet kubeadm kubectl kubernetes-cni
apt-mark hold kubelet kubeadm kubectl

kubeadm init --token=${k8stoken} --pod-network-cidr=10.244.0.0/16

mkdir -p /home/ubuntu/.kube
cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
chown -R $(id -u ubuntu):$(id -g ubuntu) /home/ubuntu/.kube/

usermod -aG docker ubuntu

echo "net.bridge.bridge-nf-call-iptables=1" | tee -a /etc/sysctl.conf
sysctl -p
sleep 60
runuser -l ubuntu -c '\
   kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml
'

# runuser -l ubuntu -c '\
#    kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml && \
#    git clone https://github.com/alecashford/kube_tests.git /home/ubuntu/kube_tests && \
#    kubectl apply -f kube_tests/personal_site.yaml
# '

# cd /home/ubuntu
# git clone https://github.com/alecashford/kube_tests.git /home/ubuntu

# runuser -l ubuntu -c 'kubectl apply -f kube_tests/personal_site.yaml'
