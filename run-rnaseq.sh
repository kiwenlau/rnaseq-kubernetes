#!/bin/bash

echo -e "\nkubectl delete pods/rnaseq"
kubectl delete pods/rnaseq

echo -e "\n\nrm rnaseq/output/index/*"
rm rnaseq/output/index/*

echo -e "\n\nkubectl create --validate -f pod-rnaseq.yaml"
kubectl create --validate -f pod-rnaseq.yaml 

echo -e "\n\nkubectl get pods/rnaseq\n"
while [[ true ]]; do
        kubectl get pods/rnaseq
        rnaseqPod=`kubectl get pods/rnaseq | grep ExitCode`
        if [[ $rnaseqPod ]]; then
                break
        fi
        sleep 2
done

containerID=`docker ps -l=1 -q`

echo -e "\n\ndocker logs $containerID\n"
docker logs $containerID

