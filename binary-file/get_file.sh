#!/bin/bash

etcd_url="https://github.com/coreos/etcd/releases/download/v3.3.7/etcd-v3.3.7-linux-amd64.tar.gz"
k8s_url="https://dl.k8s.io/v1.10.0-beta.4/kubernetes-server-linux-amd64.tar.gz"

get_file()
{
	wget $etcd_url -O ./binary-file/etcd.tar.gz
	wget $k8s_url -O ./binary-file/k8s.tar.gz
}

unzip_file()
{
	tar -zxvf etcd.tar.gz -C ./binary-file/
	tar -zxvf k8s.tar.gz -C ./binary-file/
}

mv_file()
{
	mv ./binary-file/etcd-v3.3.7-linux-amd64/{etcd,etcdctl} ./binary-file/
	mv ./binary-file/kubernetes/server/bin/{kube-apiserver,kube-controller-manager,kube-proxy,kube-scheduler,kubectl,kubelet} ./binary-file/
}

get_file
unzip_file
mv_file

