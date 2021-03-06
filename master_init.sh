#!/bin/bash


host_ip=""
host_name=""
cluster_dns="10.10.10.2"
cluster_ip_range="10.10.10.0"


# 可能还需要定义其他变量

get_ip()
{
	# 这里可能需要修改，不同主机ip地址格式不一样
	host_ip=`ip addr | grep "global eth0" | awk '{print $2}' | awk -F '/' '{print $1}'`
	#host_ip="192.168.1.1"
	host_name=$host_ip
}

get_binary_file()
{
	bash ./binary-file/get_file.sh
}


install_docker()
{
	yum install docker
	service docker start
}

pull_basic_image()
{
	docker pull busybox
	docker pull cnych/pause-amd64:3.1
	docker tag cnych/pause-amd64:3.1 k8s.gcr.io/pause-amd64:3.1
}

create_image()
{
	docker build -f ./dockerfile/kube-apiserver -t docker.io/kube-apiserver:1.10 .
	docker build -f ./dockerfile/etcd -t docker.io/etcd:3.2 .
	docker build -f ./dockerfile/kube-scheduler -t docker.io/kube-scheduler:1.10 .
	docker build -f ./dockerfile/kube-controller-manager -t docker.io/kube-controller-manager:1.10 .
}

config_kubelet()
{
	sed "s/host_ip/$host_ip/g;s/host_name/$host_name/g;s/cluster_dns/$cluster_dns/g" ./conf/kubelet > ./conf/kubelet.confed
	sed "s/host_ip/$host_ip/g" ./conf/kubelet.config > ./conf/kubelet.config.confed
	mkdir -p /etc/kubernetes/conf/
	mkdir -p /etc/kubernetes/manifest/
	cp ./binary-file/kubelet /usr/bin/
	chmod +x /usr/bin/kubelet
	cp ./conf/kubelet.service /usr/lib/systemd/system/
	cp ./conf/{kubelet.confed,kubelet.config.confed} /etc/kubernetes/conf/
	mv /etc/kubernetes/conf/kubelet.confed /etc/kubernetes/conf/kubelet
	mv /etc/kubernetes/conf/kubelet.config.confed /etc/kubernetes/conf/kubelet.config
}

config_etcd()
{
	sed "s/host_ip/$host_ip/g" ./manifest/etcd.yaml > ./manifest/etcd.yaml.confed
	mv ./manifest/etcd.yaml.confed ./manifest/etcd.yaml
}

config_apiserver()
{
	sed "s/host_ip/$host_ip/g;s/cluster_ip_range/$cluster_ip_range/g" ./manifest/kube-apiserver.yaml > ./manifest/kube-apiserver.yaml.confed
	mv ./manifest/kube-apiserver.yaml.confed ./manifest/kube-apiserver.yaml
}


config_controllermanager()
{
	sed "s/host_ip/$host_ip/g" ./manifest/kube-controller-manager.yaml > ./manifest/kube-controller-manager.yaml.confed
	mv ./manifest/kube-controller-manager.yaml.confed ./manifest/kube-controller-manager.yaml
}

config_scheduler()
{
	sed "s/host_ip/$host_ip/g" ./manifest/kube-scheduler.yaml > ./manifest/kube-scheduler.yaml.confed
	mv ./manifest/kube-scheduler.yaml.confed ./manifest/kube-scheduler.yaml
}


cp_manifest()
{
	cp ./manifest/*  /etc/kubernetes/manifest/
}

start_kubelet()
{
	systemctl enable kubelet
	systemctl start kubelet
}

install_kubectl()
{
	cp ./binary-file/kubectl /usr/bin/
	chmod +x /usr/bin/kubectl
}

get_ip
get_binary_file
install_docker
pull_basic_image
config_kubelet
config_etcd
config_apiserver
config_controllermanager
config_scheduler
create_image
cp_manifest
start_kubelet
install_kubectl
