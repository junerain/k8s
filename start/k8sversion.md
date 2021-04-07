## docker版本
```
[root@k8s-master ~]# docker version
Client: Docker Engine - Community
 Version:           20.10.3
 API version:       1.40
 Go version:        go1.13.15
 Git commit:        48d30b5
 Built:             Fri Jan 29 14:34:14 2021
 OS/Arch:           linux/amd64
 Context:           default
 Experimental:      true

Server: Docker Engine - Community
 Engine:
  Version:          19.03.10
  API version:      1.40 (minimum version 1.12)
  Go version:       go1.13.10
  Git commit:       9424aeaee9
  Built:            Thu May 28 22:16:43 2020
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.4.3
  GitCommit:        269548fa27e0089a8b8278fc4fc781d7f65a939b
 runc:
  Version:          1.0.0-rc92
  GitCommit:        ff819c7e9184c13b7c2607fe6c30ae19403a7aff
 docker-init:
  Version:          0.18.0
  GitCommit:        fec3683
```

## K8s版本
```
[root@k8s-master ~]# docker image ls
REPOSITORY                           TAG        IMAGE ID       CREATED         SIZE
calico/node                          v3.17.3    a45c42ebe880   6 weeks ago     165MB
calico/pod2daemon-flexvol            v3.17.3    53f21afd77e8   6 weeks ago     21.7MB
calico/cni                           v3.17.3    32eddea2c8b4   6 weeks ago     128MB
calico/kube-controllers              v3.17.3    8a89fcd7b1c0   6 weeks ago     52.1MB
k8s.gcr.io/kube-proxy                v1.20.4    c29e6c583067   6 weeks ago     118MB
k8s.gcr.io/kube-controller-manager   v1.20.4    0a41a1414c53   6 weeks ago     116MB
k8s.gcr.io/kube-apiserver            v1.20.4    ae5eb22e4a9d   6 weeks ago     122MB
k8s.gcr.io/kube-scheduler            v1.20.4    5f8cb769bd73   6 weeks ago     47.3MB
k8s.gcr.io/etcd                      3.4.13-0   0369cf4303ff   7 months ago    253MB
k8s.gcr.io/coredns                   1.7.0      bfe3a36ebd25   9 months ago    45.2MB
k8s.gcr.io/pause                     3.2        80d28bedfe5d   13 months ago   683kB
[root@k8s-master ~]# kubectl version
Client Version: version.Info{Major:"1", Minor:"20", GitVersion:"v1.20.4", GitCommit:"e87da0bd6e03ec3fea7933c4b5263d151aafd07c", GitTreeState:"clean", BuildDate:"2021-02-18T16:12:00Z", GoVersion:"go1.15.8", Compiler:"gc", Platform:"linux/amd64"}
The connection to the server localhost:8080 was refused - did you specify the right host or port?
[root@k8s-master ~]# su - k8s
Last login: Wed Apr  7 08:43:15 CST 2021 on pts/4
[k8s@k8s-master ~]$ kubectl version
Client Version: version.Info{Major:"1", Minor:"20", GitVersion:"v1.20.4", GitCommit:"e87da0bd6e03ec3fea7933c4b5263d151aafd07c", GitTreeState:"clean", BuildDate:"2021-02-18T16:12:00Z", GoVersion:"go1.15.8", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"20", GitVersion:"v1.20.4", GitCommit:"e87da0bd6e03ec3fea7933c4b5263d151aafd07c", GitTreeState:"clean", BuildDate:"2021-02-18T16:03:00Z", GoVersion:"go1.15.8", Compiler:"gc", Platform:"linux/amd64"}
```

## 镜像导出

```

[root@k8s-master docker-image]# docker image ls|grep /|awk '{print "docker save "  substr($3,1,4) " > " $1"."$2".tar"}'|sed 's/\//\./g'
docker save a45c > calico.node.v3.17.3.tar
docker save 53f2 > calico.pod2daemon-flexvol.v3.17.3.tar
docker save 32ed > calico.cni.v3.17.3.tar
docker save 8a89 > calico.kube-controllers.v3.17.3.tar
docker save c29e > k8s.gcr.io.kube-proxy.v1.20.4.tar
docker save 0a41 > k8s.gcr.io.kube-controller-manager.v1.20.4.tar
docker save ae5e > k8s.gcr.io.kube-apiserver.v1.20.4.tar
docker save 5f8c > k8s.gcr.io.kube-scheduler.v1.20.4.tar
docker save 0369 > k8s.gcr.io.etcd.3.4.13-0.tar
docker save bfe3 > k8s.gcr.io.coredns.1.7.0.tar
docker save 80d2 > k8s.gcr.io.pause.3.2.tar

```

## 镜像导入
```
[root@k8s-master docker-image]# docker image ls|grep /|awk '{print "docker tag "  substr($3,1,4)  " "$1":"$2}'
docker tag a45c calico/node:v3.17.3
docker tag 53f2 calico/pod2daemon-flexvol:v3.17.3
docker tag 32ed calico/cni:v3.17.3
docker tag 8a89 calico/kube-controllers:v3.17.3
docker tag c29e k8s.gcr.io/kube-proxy:v1.20.4
docker tag 0a41 k8s.gcr.io/kube-controller-manager:v1.20.4
docker tag ae5e k8s.gcr.io/kube-apiserver:v1.20.4
docker tag 5f8c k8s.gcr.io/kube-scheduler:v1.20.4
docker tag 0369 k8s.gcr.io/etcd:3.4.13-0
docker tag bfe3 k8s.gcr.io/coredns:1.7.0
docker tag 80d2 k8s.gcr.io/pause:3.2

[root@wxtest1607 lixr]# docker images
REPOSITORY                TAG                 IMAGE ID            CREATED             SIZE
tomcat8                   3.0                 90457edaf6ff        7 hours ago         1.036 GB
[root@wxtest1607 lixr]# docker rmi 9045
Untagged: tomcat8:3.0
Deleted: sha256:90457edaf6ff4ce328dd8a3131789c66e6bd89e1ce40096b89dd49d6e9d62bc8
Deleted: sha256:00df1d61992f2d87e7149dffa7afa5907df3296f5775c53e3ee731972e253600
[root@wxtest1607 lixr]# docker images
REPOSITORY                TAG                 IMAGE ID            CREATED             SIZE
[root@wxtest1607 lixr]# docker load < tomcat8-apr.tar
60685807648a: Loading layer [==================================================>] 442.7 MB/442.7 MB
[root@wxtest1607 lixr]# yer [>                                                  ] 527.7 kB/442.7 MB
[root@wxtest1607 lixr]# docker images
REPOSITORY                TAG                 IMAGE ID            CREATED             SIZE
<none>                    <none>              90457edaf6ff        7 hours ago         1.036 GB
[root@wxtest1607 lixr]# docker tag 9045 tomcat8-apr:3.0
[root@wxtest1607 lixr]# 
[root@wxtest1607 lixr]# docker images
REPOSITORY                TAG                 IMAGE ID            CREATED             SIZE
tomcat8-apr               3.0                 90457edaf6ff        7 hours ago         1.036 GB
```