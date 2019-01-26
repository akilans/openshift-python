# OpenShift - Python - Ansible

Setting up Openshift Cluster for local Dev/Test environment, explore the capabilities of Openshift by Deploying sample python web application and test the deployed web application using ansible

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

This whole setup tested on Centos7

```
CentOS7
Python3

```

### OpenShift Installation

The follwing commands used to setup Openshift on CentOS7 using OC client tool. Login into CentOS7 machine and run the commands as root user. This installs Docker 1.13 and OC 3.11. 

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

Manage Docker as a non-root user

```bash
sudo usermod -aG docker $USER
```

Configure the Docker daemon with an insecure registry parameter of 172.30.0.0/16

edit the /etc/docker/daemon.json file and add the following:

```json
    {
        "insecure-registries": [
            "172.30.0.0/16"
        ]
    }
```

After editing the config, reload systemd and restart the Docker daemon.

```bash
sudo systemctl daemon-reload
sudo systemctl restart docker
```

Run oc cluster up to run OpenShift cluster with public host name or public ip. This wil take sometime to download and install Openshift

```bash
oc cluster up --public-hostname=$HOSTNAME/$IP 
```
#### Important Note

While running the above command, OpenShift Web UI redirects the console to https://127.0.0.1:8443 by default. This is the known [issue](https://github.com/openshift/origin/issues/20726) of OpenShift.

To fix the above mentioned issue, run the below command and restart the cluster.

```bash

fgrep -RIl 127.0.0.1:8443 /home/centos/openshift.local.clusterup/ | xargs sed -i 's/127.0.0.1:8443/$HOSTNAME:8443/g'

oc cluster down
oc cluster up --public-hostname=$HOSTNAME/$IP

```
Now OpenShift will be up and running with https://$HOSTNAME:8443

## Python Flask Web Application Setup, Unittest and Dockerfile

Run the bellow commands to test and run the python web application locally

```bash

pip install -r requirements.txt
python -m unittest test_flask_app
python flask_app.py

```

Access the web page by URL http://localhost:8000. If it works successfully then add Dockerfile to containerize this application and push all the source code to private repository.

## Deploy Flask web Application on OpenShift

Add github credentials as secret in openshift and deploy the application using Docker strategy by running the below commands.

```bash

oc login -u system:admin
oc secret new-basicauth aki-github-cred --username=akilans --prompt
oc secrets link builder aki-github-cred
oc new-app https://github.com/akilans/openshift-python.git --strategy docker --name python-web-app --source-secret aki-github-cred
oc expose service python-web-app

```

Create a storage in OpenShift and Attach that to python-web-app Deployment on /mnt folder using web console. Add "WRITE_FOLDER" ENV variable to /mnt folder, so that next version of python application writes files into /mnt folder

## Modify Flask web Application to test Persistent Storage

Uncomment the bellow code in flask_app.py file and push it github repo. The below code write hello word with timestamp on /tmp every 10 seconds interval by default of there is no "WRITE_FOLDER" ENV variable.

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

## ReDeploy the Application to test Persistent Storage

Run the below command to dedeploy the new version of python application. This time it will not ask for git credentials as we already binded the git secrets to build

```bash
oc start-build python-web-app 
```

Delete the pod and test whether the data persists or not by logging into container terminal.

```bash
tail -f /mnt/hello.txt
```

## Ansible playbook to test the Deployed Application

We already installed Ansible in our first step. Go inside ansible folder and run the playbook to test whether the deployed application is up or not and volume mount details.We can pass web application URL as a parameter.

```bash
ansible-playbook site.yaml -e web_url=http://python-web-app-myproject.127.0.0.1.nip.io/
```