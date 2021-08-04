 #/bin/bash

echo "****************************"
echo "Configuring Dynamic NFS"
echo "****************************"


NAMESPACE=$(grep NAMESPACE env | awk -F '=' '{print $2}' | sed 's/"//g')

oc process -f template.yaml --param-file=env | oc create -n ${NAMESPACE} -f -


oc adm policy add-scc-to-user hostmount-anyuid system:serviceaccount:nfs-autoprovisioner:nfs-client-provisioner

