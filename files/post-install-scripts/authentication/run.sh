 #/bin/bash

echo "****************************"
echo "Configuring Authentication"
echo "****************************"

## Create htpasswd file with users
sudo yum install -y httpd-tools
htpasswd -c -B -b users.htpasswd clusteradmin $CLUSTERADMIN_PASSWORD
htpasswd -b users.htpasswd viewuser $USERS_PASSWORD
htpasswd -b users.htpasswd user1 $USERS_PASSWORD
htpasswd -b users.htpasswd user2 $USERS_PASSWORD
htpasswd -b users.htpasswd user3 $USERS_PASSWORD
htpasswd -b users.htpasswd user4 $USERS_PASSWORD
htpasswd -b users.htpasswd user5 $USERS_PASSWORD
htpasswd -b users.htpasswd user6 $USERS_PASSWORD
htpasswd -b users.htpasswd user7 $USERS_PASSWORD
htpasswd -b users.htpasswd user8 $USERS_PASSWORD
htpasswd -b users.htpasswd user9 $USERS_PASSWORD
htpasswd -b users.htpasswd user10 $USERS_PASSWORD
htpasswd -b users.htpasswd user11 $USERS_PASSWORD
htpasswd -b users.htpasswd user12 $USERS_PASSWORD
htpasswd -b users.htpasswd user13 $USERS_PASSWORD
htpasswd -b users.htpasswd user14 $USERS_PASSWORD
htpasswd -b users.htpasswd user15 $USERS_PASSWORD
htpasswd -b users.htpasswd user16 $USERS_PASSWORD
htpasswd -b users.htpasswd user17 $USERS_PASSWORD
htpasswd -b users.htpasswd user18 $USERS_PASSWORD
htpasswd -b users.htpasswd user19 $USERS_PASSWORD
htpasswd -b users.htpasswd user20 $USERS_PASSWORD
htpasswd -b users.htpasswd user21 $USERS_PASSWORD
htpasswd -b users.htpasswd user22 $USERS_PASSWORD
htpasswd -b users.htpasswd user23 $USERS_PASSWORD
htpasswd -b users.htpasswd user24 $USERS_PASSWORD
htpasswd -b users.htpasswd user25 $USERS_PASSWORD


# Assign htpasswd file to auth provisioner and enable provisioner
oc create secret generic htpass-secret --from-file=htpasswd=users.htpasswd -n openshift-config
oc apply -f descriptors.yaml


# Create cluster admin
oc adm policy add-cluster-role-to-user cluster-admin clusteradmin


# Create groups
oc adm groups new developers user1 user2 user3 user4 user5 user6 user7 user8 user9 user10 user11 user12 user13 user14 user15 user16 user17 user18 user19 user20 user21 user22 user23 user24 user25
oc adm groups new reviewers viewuser


# Assign roles to groups
oc adm policy add-cluster-role-to-group view reviewers
oc adm policy add-role-to-group admin developers


# Remove kubeadmin
#oc delete secrets kubeadmin -n kube-system
