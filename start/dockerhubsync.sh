#! /bin/bash
#批量同步
docker_repo="dayunshan" # your docker hub username or organization name
registry="gcr.io" # the registry of original image, e.g. gcr.io, quay.io
repo="google_containers" # the repository name of original image


sync_one(){
  docker pull ${registry}/${repo}/${1}:${2}
  docker tag ${registry}/${repo}/${1}:${2} docker.io/${docker_repo}/${1}:${2}
  docker push docker.io/${docker_repo}/${1}:${2}
  docker rmi -f ${registry}/${repo}/${1}:${2} docker.io/${docker_repo}/${1}:${2}
}

sync_all_tags() {
  for image in $*; do
    tags_str=`curl https://${registry}/v2/${repo}/$image/tags/list | jq '.tags' -c | sed 's/\[/\(/g' | sed 's/\]/\)/g' | sed 's/,/ /g'`
    echo "$image $tags_str"
    src="
sync_one(){
  docker pull ${registry}/${repo}/\${1}:\${2}
  docker tag ${registry}/${repo}/\${1}:\${2} docker.io/${docker_repo}/\${1}:\${2}
  docker push docker.io/${docker_repo}/\${1}:\${2}
  docker rmi -f ${registry}/${repo}/\${1}:\${2} docker.io/${docker_repo}/\${1}:\${2}
}
tags=${tags_str}
echo \"$image ${tags_str}\"
for tag in \${tags[@]}
do
  sync_one $image \${tag}
done;"
    bash -c "$src"
  done 
}

sync_with_tags(){
  image=$1
  skip=1
  for tag in $*; do
    if [ $skip -eq 1 ]; then
	  skip=0
    else
      sync_one $image $tag
	fi
  done 
}

sync_after_tag(){
  image=$1
  start_tag=$2
  tags_str=`curl https://${registry}/v2/${repo}/$image/tags/list | jq '.tags' -c | sed 's/\[/\(/g' | sed 's/\]/\)/g' | sed 's/,/ /g'`
  echo "$image $tags_str"
  src="
sync_one(){
  docker pull ${registry}/${repo}/\${1}:\${2}
  docker tag ${registry}/${repo}/\${1}:\${2} docker.io/${docker_repo}/\${1}:\${2}
  docker push docker.io/${docker_repo}/\${1}:\${2}
  docker rmi -f ${registry}/${repo}/\${1}:\${2} docker.io/${docker_repo}/\${1}:\${2}
}
tags=${tags_str}
start=0
for tag in \${tags[@]}; do
  if [ \$start -eq 1 ]; then
    sync_one $image \$tag
  elif [ \$tag == '$start_tag' ]; then
    start=1
  fi
done"
  bash -c "$src"
}

get_tags(){
  image=$1
  curl https://${registry}/v2/${repo}/$image/tags/list | jq '.tags' -c
}

#sync_with_tags etcd 2.0.12 2.0.13 # sync etcd:2.0.12 and etcd:2.0.13
#sync_after_tag etcd 2.0.8 # sync tag after etcd:2.0.8
#sync_all_tags etcd hyperkube # sync all tags of etcd and hyperkube



https://www.katacoda.com/courses/docker/deploying-first-container
#登录阿里云镜像中心
docker login --username=**** registry.cn-shanghai.aliyuncs.com
#拉取k8s.grc.io的镜像
docker pull k8s.gcr.io/sig-storage/csi-node-driver-registrar:v2.0.1
#重新打tag
docker tag k8s.gcr.io/sig-storage/csi-node-driver-registrar:v2.0.1 registry.cn-shanghai.aliyuncs.com/jieee/csi-node-driver-registrar:v2.0.1
#推送
docker push registry.cn-shanghai.aliyuncs.com/jieee/csi-node-driver-registrar:v2.0.1
#退出(关闭此网站后会销毁实例，不放心的也可以手动退出下)
docker logout registry.cn-shanghai.aliyuncs.com 



k8s.gcr.io/kube-state-metrics/kube-state-metrics:v2.0.0-beta
docker pull k8s.gcr.io/kube-state-metrics/kube-state-metrics:v2.0.0-beta

docker tag k8s.gcr.io/kube-state-metrics/kube-state-metrics:v2.0.0-beta dayunshan/k8s.gcr.io.kube-state-metrics:v2.0.0-beta
docker tag gcr.io/google-samples/cassandra:v13 dayunshan/gcr.io.google-samples.cassandra:v13
docker push dayunshan/k8s.gcr.io.kube-state-metrics:v2.0.0-beta

docker push dayunshan/gcr.io.google-samples.cassandra:v13


