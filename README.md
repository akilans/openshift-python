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
yum install -y yum-utils wget git
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