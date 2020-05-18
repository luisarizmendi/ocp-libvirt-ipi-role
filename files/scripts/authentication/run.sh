 #/bin/bash

echo "****************************"
echo "Configuring Authentication"
echo "****************************"

## Create htpasswd file with users
#sudo yum install -y httpd-tools
#htpasswd -c -B -b users.htpasswd clusteradmin R3dhat01
#htpasswd -b users.htpasswd viewuser R3dhat01
#htpasswd -b users.htpasswd user1 R3dhat01
#htpasswd -b users.htpasswd user2 R3dhat01
#htpasswd -b users.htpasswd user3 R3dhat01
#htpasswd -b users.htpasswd user4 R3dhat01
#htpasswd -b users.htpasswd user5 R3dhat01
#htpasswd -b users.htpasswd user6 R3dhat01
#htpasswd -b users.htpasswd user7 R3dhat01
#htpasswd -b users.htpasswd user8 R3dhat01
#htpasswd -b users.htpasswd user9 R3dhat01
#htpasswd -b users.htpasswd user10 R3dhat01
#htpasswd -b users.htpasswd user11 R3dhat01
#htpasswd -b users.htpasswd user12 R3dhat01
#htpasswd -b users.htpasswd user13 R3dhat01
#htpasswd -b users.htpasswd user14 R3dhat01
#htpasswd -b users.htpasswd user15 R3dhat01
#htpasswd -b users.htpasswd user16 R3dhat01
#htpasswd -b users.htpasswd user17 R3dhat01
#htpasswd -b users.htpasswd user18 R3dhat01
#htpasswd -b users.htpasswd user19 R3dhat01
#htpasswd -b users.htpasswd user20 R3dhat01
#htpasswd -b users.htpasswd user21 R3dhat01
#htpasswd -b users.htpasswd user22 R3dhat01
#htpasswd -b users.htpasswd user23 R3dhat01
#htpasswd -b users.htpasswd user24 R3dhat01
#htpasswd -b users.htpasswd user25 R3dhat01


# Assign htpasswd file to auth provisioner and enable provisioner
oc create secret generic htpass-secret --from-file=htpasswd=users.htpasswd -n openshift-config
oc apply -f descriptors.yaml


# Create cluster admin
oc adm policy add-cluster-role-to-user cluster-admin clusteradmin


# Create groups
oc adm groups new developers user1 user2 user3 user4 user5 user6 user7 user8 user9 user10 user11 user12 user13 user14 user15 user99
oc adm groups new reviewers viewuser


# Assign roles to groups
oc adm policy add-cluster-role-to-group view reviewers
oc adm policy add-role-to-group admin developers


# Remove kubeadmin
#oc delete secrets kubeadmin -n kube-system
