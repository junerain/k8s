# 安装k8s
## 安装docker

    yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
    yum install -y docker-ce-19.03.10-3.el7

## 设置docker代理（很关键）
```
cat <<EOF >  vim /etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=http://172.16.0.16:8118"
EOF
```
    systemctl daemon-reload
    systemctl restart docker
    systemctl show --property=Environment docker

## 验证代理  
    docker pull k8s.gcr.io/pause:3.2

## 安装kubeadm
### 设置yum源
```
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
```
    yum makecache fast
    
### 安装软件

    yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

### 拉取镜像
    kubeadm config images list
    [root@k8s-master .docker]# kubeadm config images list
    k8s.gcr.io/kube-apiserver:v1.20.4
    k8s.gcr.io/kube-controller-manager:v1.20.4
    k8s.gcr.io/kube-scheduler:v1.20.4
    k8s.gcr.io/kube-proxy:v1.20.4
    k8s.gcr.io/pause:3.2
    k8s.gcr.io/etcd:3.4.13-0
    k8s.gcr.io/coredns:1.7.0
    //
    kubeadm config images pull
    [root@k8s-master ~]# kubeadm config images pull
    [config/images] Pulled k8s.gcr.io/kube-apiserver:v1.20.4
    [config/images] Pulled k8s.gcr.io/kube-controller-manager:v1.20.4
    [config/images] Pulled k8s.gcr.io/kube-scheduler:v1.20.4
    [config/images] Pulled k8s.gcr.io/kube-proxy:v1.20.4
    [config/images] Pulled k8s.gcr.io/pause:3.2
    [config/images] Pulled k8s.gcr.io/etcd:3.4.13-0
    [config/images] Pulled k8s.gcr.io/coredns:1.7.0

### 打印初始化的配置
    kubeadm config print init-defaults
    [root@k8s-master .docker]# kubeadm config print init-defaults
    apiVersion: kubeadm.k8s.io/v1beta2
    bootstrapTokens:
    - groups:
    - system:bootstrappers:kubeadm:default-node-token
    token: abcdef.0123456789abcdef
    ttl: 24h0m0s
    usages:
    - signing
    - authentication
    kind: InitConfiguration
    localAPIEndpoint:
    advertiseAddress: 1.2.3.4
    bindPort: 6443
    nodeRegistration:
    criSocket: /var/run/dockershim.sock
    name: k8s-master
    taints:
    - effect: NoSchedule
        key: node-role.kubernetes.io/master
    ---
    apiServer:
    timeoutForControlPlane: 4m0s
    apiVersion: kubeadm.k8s.io/v1beta2
    certificatesDir: /etc/kubernetes/pki
    clusterName: kubernetes
    controllerManager: {}
    dns:
    type: CoreDNS
    etcd:
    local:
        dataDir: /var/lib/etcd
    imageRepository: k8s.gcr.io
    kind: ClusterConfiguration
    kubernetesVersion: v1.20.0
    networking:
    dnsDomain: cluster.local
    serviceSubnet: 10.96.0.0/12
    scheduler: {}
## 确保流量路由配置
```
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
sysctl --system
```
# 安装集群
    [root@k8s-master ~]# kubeadm init
    [init] Using Kubernetes version: v1.20.4
    [preflight] Running pre-flight checks
	[WARNING Service-Docker]: docker service is not enabled, please run 'systemctl enable docker.service'
	[WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/ error execution phase preflight: [preflight] Some fatal errors occurred:
	[ERROR FileContent--proc-sys-net-ipv4-ip_forward]: /proc/sys/net/ipv4/ip_forward contents are not set to 1
    [preflight] If you know what you are doing, you can make a check non-fatal with `--ignore-preflight-errors=...`
    To see the stack trace of this error execute with --v=5 or higher
    [root@k8s-master ~]# echo 1 > /proc/sys/net/ipv4/ip_forward
    [root@k8s-master ~]# kubeadm init
    [init] Using Kubernetes version: v1.20.4
    [preflight] Running pre-flight checks
        [WARNING Service-Docker]: docker service is not enabled, please run 'systemctl enable docker.service'
        [WARNING IsDockerSystemdCheck]: detected "cgroupfs" as the Docker cgroup driver. The recommended driver is "systemd". Please follow the guide at https://kubernetes.io/docs/setup/cri/
    [preflight] Pulling images required for setting up a Kubernetes cluster
    [preflight] This might take a minute or two, depending on the speed of your internet connection
    [preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
    [certs] Using certificateDir folder "/etc/kubernetes/pki"
    [certs] Generating "ca" certificate and key
    [certs] Generating "apiserver" certificate and key
    [certs] apiserver serving cert is signed for DNS names [k8s-master kubernetes kubernetes.default kubernetes.default.svc kubernetes.default.svc.cluster.local] and IPs [10.96.0.1 172.16.0.10]
    [certs] Generating "apiserver-kubelet-client" certificate and key
    [certs] Generating "front-proxy-ca" certificate and key
    [certs] Generating "front-proxy-client" certificate and key
    [certs] Generating "etcd/ca" certificate and key
    [certs] Generating "etcd/server" certificate and key
    [certs] etcd/server serving cert is signed for DNS names [k8s-master localhost] and IPs [172.16.0.10 127.0.0.1 ::1]
    [certs] Generating "etcd/peer" certificate and key
    [certs] etcd/peer serving cert is signed for DNS names [k8s-master localhost] and IPs [172.16.0.10 127.0.0.1 ::1]
    [certs] Generating "etcd/healthcheck-client" certificate and key
    [certs] Generating "apiserver-etcd-client" certificate and key
    [certs] Generating "sa" key and public key
    [kubeconfig] Using kubeconfig folder "/etc/kubernetes"
    [kubeconfig] Writing "admin.conf" kubeconfig file
    [kubeconfig] Writing "kubelet.conf" kubeconfig file
    [kubeconfig] Writing "controller-manager.conf" kubeconfig file
    [kubeconfig] Writing "scheduler.conf" kubeconfig file
    [kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
    [kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
    [kubelet-start] Starting the kubelet
    [control-plane] Using manifest folder "/etc/kubernetes/manifests"
    [control-plane] Creating static Pod manifest for "kube-apiserver"
    [control-plane] Creating static Pod manifest for "kube-controller-manager"
    [control-plane] Creating static Pod manifest for "kube-scheduler"
    [etcd] Creating static Pod manifest for local etcd in "/etc/kubernetes/manifests"
    [wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/manifests". This can take up to 4m0s
    [kubelet-check] Initial timeout of 40s passed.
    [apiclient] All control plane components are healthy after 104.008331 seconds
    [upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
    [kubelet] Creating a ConfigMap "kubelet-config-1.20" in namespace kube-system with the configuration for the kubelets in the cluster
    [upload-certs] Skipping phase. Please see --upload-certs
    [mark-control-plane] Marking the node k8s-master as control-plane by adding the labels "node-role.kubernetes.io/master=''" and "node-role.kubernetes.io/control-plane='' (deprecated)"
    [mark-control-plane] Marking the node k8s-master as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
    [bootstrap-token] Using token: g97yjq.n40ng8r5g0gmif07
    [bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
    [bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to get nodes
    [bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term certificate credentials
    [bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
    [bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
    [bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
    [kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
    [addons] Applied essential addon: CoreDNS
    [addons] Applied essential addon: kube-proxy

    Your Kubernetes control-plane has initialized successfully!

    To start using your cluster, you need to run the following as a regular user:

    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config

    Alternatively, if you are the root user, you can run:

    export KUBECONFIG=/etc/kubernetes/admin.conf

    You should now deploy a pod network to the cluster.
    Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
    https://kubernetes.io/docs/concepts/cluster-administration/addons/

    Then you can join any number of worker nodes by running the following on each as root:

    kubeadm join 172.16.0.10:6443 --token g97yjq.n40ng8r5g0gmif07 \
        --discovery-token-ca-cert-hash sha256:34f682b418599d7c7da93b46e247f8d6c90c827bbcfe4996f7e26dfedf490f6f 
    
## 安装网络插件
    curl https://docs.projectcalico.org/manifests/calico.yaml -O

然后编辑 calico.yaml，找到 name: IP，在它上面加入

    - name: CLUSTER_TYPE
    value: "k8s,bgp"
    # 新增部分
    - name: IP_AUTODETECTION_METHOD
    value: "interface=eth0"
    # 新增部分结束
    - name: IP
    value: "autodetect"
    - name: CALICO_IPV4POOL_IPIP
    value: "Always"

# 加入节点
    kubeadm join 172.16.0.10:6443 --token g97yjq.n40ng8r5g0gmif07 \
        --discovery-token-ca-cert-hash sha256:34f682b418599d7c7da93b46e247f8d6c90c827bbcfe4996f7e26dfedf490f6f     
kubeadm init 产生的token默认的有效期是24小时，超过24小时后token过期了。在master节点上运行重新生成token

    kubeadm token create --print-join-command
    

# 部署kubernetes-dashboard

下载部署文件

    wget  https://raw.githubusercontent.com/kubernetes/dashboard/v2.1.0/aio/deploy/recommended.yaml

    kubectl apply -f ./recommended.yaml
    kubectl get -f ./recommended.yaml

后续操作见[中文参考网页](https://www.cnblogs.com/ljhbjehp/p/13567354.html)：

    [k8s@k8s-master ~]$ kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')
    Name:         admin-user-token-kzxf2
    Namespace:    kubernetes-dashboard
    Labels:       <none>
    Annotations:  kubernetes.io/service-account.name: admin-user
                kubernetes.io/service-account.uid: 8ae0d269-33c1-4fac-b954-96cbcef094a2

    Type:  kubernetes.io/service-account-token

    Data
    ====
    ca.crt:     1066 bytes
    namespace:  20 bytes
    token:      eyJhbGciOiJSUzI1NiIsImtpZCI6ImdmXzZyeGlUNzBORFVTZ0RPaFRKUS1nVEkyODRNR3drYVNTcjJ2Y0lsTFkifQ.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJhZG1pbi11c2VyLXRva2VuLWt6eGYyIiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9zZXJ2aWNlLWFjY291bnQubmFtZSI6ImFkbWluLXVzZXIiLCJrdWJlcm5ldGVzLmlvL3NlcnZpY2VhY2NvdW50L3NlcnZpY2UtYWNjb3VudC51aWQiOiI4YWUwZDI2OS0zM2MxLTRmYWMtYjk1NC05NmNiY2VmMDk0YTIiLCJzdWIiOiJzeXN0ZW06c2VydmljZWFjY291bnQ6a3ViZXJuZXRlcy1kYXNoYm9hcmQ6YWRtaW4tdXNlciJ9.pF2CxntpHfl2IL7E-H1U0gJzM-voYYtOP1YGQZPZTv5qlGBNXZOkC98sd-eT6HzRRSIeB5DBJnArIsYFogbvBMKpW4kpQ3aGJOn1cjJixWy4b3Znef5s1Uy0qEEEPorQIZht67QS2OXv_zDUMKvwipPdThW6xdipfxBKHKLhyQAiktVGA9_3wdw5B0qLc6NeMuHnY9cGzdvQKM58kQvwIlwANP-gpPEo8CmvyYLq1nuKN8b3t7bIEXfTyXthQxEVAUY8nRHqzhYWQxBaidkBNTl_HNMHUiy10sdCrZnL072oOKEQCYzse25prL1EM4xdigUvTmJfa8Tl9vyPzPmrEA
[官网参考](https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md)
[中文网页参考](https://www.cnblogs.com/ljhbjehp/p/13567354.html)

## 部署k8s集群   
    You can bootstrap a cluster as follows:
    1. Initializes cluster master node:
    kubeadm init --apiserver-advertise-address $(hostname -i) --pod-network-cidr 10.5.0.0/16
    2. Initialize cluster networking:
    kubectl apply -f https://raw.githubusercontent.com/cloudnativelabs/kube-router/master/daemonset/kubeadm-kuberouter.yaml
    3. (Optional) Create an nginx deployment:
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/website/master/content/en/examples/application/nginx-app.yaml
修改主机名称：

    hostnamectl set-hostname k8s-node17
参考:

    https://zhuanlan.zhihu.com/p/55740564?from_voters_page=true

    https://blog.csdn.net/lbw520/article/details/108746617
    https://www.cnblogs.com/ljhbjehp/p/13567354.html

添加源


# 删除k8s
    rm -rf /var/lib/etcd
    rm -rf $HOME/.kube
    rm -rf /var/etcd
    rm -rf /var/lib/kubelet/
    rm -rf /var/lib/rancher/
    rm -rf /run/kubernetes/
    rm /var/lib/kubelet/* -rf
    rm /etc/kubernetes/* -rf
    rm /var/lib/rancher/* -rf
    rm /var/lib/etcd/* -rf
    rm /var/lib/cni/* -rf
