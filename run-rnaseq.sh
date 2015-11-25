#!/bin/bash

kubectl delete pods/rnaseq

kubectl create --validate -f pod-rnaseq.yaml 

while [[ true ]]; do
        kubectl get pods/rnaseq
        rnaseqPod=`kubectl get pods/rnaseq | grep ExitCode`
        if [[ $rnaseqPod ]]; then
                break
        fi
        sleep 2
done

containerID='docker ps -l=1 -q'

docker logs $containerID

