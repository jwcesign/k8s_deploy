#!/bin/bash

ip=""

get_ip(){
	#这里需要改,根据不同电脑的配置用正则提取
	ip='10.211.55.8'
}

preconfig(){
	echo "[Info] Installing docker..."
	yum install -y docker 
	echo "[Info] Start docker..."
	service docker start 
	echo "[Info] Add repo to yum list..."
echo -e "[kubernetes]\n\
name=Kubernetes\n\
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64\n\
enabled=1\n\
gpgcheck=0\n\
repo_gpgcheck=0\n\
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg\n\
http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg" > /etc/yum.repos.d/kubernetes.repo


}

set_firewall(){
	echo "[Info] Close firewalld..."
	systemctl stop firewalld 
	systemctl disable firewalld 
	setenforce 0
	# 关闭swap,k8s 1.8以上的要求
	echo "[Info] Close swap..."
	swapoff -a
}

set_k8s_network(){
echo -e "net.bridge.bridge-nf-call-ip6tables = 1\n\
net.bridge.bridge-nf-call-iptables = 1\n\
net.ipv4.ip_forward = 1" > /etc/sysctl.d/k8s.conf
	modprobe br_netfilter 
	sysctl -p /etc/sysctl.d/k8s.conf 
}

pull_images(){
	echo "[Info] Pull images..."
	docker pull cnych/kube-apiserver-amd64:v1.10.0 
	docker pull cnych/kube-scheduler-amd64:v1.10.0 
	docker pull cnych/kube-controller-manager-amd64:v1.10.0 
	docker pull cnych/kube-proxy-amd64:v1.10.0 
	docker pull cnych/k8s-dns-kube-dns-amd64:1.14.8 
	docker pull cnych/k8s-dns-dnsmasq-nanny-amd64:1.14.8 
	docker pull cnych/k8s-dns-sidecar-amd64:1.14.8 
	docker pull cnych/etcd-amd64:3.1.12 
	docker pull cnych/flannel:v0.10.0-amd64 
	docker pull cnych/pause-amd64:3.1 

	docker tag cnych/kube-apiserver-amd64:v1.10.0 k8s.gcr.io/kube-apiserver-amd64:v1.10.0
	docker tag cnych/kube-scheduler-amd64:v1.10.0 k8s.gcr.io/kube-scheduler-amd64:v1.10.0
	docker tag cnych/kube-controller-manager-amd64:v1.10.0 k8s.gcr.io/kube-controller-manager-amd64:v1.10.0
	docker tag cnych/kube-proxy-amd64:v1.10.0 k8s.gcr.io/kube-proxy-amd64:v1.10.0
	docker tag cnych/k8s-dns-kube-dns-amd64:1.14.8 k8s.gcr.io/k8s-dns-kube-dns-amd64:1.14.8
	docker tag cnych/k8s-dns-dnsmasq-nanny-amd64:1.14.8 k8s.gcr.io/k8s-dns-dnsmasq-nanny-amd64:1.14.8
	docker tag cnych/k8s-dns-sidecar-amd64:1.14.8 k8s.gcr.io/k8s-dns-sidecar-amd64:1.14.8
	docker tag cnych/etcd-amd64:3.1.12 k8s.gcr.io/etcd-amd64:3.1.12
	docker tag cnych/flannel:v0.10.0-amd64 quay.io/coreos/flannel:v0.10.0-amd64
	docker tag cnych/pause-amd64:3.1 k8s.gcr.io/pause-amd64:3.1
}

install_k8s(){
	echo "[Info] install kubernetes 1.10"
	yum makecache fast && yum install -y kubelet-1.10.0-0 kubeadm-1.10.0-0 kubectl-1.10.0-0 
}


create_cluster(){
	systemctl enable kubelet.service
  	systemctl enable docker.service
	echo "[Info] Starting kubernetes service..."
	kubeadm init --kubernetes-version=v1.10.0 --pod-network-cidr=10.244.0.0/16 --apiserver-advertise-address=$ip 
}

set_discovery_method(){
	mkdir -p $HOME/.kube
	sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config 
	sudo chown $(id -u):$(id -g) $HOME/.kube/config
}

config_flannl(){
	echo "[Info] configure flannl..."
	wget https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml 
	kubectl apply -f  kube-flannel.yml 
}

check_init_success(){
	kubectl get nodes
	code=$?
	if [[ $code == 0 ]]; then
		echo "[SUCCESS] The master node is created successfully..."
	else
		echo "[ERROR] Something wrong..."
	fi
}


check_service_exist(){
	kubectl get pods &> /dev/null
	code=$?
	if [[ $code == 0 ]]; then
		exit 1
	fi
}


check_service_exist
get_ip
set_firewall
preconfig
set_k8s_network
pull_images
install_k8s
create_cluster
set_discovery_method
config_flannl
check_init_success
