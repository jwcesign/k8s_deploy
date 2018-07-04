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
	mkdir -p /etc/kubenetes/conf/
	mkdir -p /etc/kubenetes/manifest/
	cp ./manifest/*  /etc/kubenetes/manifest/
	cp ./binary-file/kubelet /usr/bin/
	chmod +x /usr/bin/kubelet
	cp ./conf/kubelet.service /etc/systemd/system/
	cp ./conf/{kubelet.confed,kubelet.config.confed} /etc/kubenetes/conf/
	mv /etc/kubenetes/conf/kubelet.confed /etc/kubenetes/conf/kubelet
	mv /etc/kubenetes/conf/kubelet.config.confed /etc/kubenetes/conf/kubelet.config
}

config_etcd()
{
	sed "s/host_ip/$host_ip/g" ./conf/etcd.conf > ./conf/etcd.conf.confed
	mv ./conf/etcd.conf.confed ./conf/etcd.conf
}

config_apiserver()
{
	sed "s/host_ip/$host_ip/g;s/cluster_ip_range/$cluster_ip_range/g" ./conf/kube-apiserver.conf > ./conf/kube-apiserver.conf.confed
	mv ./conf/kube-apiserver.conf.confed ./conf/kube-apiserver.conf
}


config_controllermanager()
{
	sed "s/host_ip/$host_ip/g" ./conf/kube-controller-manager.conf > ./conf/kube-controller-manager.conf.confed
	mv ./conf/kube-controller-manager.conf.confed ./conf/kube-controller-manager.conf
}

config_scheduler()
{
	sed "s/host_ip/$host_ip/g" ./conf/kube-scheduler.conf > ./conf/kube-scheduler.conf.confed
	mv ./conf/kube-scheduler.conf.confed ./conf/kube-scheduler.conf
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
start_kubelet
install_kubectl