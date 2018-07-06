## k8s 1.10 定制自动化搭建

### 主要文件
* binary-file: 二进制文件，由于二进制文件过大，此处通过脚本获取（wget）
* conf: 各组件的配置文件，后面可以自动添加相关的参数
* dockerfile: 把各组件打包为容器的dockerfile，基础镜像是busybox，后面可以利用更纯净的镜像
* manifest: 各组件的manifest文件，里面可以定制化一些k8s支持的特性，注意不同版本支持特性不一样
* master_init.sh: master安装脚本，实现了各组件的容器化，可以自己填入一些参数，如dns ip, cluster ip等。
* node_init.sh：脚本以完善，用以在node上安装kubelet与docker，并加入集群。
* master_init_node.sh：通过master脚本初始化node节点，并让它加入集群，通过远程命令执行。


###  注意点
* master_install.sh脚本中的***get_ip***函数根据不同主机可能需要更改正则表达式
* binary-file中的获取二进制文件地址可以设置，建议替换为内网的文件，要不然会比较慢
* 实时运行日志输出位置可以修改manifest中的配置文件
* node_init.sh脚本暂时不能用，需要手动设置master ip
* 有些k8s 1.5的启动参数在1.10中已经不建议使用,建议看官方文档的显示的启动参数

### 最新k8s 各组件启动参数链接
* kubelet: [link](https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/)
* kube-apiserver: [link](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/)
* kube-controller-manager: [link](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-controller-manager/)
* kube-scheduler: [link](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-scheduler/)
* kube-proxy: [link](https://kubernetes.io/docs/reference/command-line-tools-reference/kube-proxy/)
* etcd: [link](https://github.com/coreos/etcd/blob/master/Documentation/op-guide/configuration.md)

### 等待改进
* 脚本参数不完善，只能搭建基本的环境
* 基础镜像可以自己制作，可以达到比busybox更小的体积

### 提示
* 如果需要重新安装，直接把etcd的数据文件删除，重新运行脚本即可
* 如果需要升级，先下载二进制，然后制作dockerfile，然后替换manifest文件，最后替换kubelet
* 脚本比较简单，看一下就是做什么的了，后面可能要根据实际环境，线上线下等修改代码

### 安装
* 直接运行master_install.sh安装节点
* node_init.sh还没实现自动化，因为需要设置master ip，暂时不建议用

## 通过master节点初始化node节点
* 通过设置master_init_node.sh中的node节点的用户名，密码与ip，即可运行并把改节点加入集群
* 后面可以通过一些手段使其自动化
* 整个集群没有打通不同节点的pod与pod之间的网络