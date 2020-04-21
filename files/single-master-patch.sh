#!/bin/bash

failing  > /dev/null 2>&1

while [ $? -ne 0 ]
do
  #touch /tmp/attempts ; echo "Attempt to patch" >> /tmp/attempts
  sleep 15
  oc --kubeconfig ~/ocp/install/auth/kubeconfig patch etcd cluster -p='{"spec": {"unsupportedConfigOverrides": {"useUnsupportedUnsafeNonHANonProductionUnstableEtcd": true}}}' --type=merge
done
