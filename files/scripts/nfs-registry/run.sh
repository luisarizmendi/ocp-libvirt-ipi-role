 #/bin/bash


/usr/local/bin/oc process -f template.yaml --param-file=env | /usr/local/bin/oc create -f -


RESOURCE="cluster"
while [[ $(/usr/local/bin/oc get configs.imageregistry.operator.openshift.io cluster | grep $RESOURCE  > /dev/null ; echo $?) != "0" ]]; do echo "Waiting for $RESOURCE object" && sleep 10; done




/usr/local/bin/oc patch configs.imageregistry.operator.openshift.io cluster --type='json' -p='[{"op": "replace", "path": "/spec/managementState", "value": "Managed" },{"op": "remove", "path": "/spec/storage" },{"op": "add", "path": "/spec/storage", "value": {"pvc":{"claim": ""}}}]'
