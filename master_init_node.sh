#!/bin/bash

ip=""
port=""
user=""
passwd=""
binary_file=""
conf_file=""
node_init=""
master_ip=""
des_dir="~/"

install_expect()
{
	yum install expect -y
	chmod +x assh
	chmod +x ascp
}


set_master_ip()
{
	master_ip=`ip addr | grep "global eth0" | awk '{print $2}' | awk -F '/' '{print $1}'`
	#master_ip="10.1.1.1"
}

config_node_init_script()
{
	sed "s/master_ipaddr/$master_ip/g" ./node_init.sh > ./node_init.sh.confed
}

get_conf()
{
	# 设置node用户名，密码，二进制文件目录，manifest文件目录，配置文件目录
	ip="10.13.138.12"
	port=10022
	user="guwei"
	passwd="Jw@123456789"
	binary_file="./binary-file/kubelet"
	conf_file="./conf/"
	node_init="node_init.sh.confed"
}


copy_file_to_node()
{
	# 复制manifest，配置文件，二进制文件，node初始化文件
	# 这里可能需要用到expect操作
	# scp
	./ascp $binary_file $ip $port $user $passwd $des_dir
	#./ascp $manifest_file $ip $port $user $passwd $des_dir
	./ascp $conf_file $ip $port $user $passwd $des_dir
	./ascp $node_init $ip $port $user $passwd $des_dir
}

ssh_to_node_and_exec()
{
	# 登录到node，并执行node初始化脚本
	# 这里可能需要用到expect操作
	# ssh
	./assh $ip $port $user $passwd
}

install_expect
set_master_ip
config_node_init_script
get_conf
copy_file_to_node
ssh_to_node_and_exec

