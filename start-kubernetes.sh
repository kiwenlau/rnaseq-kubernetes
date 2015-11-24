#!/bin/bash

# Run ectd container
echo "Starting ectd container..."
sudo docker run -d --name="etcd" quay.io/coreos/etcd:v2.2.1 \
                                      --addr=127.0.0.1:4001 \
                                      --bind-addr=0.0.0.0:4001 \
                                      --data-dir=/var/etcd/data 

# Run apiserver container
echo "Starting apiserver container..."
sudo docker run -d --link etcd:etcd -p 8080:8080 --name="apiserver" kiwenlau/kubernetes:1.0.7 kube-apiserver \
                                                         --service-cluster-ip-range=10.0.0.1/24 \
                                                         --insecure-bind-address=0.0.0.0 \
                                                         --etcd_servers=http://etcd:4001

sleep 10

# Run controller-manager container
echo "Starting controller-manager container..."
sudo docker run -d --link apiserver:apiserver --name="controller-manager" kiwenlau/kubernetes:1.0.7 kube-controller-manager --master=http://apiserver:8080                                                                           

# Run scheduler container
echo "Starting scheduler container..."
sudo docker run -d --link apiserver:apiserver --name="scheduler" kiwenlau/kubernetes:1.0.7 kube-scheduler --master=http://apiserver:8080 
                                                                                                                  
# Run kubelet container
echo "Starting kubelet container..."
sudo docker run -d --link apiserver:apiserver --pid=host -v /var/run/docker.sock:/var/run/docker.sock --name="kubelet"  kiwenlau/kubernetes:1.0.7 kubelet \
                                                                                                                      --api_servers=http://apiserver:8080 \
                                                                                                                      --address=0.0.0.0 \
                                                                                                                      --hostname_override=127.0.0.1 \
                                                                                                                      --cluster_dns=10.0.0.10 \
                                                                                                                      --cluster_domain="kubernetes.local" 
                                                                                                   
# Run proxy container
echo "Starting proxy container..."
sudo docker run -d --link apiserver:apiserver --privileged --name="proxy" kiwenlau/kubernetes:1.0.7 kube-proxy --master=http://apiserver:8080 

# Install kubectl command line tool on local host                                                                
sudo docker run --rm -v /usr/local/bin:/tmp kiwenlau/kubernetes:1.0.7 bash -c "cp /usr/local/bin/kubectl /tmp"

