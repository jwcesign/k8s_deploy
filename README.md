## k8s 1.10搭建问题

### master节点

* 将etcd  etcdctl  kube-apiserver  kube-controller-manager  kubectl  kube-scheduler二进制文件复制到master节点

#### ectd服务
* etcd.service
~~~
[Unit]
Description=etcd.service
[Service]
Type=notify
TimeoutStartSec=0
Restart=always
WorkingDirectory=/var/lib/etcd
EnvironmentFile=/usr/src/k8s19/master/conf/etcd.conf
ExecStart=/usr/src/k8s19/master/bin/etcd
[Install]
WantedBy=multi-user.target
~~~

* etcd.conf
~~~
ETCD_NAME=ETCD Server
ETCD_DATA_DIR="/var/lib/etcd/"
ETCD_LISTEN_CLIENT_URLS="http://0.0.0.0:2379"
ETCD_ADVERTISE_CLIENT_URLS="http://127.0.0.1:2379"
~~~

* 其他可配置参数
~~~
等待补充
~~~

####  kube-apiserver
* kube-apiserver.service
~~~
[Unit]
Description=Kubernetes API Server
After=etcd.service
Wants=etcd.service

[Service]
EnvironmentFile=/usr/src/k8s19/master/conf/apiserver
ExecStart=/usr/src/k8s19/master/bin/kube-apiserver  \
        $KUBE_ETCD_SERVERS \
        $KUBE_API_ADDRESS \
        $KUBE_API_PORT \
        $KUBE_SERVICE_ADDRESSES \
        $KUBE_ADMISSION_CONTROL \
        $KUBE_API_LOG \
        $KUBE_API_ARGS
Restart=on-failure
Type=notify
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
~~~

* apiserver
~~~
UBE_API_ADDRESS="--insecure-bind-address=0.0.0.0"
KUBE_API_PORT="--insecure-port=8080"
KUBE_ETCD_SERVERS="--etcd-servers=http://127.0.0.1:2379"
KUBE_SERVICE_ADDRESSES="--service-cluster-ip-range=10.10.10.0/24"
KUBE_ADMISSION_CONTROL="--admission-control=NamespaceLifecycle,LimitRanger,ResourceQuota"
KUBE_API_LOG="--logtostderr=false --log-dir=/home/k8s-t/log/kubernets --v=2"
KUBE_API_ARGS=" "
~~~

* 其他可配置参数
~~~
等待补充
~~~

#### kube-scheduler
* kube-scheduler.service
~~~
[Unit]
Description=Kubernetes Scheduler
After=kube-apiserver.service
Requires=kube-apiserver.service

[Service]
User=root
EnvironmentFile=/usr/src/k8s19/master/conf/scheduler
ExecStart=/usr/src/k8s19/master/bin/kube-scheduler \
        $KUBE_MASTER \
        $KUBE_SCHEDULER_ARGS
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
~~~

* scheduler
~~~
KUBE_MASTER="--master=http://127.0.0.1:8080"
KUBE_SCHEDULER_ARGS="--logtostderr=true --log-dir=/home/k8s-t/log/kubernetes --v=2"
~~~

* 其他可配置参数
~~~
等待补充
~~~

#### kube-controller-manager
* kube-controller-manager.service
~~~
[Unit]
Description=Kubernetes Scheduler
After=kube-apiserver.service
Requires=kube-apiserver.service

[Service]
EnvironmentFile=/usr/src/k8s19/master/conf/controller-manager
ExecStart=/usr/src/k8s19/master/bin/kube-controller-manager \
        $KUBE_MASTER \
        $KUBE_CONTROLLER_MANAGER_ARGS
Restart=on-failure
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
~~~

* controller-manager
~~~
KUBE_MASTER="--master=http://127.0.0.1:8080"
KUBE_CONTROLLER_MANAGER_ARGS=" "
~~~

* 其他可配置参数
~~~
等待补充
~~~

#### 启动脚本

* start.sh
~~~
systemctl daemon-reload
systemctl enable kube-apiserver.service
systemctl start kube-apiserver.service
systemctl enable kube-controller-manager.service
systemctl start kube-controller-manager.service
systemctl enable kube-scheduler.service
systemctl start kube-scheduler.service
systemctl status kube-apiserver.service
systemctl status kube-controller-manager.service
systemctl status kube-scheduler.service
~~~

* stop.sh
~~~
systemctl stop kube-scheduler
systemctl stop kube-controller-manager
systemctl stop kube-apiserver
systemctl status kube-apiserver.service
systemctl status kube-controller-manager.service
systemctl status kube-scheduler.service
~~~


### node节点
* 将kubectl  kubelet  kube-proxy复制到node节点

#### kubelet
* kubelet.service
~~~
[Unit]
Description=Kubernetes Kubelet Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=docker.service
Requires=docker.service

[Service]
WorkingDirectory=/var/lib/kubelet
EnvironmentFile=/usr/src/k8s19/node/conf/kubelet
ExecStart=/usr/src/k8s19/node/bin/kubelet $KUBELET_ARGS
Restart=on-failure
KillMode=process

[Install]
WantedBy=multi-user.target
~~~

* kubelet
~~~
KUBELET_ARGS="--cgroup-driver=systemd --address=10.13.130.78 --port=10250 --hostname-override=10.13.130.78 --allow-privileged=false --kubeconfig=/usr/src/k8s19/node/conf/kubelet.kubeconfig --cluster-dns=10.10.10.2 --cluster-domain=cluster.local --fail-swap-on=false --logtostderr=true --log-dir=/var/log/kubernetes --v=2"
~~~

* 其他可配置参数
~~~
等待补充
~~~


#### kube-proxy
* kube-proxy.service
~~~
[Unit]
Description=Kubernetes Kube-proxy Server
Documentation=https://github.com/GoogleCloudPlatform/kubernetes
After=network.service
Requires=network.service

[Service]
EnvironmentFile=/usr/src/k8s19/node/conf/proxy
ExecStart=/usr/src/k8s19/node/bin/kube-proxy $KUBE_PROXY_ARGS
Restart=on-failure
LimitNOFILE=65536
KillMode=process

[Install]
WantedBy=multi-user.target
~~~

* proxy
~~~
KUBE_PROXY_ARGS="--master=http://10.13.130.78:8080 --hostname-override=10.13.130.78 --logtostderr=true --log-dir=/var/log/kubernetes --v=4"
~~~

* 其他可配置参数
~~~
等待补充
~~~

#### 启动脚本

* start.sh
~~~
systemctl start kubelet
systemctl start kube-proxy
systemctl status kubelet
systemctl status kube-proxy
~~~

* stop.sh
~~~
systemctl stop kubelet
systemctl stop kube-proxy
systemctl status kube-proxy
systemctl status kubelet
~~~

## 容器化安装
* 安装主脚本：master_install.sh，注意其中的kube-proxy没有拉起，待完善（可以定制化参数）
* manifest文件夹：各主机的yaml文件，可以修改以定制启动参数
* dockerfile：docker build的各组件的dockerfile
* conf: 各组件的启动参数设置
* binary-file：获取各组件
* 脚本比较简单，一看就懂，如果需要定制化脚本，可以自己添加类容
