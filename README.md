Role Name
=========

Deploy OpenShift 4 on a CentOS 7 or Fedora KVM using libvirt IPI

Requirements
------------

CentOS 7 or Fedora (tested in Fedora 31) host, the one included in the inventory file and that will host and launch the OpenShift cluster.

It has been tested with OpenShift 4.4 (I'm not sure about backwards compatibility)

You need to prepare the install-config.yaml file, including:

* Your Pull secret from [https://cloud.redhat.com/](https://cloud.redhat.com/)
* KVM IP
* Cluster name
* Domain
* Public SSH key
* Number of masters (1 or 3) and workers (0,1,2...or more)


This is a template example:

```
apiVersion: v1
baseDomain: < my.domain >
compute:
- architecture: amd64
  hyperthreading: Enabled
  name: worker
  platform: {}
  replicas: 2
controlPlane:
  architecture: amd64
  hyperthreading: Enabled
  name: master
  platform: {}
  replicas: 3
metadata:
  creationTimestamp: null
  name: ocp
networking:
  clusterNetwork:
  - cidr: 10.128.0.0/14
    hostPrefix: 23
  machineNetwork:
  - cidr: 192.168.126.0/24
  networkType: OpenShiftSDN
  serviceNetwork:
  - 172.30.0.0/16
platform:
  libvirt:
    URI: qemu+tcp://< kvm ip >/system
    network:
      if: tt0
publish: External
pullSecret: '< pull secret >'
sshKey: |
  < ssh key >
```



Role Variables
--------------

There are some variables that you will need to modify to configure the environment as per your needs:

* ocp_install_file_path

      description: Path to the pre-configured install-config.yaml

      default: "ocp-config/install-config.yaml"

* ocp_release

      description: OCP release number from https://mirror.openshift.com/pub/openshift-v4/clients/ocp

      default: "4.4.0"

* ocp_git_branch

      description: OpenShift installer branch name from https://github.com/openshift/installer

      default: "release-4.4"

* ocp_install_install_release_image_override

      description: OCP release image from https://quay.io/repository/openshift-release-dev/ocp-release?tag=latest&tab=tags

      default: "quay.io/openshift-release-dev/ocp-release:4.4.0-rc.8-x86_64"

* ocp_master_memory

      description: Memory (in MB) for Master nodes

      default: 16384

* ocp_master_cpu

      description: Number of cores for Master nodes

      default: 4

* ocp_master_disk

      description: Disk size (in GB) for Master nodes

      default: 120

* ocp_worker_memory

      description: Memory (in MB) for Master nodes

      default: 8192

* ocp_worker_cpu

      description: Number of cores for Worker nodes

      default: 2

* ocp_worker_disk

      description: Disk size (in GB) for Worker nodes

      default: 120

* kvm_interface

      description: Public interface of the KVM host (from where the OCP VMs will be published)

      default: "eth0"


There are other variables that shouldn't be modify unless you have


* kvm_install

      description: If "true" the role will install and prepare the KVM service

      default: "true"

* kvm_configure

      description: If "true" the role will configure KVM service so libvirt IPI can use it

      default: "true"

* nfs_storage

      description: If "true" NFS storage and a storageclass for dynamic PV provisioning (it’s no supported in Openshift, but it works for testing) will be configured. ou could want to avoid configuring NFS if, for example, you want to install on a laptop and you don’t want to install anything else on your machine. If false only ephemeral storage will be available after the install.

      default: "true"

* lb

      description: If true the role will install and configure haproxy to load balance API among masters and routers between workers. If not true only the first master (API) and to the first worker (APPS) will be getting external requests.

      default: "true"

* kvm_publish

      description: If "true" the role will configure IPTABLES so external request will be forwarded to either the load balancer (if lb = "true") ot to the first master (API) and to the first worker (APPS) (or only to first master if no workers are setup). If "false" the environment will only be available locally to the KVM.

      default: "true"

* ocp_prepare

      description: If "true" the role will prepare the host to launch the OpenShift installation

      default: "true"

* ocp_install

      description: If "true" the role will use the host to launch the OpenShift installation

      default: "true"

* ocp_create_users

      description: If "true" local users will be created. One cluster-wide admin (clusteradmin / R3dhat01), 25 users (userXX / R3dhat01) included in a group ´developers´ and one cluster wide read only user (viewuser / R4dhat01) included in a group called `reviewers`. You can disable it by configuring `ocp_create_users` to `false` or change the usernames or passwords modifying the htpasswd file located in the post-install-scripts directory inside the `files` directory

      default: "true"



Example Playbook
----------------

You can create a playbook (let's say `ocp_libvirt_ipi.yaml`), an inventory file with the KVM node details and you are good to import the role.

Find below a playbook example where we call the role and include the variables to customize the environment

```
---
- hosts: all
  roles:
    - role: ocp-libvirt-ipi
      vars:
        ocp_install_file_path: "ocp-config/install-config.yaml"
        ocp_release: "4.4.0-rc.8"
        ocp_git_branch: release-4.4
        ocp_install_install_release_image_override: "quay.io/openshift-release-dev/ocp-release:4.4.0-rc.8-x86_64"
        ocp_master_memory: 16384
        ocp_master_cpu: 4
        ocp_master_disk: 150
        ocp_worker_memory: 20480
        ocp_worker_cpu: 4
        ocp_worker_disk: 150
        kvm_interface: eno1
```

Inventory file does not need any fancy stuff, this is an example:

```
kvm-node ansible_host=1.2.3.4 ansible_port=22 ansible_user=larizmen
```

So one probably directory structure that you could have to support the playbook (`ocp_libvirt_ipi.yaml` in this example) would be this one:

```
.
├── ansible.cfg
├── ansible.log
├── inventory
├── ocp-config
│   └── install-config.yaml
├── ocp_libvirt_ipi.yaml
└── roles
    └── ocp_libvirt_ipi
        └── ...
...
```

After the playbook and the inventory are created you can use them to install (`tags` = `install`) and configure OpenShift :

```
ansible-playbook -vv -i <path to inventory> --tags install <path to playbook>
```

Or to remove (`tags` = `remove`) OpenShift and clean up the node:

```
ansible-playbook -vv -i <path to inventory> --tags remove <path to playbook>
```


Author Information
------------------

Luis Javier Arizmendi Alonso


Extended Information
-----------------

Should I read this? Maybe, it might be interesting if you want to :

* better know how install OpenShift in a Fedora or CentOS7 node using libvirt IPI
* know the details about how to run OpenShift 4.4+ All-in-One setup
* know more about how to customize OpenShift installations, including modifying and compiling the OpenShift installer (I should include here 10k+ "not-supported, only for labs" disclaimers)

Let's start why you should be using this Ansible role...

Imagine that you have a baremetal node running (a not too old) Fedora or a CentOS7 (or a PC/Laptop with a good amount of RAM and CPU) and you want to run an OpenShift LAB on them, but you don't want to use [CodeReady Containers](https://developers.redhat.com/products/codeready-containers/overview) because of multiple reasons, for example because you want to test the latest (or specific) bits, because you need more than one VM running OpenShift, or because you want the flexibility to build the lab as you want. In that case you could use multiple installation paths, for example simulating baremetal UPI, or using libvirt hooks but there is another way to do it that will bring extended capabilities (Machine API): [OpenShift libvirt IPI](https://github.com/openshift/installer/blob/master/docs/dev/libvirt/README.md).

OpenShift libvirt IPI is not intended to be used for installing production systems but it's quite helpful simplifying...well..."simplifying" (because you need some tips & tricks to make libvirt IPI work at this moment) the deployment on a KVM node. It's available from OpenShift 4.3 so it's quite new, thus there are multiple aspects that have to be taken into account, and that's why I made this Ansible Role.


More details about the installation
-----------------

The scripts will make use of libvirt IPI installation. The steps made by my scripts are based on https://github.com/openshift/installer/blob/master/docs/dev/libvirt/README.md

By default, masters will be using 16GB of RAM, 120 GB of disk and 4 vcores per node and workers 8GB of RAM, 120 GB of disk and 2 vcores. Those are the minimum requirements according to documentation (although 16GB of disk is enough if you don't want to use ephemeral). Bear in mind that you will need +2GB and 2 cores in your KVM node for bootstrap while installing (remember that OpenShift bootstrap VM is deleted during the installation steps).

You can choose to run a full OpenShift installation (with 3 masters and 2+ nodes), just 3 masters with no workers (masters will run both master and worker roles) or just 1 master (all-in-one). The all-in-one setup would need at least 16GB and 4 cores but put as much RAM and cores you can add, and also take into account the ephemeral storage, depending if you are going to use NFS or not (see below).

You will need to configure just the API and the APPS wildcard to use the environment, although you can always play with the /etc/hosts if you don't have a chance to configure a DNS (or configure a nip.io domain that includes the wildcard that you need).

This IPI installation won't need that you configure an external load balancer (although you can install it with just adjusting `lb`= "true" in the inventory file), any HTTP server or that you configure SRV in an external DNS.

You won't need to configure a Load Balancer because in the KVM iptables rule will be configured to forward 6443 to the first master and 443 and 80 to the first worker. That's OK if you are thinking about using 1 master and 1 or 1 workers or a all-in-one setup (in case that you don't deploy workers, all traffic will be to the first master), but if you plan to have multiple masters and workers, configuring a load balancer is a good idea because in case than more than 2 workers are deployed there is a chance that the router won't run on the first worker node where the iptables are forwarding. If you want to run HA tests you will need to install including a load balancer.

One last thing is that scripts were tested starting with OCP 4.4 (release candidate) and probably they will work for 4.4+ releases but won't be tested with previous versions.

What are those tips & tricks?
-----------------

Inside the playbooks there are some configurations that were needed to make the installation more flexible or even to make it finish. Some of then are in the steps that you can find in the [libvirt IPI repo](https://github.com/openshift/installer/blob/master/docs/dev/libvirt/README.md), but others are not...I will describe them in the order that are performed in my playbooks:

### Libvirt config

Apart from installing libvirt and enabling IP forwarding, libvirt IPI will need to "talk" with the server, so We'll need to accept TCP connections by configuring the appropriate variables in libvirtd.conf and running the service with `--listen`. This is well explained in the [libvirt IPI repo](https://github.com/openshift/installer/blob/master/docs/dev/libvirt/README.md)


### Build the OpenShift installer with libvirt IPI support

Libvirt IPI is not included in the installer software by default. In order to "activate" it, you need to build the installer from source including its support, so you have to clone the [OpenShift installer GitHub repo](https://github.com/openshift/installer) and then use the build script (`hack/build.sh`) but including the variable TAGS setup to TAPS=libvirt

`TAGS=libvirt hack/build.sh`

..but before running that script to make the build, I applied two changes to the code (shown below).

This is important...wait just for a moment and think about it... you can do all of this because **IT IS OPEN SOURCE**. It would be impossible if we were using close-source Software...


#### Custom disk size in OpenShift nodes

All (supported) IPI providers have a way to modify the created VM resources (CPU, memory and disk). In the libvirt IPI case you can modify the CPU and memory using the manifest (see below) just changing the values that are already there. [In order to change the worker nodes disk size you have to include an additional variable that is not in the manifest by default](https://github.com/openshift/installer/issues/2338), but it works. The problem [is that the code is not (yet?) prepared to allow master nodes disk size changes](https://github.com/openshift/cluster-api-provider-libvirt/pull/175) so the only way to do it is by [adding the 'size' variable](https://github.com/openshift/installer/pull/2652/commits/5e46b881675cda0613233574b0b70531b4a82a31) in the code in file `data/data/libvirt/main.tf` including the size in bytes.

```
...
resource "libvirt_volume" "master" {
  size           = < size >
  count          = var.master_count
  name           = "${var.cluster_id}-master-${count.index}"
  base_volume_id = module.volume.coreos_base_volume_id
  pool           = libvirt_pool.storage_pool.name
}
...
```

The reason why masters are not that flexible is that for LABs, with the default disk size you are good to go....but maybe there is one use case where you want to increase the disk size, and that's when you want to run an All-in-One setup (this is allowed in my playbooks) because the master will need to run the workloads as well (even more important if you don't have configured any storage backend to have PVs).


#### Custom timeouts in the OpenShift installer

When running the install in a dedicated hardware with plenty of resources the default timeouts are ok... but this installer is intended to be used even in Laptops, so sometimes it takes longer than that. The only way to modify the timeouts of the openshift installer at this moment (I'm not sure that this will change) is modifying the code.

There different timers:
* [Waiting for bootstrap Kubernetes API (default 20 minutes)](https://github.com/wking/openshift-installer/blob/master/cmd/openshift-install/create.go#L255)
* [Waiting for bootstrap to complete (40 minutes)](https://github.com/wking/openshift-installer/blob/master/cmd/openshift-install/create.go#L295)
* [Waiting for confirmation that the cluster has been initialized (30 minutes, or 60 minutes if it's a baremetal installation)](https://github.com/wking/openshift-installer/blob/master/cmd/openshift-install/create.go#L334)
* [Wating for Console URL from the route 'console' in namespace openshift-console (default 10 minutes)](https://github.com/wking/openshift-installer/blob/master/cmd/openshift-install/create.go#L412)


### Custom RAM and CPU in OpenShift VMs (and custom size in Worker nodes)

We already review that we could need to change the default disk size (only 16GB) reserved for our OpenShift nodes created by libvirt IPI. Masters can only be changed fixing the size in code. For workers a variable can be added in the manifests, so first we have to create the manifests (`openshift-installer create manifests --dir <installation dir>`) and then modify the `openshift/99_openshift-cluster-api_worker-machineset-0.yaml` file, adding the `volumeSize` with the disk size in bytes


```
...
spec:
...
  template:
...
    spec:
...
      providerSpec:
        value:
...
          volume:
            volumeSize: <size>
            baseVolumeID: ocp-2972r-base
            poolName: ocp-2972r
            volumeName: ""
...
```


### Custom URL for Applications

One more thing to be taken into account is that [due an issue with libvirt and the need of a wildcard for the console](https://github.com/openshift/installer/issues/1007) we need to configure *.apps.basedomain instead of *.apps.< CLUSTERNAME >.basedomain, in order to let the openshift console being deploy, so bear in mind that change and do not include the cluster name when trying to access your APPs in this cluster.

This change is also done in the manifests, in this case by removing the "cluster name" part (probably `ocp` if you didn't change it in the `install-config.yaml`) from the url that appears in the `manifests/cluster-ingress-02-config.yml` file.


### OpenShift release image overwrite

When building installer from the source code we use images that have [OKD](https://www.okd.io/) content, and we want to install the desired Red Hat OpenShift release, so we need to override the image that the installer will use, otherwise [the bootstrap will start but the master will be stuck before showing the login prompt](https://github.com/openshift/installer/issues/2717).

You can override the release image by exporting the `OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE` variable [before launching the openshift installation](https://access.redhat.com/solutions/3880221).

Be aware that you will need to select the right values for ocp_release, ocp_git_branch and `ocp_install_install_release_image_override` otherwise the installation will fail.


### All-in-One OpenShift deployment

Before OpenShift 4.4, if you configured just one single master node the OpenShift installer will go through with no problems, but starting in OpenShift 4.4 the way that the ETCD cluster is installed and managed has changed. Now the Cluster ETCD operator must allow having just one node as Master (so having no ETCD quorum). This is done using the pretty weird (and auto-explanatory) variable `useUnsupportedUnsafeNonHANonProductionUnstableEtcd` as you can see in [this BUG](https://bugzilla.redhat.com/show_bug.cgi?id=1805034)

You have to wait until the Kubernetes API is ready after launching the install and then apply this patch:

`oc patch etcd cluster -p='{"spec": {"unsupportedConfigOverrides": {"useUnsupportedUnsafeNonHANonProductionUnstableEtcd": true}}}' --type=merge`

Just in case you didn't notice in the variable name, this is not supported, unstable, not safe and for non HA (of course) environments.

Why not all variables are named as this one? We could just get rid of documentation in that case.

Enjoy
-----------------

That's all, make responsible use of these playbooks (remember that this is just for LABs) and enjoy the Machine API even when your LAB is running on a single KVM node.
