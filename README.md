# OpenShift - Python - Ansible



Setting up Openshift cluster for local Dev/Test environment, explore the capabilities of Openshift by deploying sample python web application and test the deployed web application using ansible



## Note



These instructions will get you a OpenShift up and running on your local machine for development and testing purposes.



### Tech/Tools/Framework used



* [python](https://www.python.org/)

* [Flask](http://flask.pocoo.org/)

* [Centos7](https://www.centos.org/)

* [OpenShift](https://www.openshift.com/)

* [OKD](https://www.okd.io/)

* [Docker](https://www.docker.com/)

* [Ansible](https://www.ansible.com/)



### Prerequisites



This solution is setup and tested on Centos7



```

CentOS7

Python3

```


### OpenShift Installation


The following commands will set up Openshift on CentOS7 using OC client tool. Login into the CentOS7 machine and run the commands as root user. This installs Ansible, Docker 1.13 and OC 3.11. 


```bash

yum update -y

rpm --import "https://sks-keyservers.net/pks/lookup?op=get&search=0xee6d536cf7dc86e2d7d56f59a178ac6c6238f52e"

yum install -y yum-utils wget git ansible

yum-config-manager --add-repo https://packages.docker.com/1.13/yum/repo/main/centos/7

yum makecache fast

yum install -y docker-engine-1.13.1.cs9-1.el7.centos

systemctl enable docker.service

systemctl start docker.service

wget https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz

tar -xf openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz -C /usr/local/bin/ --strip-components=1

```

#### Manage Docker as a non-root user


```bash
# Allow user to run docker commands
sudo usermod -aG docker $USER

```


#### Configure the Docker daemon with an insecure registry parameter of 172.30.0.0/16


edit the /etc/docker/daemon.json file and add the following:


```json

    {

        "insecure-registries": [

            "172.30.0.0/16"

        ]

    }

```


After editing the config, reload *systemd* and restart the Docker daemon.


```bash

sudo systemctl daemon-reload

sudo systemctl restart docker

```

Run *oc cluster up* to run OpenShift cluster with public host name or public ip. This will take sometime to download and install Openshift


```bash
# Run openshift cluster
oc cluster up --public-hostname=$HOSTNAME/$IP 

```

#### Important Note


While running the above command, OpenShift web UI redirects the console to https://127.0.0.1:8443 by default. This is the known [issue](https://github.com/openshift/origin/issues/20726) of OpenShift.


To fix the above mentioned issue, run the below command and restart the cluster.


```bash
# Run as a root user
fgrep -RIl 127.0.0.1:8443 /home/centos/openshift.local.clusterup/ | xargs sed -i 's/127.0.0.1:8443/$HOSTNAME:8443/g'

oc cluster down

oc cluster up --public-hostname=$HOSTNAME/$IP

```

OpenShift is now set up and would be up and running at https://$HOSTNAME:8443

![OpenShift Web UI](screenshot/1_openshift_web_ui.png?raw=true "OpenShift Web UI")

## Python flask web application setup, unittest and Dockerfile

This repository has sample "Hello World" application written in python using Flask framework. Clone this repository and run the below commands to test and run the python web application locally


```bash

#Install all the dependencies
pip install -r requirements.txt

# Run the unit test
python -m unittest test_flask_app

# Run the application locally
python flask_app.py

```

Access the web page by URL http://localhost:8000. 

## Deploy flask web application on OpenShift


Before deploying to Openshift, add github credentials as secret and deploy the application using Docker strategy by running the below commands.


```bash
# Login into openshift cluster
oc login -u system:admin

# Create secret
oc secret new-basicauth aki-github-cred --username=akilans --prompt

# Link the secrent to Openshift builder
oc secrets link builder aki-github-cred

# Deploy the application usind Docker strategy
oc new-app https://github.com/akilans/openshift-python.git --strategy docker --name python-web-app --source-secret aki-github-cred

# Expose the service. It creates route
oc expose service python-web-app

```

Create a storage in OpenShift and attach that to python-web-app deployment on /mnt folder using web console. Set "WRITE_FOLDER" as ENV variable with "/mnt" value, so that next version of python application writes files into /mnt folder

## Modify flask web application to test persistent storage

Uncomment the below code in flask_app.py file and push it github repo. The below code writes "hello word with timestamp" on file called "hello.txt" under /tmp every 10 seconds interval by default if there is no "WRITE_FOLDER" ENV variable.

```python

# Cron Job at 10 seconds interval

import time

import atexit

import os


from apscheduler.schedulers.background import BackgroundScheduler


def print_hello_timestamp(folder):

    file = open(os.path.join(folder,'hello.txt'), 'a+')

    file.write(time.strftime("%m/%d/%Y %H:%M:%S ")+ "Hello Word \n")

    file.close()


write_folder = str(os.environ.get("WRITE_FOLDER", "/tmp"))

scheduler = BackgroundScheduler()

scheduler.add_job(func=print_hello_timestamp, args=[write_folder], trigger="interval", seconds=10)

scheduler.start()


# Shut down the scheduler when exiting the app

atexit.register(lambda: scheduler.shutdown())

```


## Redeploy the application to test persistent storage


Run the below command to redeploy the new version of python application. This time it will not ask for git credentials as we already binded the git secrets to the build


```bash
# Trigger the build
oc start-build python-web-app 

```

### Testing persistent storage

Delete the pod and test whether the data persists or not by logging into container terminal and run the below command.

```bash
# Prints content of hello.txt file
tail -f /mnt/hello.txt

```

![File storage](screenshot/2_file_data.png?raw=true "File storage")

## Ansible playbook to test the deployed application


We have already installed ansible in our first step and added ansible playbook under ansible folder. Go inside the ansible folder path and run the playbook to test whether the deployed application is up and the corresponding volume mount details. Web application URL [Generated when we exposed the application] is passed as a parameter.


```bash

ansible-playbook site.yaml -e web_url=http://python-web-app-myproject.127.0.0.1.nip.io/

```
