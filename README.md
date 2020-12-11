Deployment of Red Hat ActiveMQ 7.6 into openshift.

Use the templates in this directory to deploy. 

There are several "flavors" of AMQ. 
The recommended version to deploy is the persistent broker. 

You may use these deployment templates as reference that can be modified to suit you specific needs.

Install ActiveMQ into Openshift
---------------------
To deploy Active MQ into a namespace :

Pre-Requisites : 
- Install latest Ansible on your Linux based system https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html
- Install the 'oc' tool; the command-line interface to Openshift.  Download the latest binary release here (https://github.com/openshift/origin/releases) and set the 'oc' executable on your path. 

You will use Ansible, along with the Ansible Applier (libraries maintained by Red Hat) to deploy the project into Openshift. (This simulates the technique used by the Pipeline, but will run from your local host instead of Jenkins pipeline.)  For reference the source code for the Ansible Applier project is here: https://github.com/redhat-cop/openshift-applier

Once above pre-requisites are installed, here are the steps used to install the project:

1) Login to openshift using the web console.
In Browser go to : https://ocp.mng-staging.dso.ncps.us-cert.gov:443   (URL dependent on deployment environment)
From the Openshift console Top Right, drop down select Your Name, and click "Copy Login Command" 
Once copied, open a command line shell, and "paste" the command line copied from the browser.
This will allow you to login from a (Linux) command line using the 'oc' command-line interface.  
The command will look something similar to this:

oc login https://ocp.mng-staging.dso.ncps.us-cert.gov:443 --token=6a9Q0nePHwSYXhRUs5r860fKaHL_43CjySwDqEqVDGQ

From command line, switch to namespace where you wish to deploy

oc project <namespace where you will deploy>

2) Set up shell environment.
From Linux command-line shell.

export TOKEN=$(oc whoami -t)
export SERVICE=activemq
export NAMESPACE=malware-nextgen-lcurry-dev
export OCP_URL=ocp.mng-staging.dso.ncps.us-cert.gov
export DOCKER_REPO_URL=docker-registry.default.svc:5000
export PROJECT_ENV=/home/lcurry/Malware/code/malware-integration/activemq

*Above PROJECT_ENV is dependent on your environment and assumes the code from git project has been cloned or forked and root of project repo exists in the specified location.
 
3) Run commands to deploy buildConfig into Openshift namespace

cd $PROJECT_ENV/_openshift
chmod u+x deploy  
./deploy -e filter_tags=create-build-config-local -e include_tags=create-build-config-local -e service=$SERVICE -e namespace_name=$NAMESPACE -e image_namespace_name=$NAMESPACE -e docker_repo_url=$DOCKER_REPO_URL -e ocp_url=$OCP_URL -e ocp_token=$TOKEN -e ocp_login_skip_tls_verify=true

4) Trigger buildConfig using local source code (Dockerfile). The following commands will trigger Openshift to build the project image from the Dockerfile located in your local directory. These commands must be run from root of project and will feed the Dockerfile (and any files it needs from local directory) into Openshift.
 
cd $PROJECT_ENV
oc start-build activemq --from-dir . --follow  -n $NAMESPACE 
If above successfull, proceed to deploy step 

5) Deploy Step.  Add the deploymentConfig meta information to your Openshift Namespace.  This will trigger the deployment of the POD into your namespace within Openshift. 

cd $PROJECT_ENV/_openshift
./deploy -e apps_subdomain=$OCP_URL -e image_version=latest -e filter_tags=deploy-local -e include_tags=deploy-local -e target_environment=dev -e service=$SERVICE -e docker_repo_url=$DOCKER_REPO_URL -e namespace_name=$NAMESPACE -e image_namespace_name=$NAMESPACE -e ocp_url=$OCP_URL -e ocp_token=$TOKEN -e ocp_login_skip_tls_verify=true
 	

Delete all from namespace
-----------
If you need to remove all artifacts related to this project from your namespace,ake sure you are in your own namespace, otherwise you risk deleting objects from another (potentially shared) namespace. The first command will set env variable to the namespace where you wish to delete the deployment. 

$ export NAMESPACE=malware-nextgen-lcurry-dev
$ export SERVICE=activemq
$ oc project $NAMESPACE
$ oc delete all,configmap,pvc,serviceaccount,rolebinding,secret --selector app=$SERVICE

$$(SERVICE) 


