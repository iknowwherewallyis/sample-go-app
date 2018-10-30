# sample-go-app
## Deploying sample application through Jenkins CICD pipeline to Minikube

This guide will go through the steps neccessary to deploy a docker registry, a Jenkins instance and the sample application to a Minikube cluster. The guide will go through the steps of building and pushing images needed for each of these components, and then deploying the sample application using a Jenkins pipeline job. The pipeline job will then update the docker image for the sample application whenever the job is run and redeploy the sample application with the latest image, if changes have been pushed to the Github repo for the sample application since the last time the job was run.

## Part 1: Deploying sample application through Jenkins CICD pipeline to Minikube

### Prerequisites:

- Install docker & enable sudo-less access (https://docs.docker.com/install/linux/docker-ce/ubuntu/)
- Install minikube (https://kubernetes.io/docs/tasks/tools/install-minikube/)
- Start minikube

### Step 1: 

Clone the repo: 

git clone https://github.com/iknowwherewallyis/sample-go-app/ 

### Step 3: 

Run the initialization script (init.sh) to do the following:
- Build and deploy a Docker registry inside Minikube
- Build and run and a proxy registry for ease of pushing images to a local registry
- Build and push image for the sample application to the registry
- Build, push & deploy Jenkins instance to the cluster
- Create the Timber.io secret for pushing logs to web dashboard
- Create the Timber logging agent to listen at the node level for pod logs

### Step 4:

Open Jenkins service in browser:
- minikube service jenkins

Get initial admin password and unlock Jenkins:
- kubectl exec -it <jenkins-pod-id> cat /var/jenkins_home/secrets/initialAdminPassword

- Install suggested plugins (come from plugins.txt) 

- Create initial user

- Save jenkins URL 

- Restart Jenkins

- Log in

### Step 5:

Create credentials for Jenkins and Kubernetes:

- Go to credentails section on menu on left-hand side of dashboard
- Click into "Jenkins" under "stores scoped to Jenkins"
- Hover over "global credentials (unrestricted)" and on drop down menu, select create new credentials
- On next page, pick Kubernetes configuration (kubeconfig) as "kind"
- ID is "sample-kubeconfig"
- Under kubeconfig, pick "from file on Jenkin's master" option and enter /var/jenkins_home/.kube/config
- Save credentials

Create pipeline job:

- Return to dashboard home
- Click "new item"
- Under name, enter "sample-app-production", and select "pipeline job", continue
- On next page, under "general" tab, pick "github project" checkbox and enter github URL
- Under "pipeline" section of job configuration, select "pipeline from SCM"
- Choose "git" as the SCM
- Enter URL for github repo
- Leave path to pipeline script as "Jenkinsfile" to use Jenkinsfile in root of project
- Save the job

### Step 8:

Run pipeline job manually:

- Click "build now" and watch the pipeline run through its steps
- Job is pulling code from github repo, so if no changes have been committed, docker image will not be updated and deployment will not be affected. However, if new changes commited since last time job was run, new version of docker image will be built and pushed to registry and deployment will change based on newest image
- Make changes to project code
- Push to repository
- Re-run the job and check deployment status

## Part 2: Creating staging Jenkins job based on "staging" branch:

### Step 1:

- Return to dashboard home
- Click "new item"
- Under name, enter "sample-app-staging", and select "pipeline job", continue
- On next page, under "general" tab, pick "github project" checkbox and enter github URL
- Under "pipeline" section of job configuration, select "pipeline from SCM"
- Choose "git" as the SCM
- Enter URL for github repo
- Change branch to "*/staging" under "branch specifier"
- Leave path to pipeline script as "Jenkinsfile" to use Jenkinsfile in root of project
- Save the job


### Step 2:

- Return to dashboard
- Kick off the job manually with the "build now" button
- See job complete and check registry ui to see the newly created "sample-app-staging" image




