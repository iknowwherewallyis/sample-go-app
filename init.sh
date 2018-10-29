#!/bin/bash

set -e

echo "-------------------------------------------"
echo "INIT SCRIPT TO DEPLOY SAMPLE APP, DOCKER REGISTRY AND JENKINS"
echo "-------------------------------------------"

kubectl apply -f k8s/proxy-registry/docker-registry.yaml
kubectl rollout status deployments/registry
echo "Registry rolled out"

echo "Building sample-app docker image..."
docker build -t 127.0.0.1:30400/sample-app:`git rev-parse --short HEAD` -f src/Dockerfile src/

echo "Building proxy registry image"
docker build -t socat-registry -f k8s/proxy-registry/Dockerfile k8s/proxy-registry

echo "Starting proxy registry container..."
docker run -d -e "REG_IP=`minikube ip`" -e "REG_PORT=30400"   --name socat-registry -p 30400:5000 socat-registry

echo "Pushing sample-app image to registry container"
docker push 127.0.0.1:30400/sample-app:`git rev-parse --short HEAD`

echo "Building jenkins image for use in deployment..."
docker build -t 127.0.0.1:30400/jenkins:latest -f k8s/jenkins/Dockerfile k8s/jenkins

echo "Pushing jenkins image to registry container"
docker push 127.0.0.1:30400/jenkins:latest

echo "Stopping proxy registry container..."
docker stop socat-registry; docker rm socat-registry;

echo "Deploying Jenkins components..."
kubectl apply -f k8s/jenkins/jenkins.yaml

kubectl rollout status deployments/jenkins

echo "-------------------------------------------"
echo "DEPLOY KUBERNETES SECRET, LOGGING AGENT DAEMONSET"
echo "-------------------------------------------"

echo "Create kubernetes secret for timber api"
kubectl create secret generic timber --from-literal=timber-api-key=5870_9b802cc5429fe987:0146a54598dae5497c56297d4412eb755051f54a0516dc219c5d4538c59ab750

echo "Create the timber dameon-set logging agent"
kubectl create -f k8s/timber.yaml


echo "-------------------------------------------"
printf "Done, all components deployed successfully. access the Jenkins UI by running minikube service jenkins\n"
printf "Access the Registry UI by running minikube service registry-ui\n"
echo "View logs for all pods in timber.io dashboard
login at https://app.timber.io/auth/login
username: ccttestlogs2018@gmail.com
password: password"
echo "-------------------------------------------"


