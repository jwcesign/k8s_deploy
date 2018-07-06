#!/bin/bash

#master_ip="10.13.130.78"
master_ip="master_ipaddr"
cluster_dns="10.10.10.2"
cluster_ip_range="10.10.20.0"
host_name=""

install_docker()
{
	yum install docker -y
	service docker start
}

get_ip()
{
	host_ip=`ip addr | grep "global eth0" | awk '{print $2}' | awk -F '/' '{print $1}'`
	#host_ip="10.211.55.8"
	host_name=$host_ip
}

pull_basic_image()
{
	docker pull cnych/pause-amd64:3.1
	docker tag cnych/pause-amd64:3.1 k8s.gcr.io/pause-amd64:3.1
}

config_kubelet()
{
	sed "s/host_name/$host_name/g;s/cluster_dns/$cluster_dns/g" ./conf/kubelet_node > ./conf/kubelet.confed
	sed "s/master_ip/$master_ip/g" ./conf/kubelet_node.config > ./conf/kubelet.config.confed
	mkdir -p /etc/kubernetes/conf/
	mkdir -p /etc/kubernetes/manifest/ 
	cp ./kubelet /usr/bin/
	chmod +x /usr/bin/kubelet
	cp ./conf/kubelet.service /usr/lib/systemd/system/
	cp ./conf/{kubelet.confed,kubelet.config.confed} /etc/kubernetes/conf/
	mv /etc/kubernetes/conf/kubelet.confed /etc/kubernetes/conf/kubelet
	mv /etc/kubernetes/conf/kubelet.config.confed /etc/kubernetes/conf/kubelet.config
}

start_kubelet()
{
	systemctl enable kubelet
	systemctl start kubelet
}

install_docker
get_ip
pull_basic_image
config_kubelet
start_kubelet

