# openshift-python

    * oc secret new-basicauth aki-github-cred --username=akilans --prompt

    * oc secrets link builder aki-github-cred

    * oc new-app https://github.com/akilans/openshift-python.git --strategy docker --name python-web-app --source-secret aki-github-cred

    * oc annotate secret/aki-github-cred 'build.openshift.io/source-secret-match-uri-1=https://github.com/akilans/openshift-python.git'

    * fgrep -RIl 127.0.0.1:8443 /home/centos/openshift.local.clusterup/ | xargs sed -i 's/127.0.0.1:8443/ec2-54-187-71-216.us-west-2.compute.amazonaws.com:8443/g'

    * ansible-playbook site.yaml -e web_url=http://localhost:8000