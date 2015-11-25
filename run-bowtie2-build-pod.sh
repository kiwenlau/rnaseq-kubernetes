#!/bin/bash

echo -e "\nkubectl delete pods/bowtie2-build"
kubectl delete pods/bowtie2-build

echo -e "\n\nrm rnaseq/output/index/*"
rm rnaseq/output/index/*

echo -e "\n\nkubectl create --validate -f pod-bowtie2-build.yaml"
kubectl create --validate -f pod-bowtie2-build.yaml 

echo -e "\n\nkubectl get pods/bowtie2-build\n"
while [[ true ]]; do
        kubectl get pods/bowtie2-build
        bowtie2buildPod=`kubectl get pods/bowtie2-build | grep ExitCode`
        if [[ $bowtie2buildPod ]]; then
                break
        fi
        sleep 2
done

containerID=`docker ps -l=1 -q`

echo -e "\n\ndocker logs $containerID\n"
docker logs $containerID

