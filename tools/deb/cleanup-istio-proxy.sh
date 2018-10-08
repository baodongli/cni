#!/bin/bash
sudo docker stop `sudo docker ps -a | grep istio-proxy | grep -v k8s | awk '{print $1}'`
sudo docker rm `sudo docker ps -a | grep istio-proxy | grep -v k8s | awk '{print $1}'`
