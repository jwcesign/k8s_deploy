#!/bin/bash

preconfig(){
	echo "[Info] Update..."
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
	docker pull cnych/kube-proxy-amd64:v1.10.0
	docker pull cnych/flannel:v0.10.0-amd64
	docker pull cnych/pause-amd64:3.1
	docker pull cnych/kubernetes-dashboard-amd64:v1.8.3
	docker pull cnych/heapster-influxdb-amd64:v1.3.3
	docker pull cnych/heapster-grafana-amd64:v4.4.3
	docker pull cnych/heapster-amd64:v1.4.2

	docker tag cnych/flannel:v0.10.0-amd64 quay.io/coreos/flannel:v0.10.0-amd64
	docker tag cnych/pause-amd64:3.1 k8s.gcr.io/pause-amd64:3.1
	docker tag cnych/kube-proxy-amd64:v1.10.0 k8s.gcr.io/kube-proxy-amd64:v1.10.0

	docker tag cnych/kubernetes-dashboard-amd64:v1.8.3 k8s.gcr.io/kubernetes-dashboard-amd64:v1.8.3
	docker tag cnych/heapster-influxdb-amd64:v1.3.3 k8s.gcr.io/heapster-influxdb-amd64:v1.3.3
	docker tag cnych/heapster-grafana-amd64:v4.4.3 k8s.gcr.io/heapster-grafana-amd64:v4.4.3
	docker tag cnych/heapster-amd64:v1.4.2 k8s.gcr.io/heapster-amd64:v1.4.2
}

install_k8s(){
	echo "[Info] install kubernetes 1.10"
	yum makecache fast && yum install -y kubelet-1.10.0-0 kubeadm-1.10.0-0 kubectl-1.10.0-0 
}

config_k8s(){
	sed -i '/ExecStart/iEnvironment="KUBELET_EXTRA_ARGS=--fail-swap-on=false"' the.conf.file
	systemctl daemon-reload
}

add_to_master(){
	systemctl enable kubelet.service
  	systemctl enable docker.service
	echo "[Info] Starting kubernetes service..."
	#这里需要添加内容
}





set_firewall
preconfig
set_k8s_network
pull_images
install_k8s
config_k8s
add_to_master