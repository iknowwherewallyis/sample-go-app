# sample-go-app
## Deploying sample application through Jenkins CICD pipeline to Minikube

This guide will go through the steps neccessary to deploy a docker registry, a Jenkins instance and the sample application to a Minikube cluster. The guide will go through the steps of building and pushing images needed for each of these components, and then deploying the sample application using a Jenkins pipeline job. The pipeline job will then update the docker image for the sample application whenever the job is run and redeploy the sample application with the latest image, if changes have been pushed to the Github repo for the sample application since the last time the job was run.

## Part 1: Deploying sample application through Jenkins CICD pipeline to Minikube

### Step 1:

Install docker
Install minikube 
Start minikube

### Step 2: 

Clone the repo: 

git clone https://github.com/iknowwherewallyis/sample-go-app/ 

### Step 3: 

Create registry image
kubectl apply -f k8s/proxy-registry/docker-registry.yaml
Open registry-ui
minikube service registry-ui

### Step 4:

Build sample-app image 
docker build -t 127.0.0.1:30400/sample-app:`git rev-parse --short HEAD` -f src/Dockerfile src/

Create socat proxy to push to registry
docker build -t socat-registry -f k8s/proxy-registry/Dockerfile k8s/proxy-registry
docker stop socat-registry; docker rm socat-registry;  docker run -d -e "REG_IP=`minikube ip`" -e "REG_PORT=30400"   --name socat-registry -p 30400:5000 socat-registry

Push sample-app image
docker push 127.0.0.1:30400/sample-app:`git rev-parse --short HEAD`

### Step 5:

Build jenkins image
docker build -t 127.0.0.1:30400/jenkins:latest -f k8s/jenkins/Dockerfile k8s/jenkins

Push to registry
docker push 127.0.0.1:30400/jenkins:latest

Stop proxy container
docker stop socat

### Step 6: 

Create jenkins deployment using kubectl apply
kubectl apply -f k8s/jenkins/jenkins.yaml (might take a few mins to download image)

Open service in browser
minikube service jenkins

Set initial pwd/create user
kubectl exec -it jenkins-758dcff45b-n4wzk cat /var/jenkins_home/secrets/initialAdminPassword

Install suggested plugins (come from plugins.txt) 

Create initial user

Save jenkins URL 

Restart Jenkins

Log in

### Step 7:

Create credentials for Jenkins and Kubernetes

Go to credentails section on menu on left-hand side of dashboard
Click into "Jenkins" under "stores scoped to Jenkins"
Hover over "global credentials (unrestricted)" and on drop down menu, select create new credentials
On next page, pick Kubernetes configuration (kubeconfig) as "kind"
ID is "sample-kubeconfig"
Under kubeconfig, pick "from file on Jenkin's master" option and enter /var/jenkins_home/.kube/config
Save credentials

Create pipeline job

Return to dashboard home
Click "new item"
Under name, enter "sample-app-production", and select "pipeline job", continue
On next page, under "general" tab, pick "github project" checkbox and enter github URL
Under "pipeline" section of job configuration, select "pipeline from SCM"
Choose "git" as the SCM
Enter URL for github repo
Leave path to pipeline script as "Jenkinsfile" to use Jenkinsfile in root of project
Save the job

### Step 8:

Run pipeline job manually
Click "build now" and watch the pipeline run through its steps
Job is pulling code from github repo, so if no changes have been committed, docker image will not be updated and deployment will not be affected. However, if new changes commited since last time job was run, new version of docker image will be built and pushed to registry and deployment will change based on newest image

Make changes to project
Push to github
Re-run the job and check deployment status

## Part 2: Creating staging Jenkins job based on "staging" branch:

### Step 1:
Return to dashboard home
Click "new item"
Under name, enter "sample-app-staging", and select "pipeline job", continue
On next page, under "general" tab, pick "github project" checkbox and enter github URL
Under "pipeline" section of job configuration, select "pipeline from SCM"
Choose "git" as the SCM
Enter URL for github repo
Change branch to "*/staging" under "branch specifier"
Leave path to pipeline script as "Jenkinsfile" to use Jenkinsfile in root of project
Save the job


### Step 2:
Return to dashboard
Kick off the job manually with the "build now" button
See job complete and check registry ui to see the newly created "sample-app-staging" image


## Part 3: Logging:

### Step 1:
Create kubernetes secret for timber api
kubectl create secret generic timber --from-literal=timber-api-key=5859_59bf824defa381d9:9ea4764a756dcb4075161cd34080229dd6864af63e92e4b3acec6e8344bb6a4a

### Step 2:
Create the timber dameon-set logging agent:
kubectl create -f k8s/timber.yaml


### Step 3:
View logs for all pods in timber.io dashboard



