# openshift-python

    * oc secret new-basicauth aki-github-cred --username=akilans --prompt

    * oc secrets link builder aki-github-cred

    * oc new-app https://github.com/akilans/openshift-python.git --strategy docker --name python-web-app --source-secret aki-github-cred

    * oc annotate secret/aki-github-cred 'build.openshift.io/source-secret-match-uri-1=https://github.com/akilans/openshift-python.git'

    * 