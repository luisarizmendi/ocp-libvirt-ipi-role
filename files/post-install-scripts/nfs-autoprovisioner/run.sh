 #/bin/bash

echo "****************************"
echo "Configuring Dynamic NFS"
echo "****************************"


oc process -f template.yaml --param-file=env | oc create -f -


oc adm policy add-scc-to-user hostmount-anyuid system:serviceaccount:nfs-autoprovisioner:nfs-client-provisioner

