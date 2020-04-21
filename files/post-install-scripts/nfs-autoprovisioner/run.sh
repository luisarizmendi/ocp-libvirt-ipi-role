 #/bin/bash

echo "****************************"
echo "Configuring Dynamic NFS"
echo "****************************"

oc process -f template.yaml --param-file=env | oc create -f -

oc adm policy add-scc-to-user hostmount-anyuid -n nfs-autoprovisioner -z nfs-client-provisioner
