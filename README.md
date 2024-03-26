# talos-cluster-pve

Automated installation of talos cluster on top of Proxmox cluster.
By default it is installed without any CNI. There are some [issues](#known-issues) during installation, but I am looking into them.

## How does all this work?

The file `proxmox.tf` will do following:
- use `schematic.yaml` file to create an ISO from talos factory
  - check [Customizations](#system-extensions) for more info
- download the ISO to one of the proxmox nodes
- randomly spawn control and worker VMs on different proxmox nodes

The file `talos_install.tf` will do following:
- create secrets and machine configuration
  - secrets don't need to be saved in a file as it is saved in the state file
- apply configuration files (together with patches) to the appropriate nodes
  - check [Customizations](#configuration-patches) for more info
- bootstrap the cluster
- save talosconfig and kubeconfig to local files (`.talosconfig` and `.kubeconfig` respectively)

## KNOWN ISSUES

- When creating a VM (proxmox_virtual_environment_vm) sometimes there is a race condition where IP address is not yet assigned/reported by qemu agent and `talos_machine_configuration_apply` will hang. To continue break current execution and do following:
    ```
    terraform refresh
    terraform apply
    ```

- After installation qemu agent stops working. All VMs need to be stopped and re-started from proxmox to restart qemu agent. Same issue as reported here: https://github.com/siderolabs/extensions/issues/338

## Customizations
### System extensions
System extensions allow extending the Talos root filesystem, which enables a variety of features, such as including custom container runtimes, loading additional firmware, etc.

System extensions are only activated during the installation or upgrade of Talos Linux. With system extensions installed, the Talos root filesystem is still immutable and read-only.

To add/change system extensions change `templates/schematic.yaml` file.

See possible extensions [here](https://github.com/siderolabs/extensions)

### Configuration patches
Talos generates machine configuration for two types of machines: controlplane and worker machines.  Configuration patching allows modifying machine configuration to fit it for the cluster or a specific machine.

Configuration patching can be done using `templates/patch-control.tmpl` and `templates/patch-worker.tmpl`

Official documentation for patching is [here](https://www.talos.dev/v1.6/talos-guides/configuration/patching/)

## How do I use it?
In order to run this, you need to create `terraform.tfvars` file with following content.

```
## == K8s config ==================================================================
cluster_name = "<K8S_CLUSTER_NAME>"
floating_ip = "<IP_ADDRESS>"
vlan_id = VLAN_ID                     # Optional

MASTER_COUNT = 2
WORKER_COUNT = 1
autostart    = true
stop_on_destroy = true
master_config = {
  memory  = "4096"
  vcpus   = 4
  sockets = 1
}
worker_config = {
  memory  = "2048"
  vcpus   = 2
  sockets = 1
}

## == Proxmox config===============================================================
PROXMOX_API_ENDPOINT    = "<API_ENDPOINT>"     # e.g. https://pve-01.proxmox.net:8006/api2/json
PROXMOX_USERNAME        = <PROXMOX_USER>       # Used for proxmox API token e.g. "joe"
PROXMOX_TOKEN_ID        = <TOKEN_ID>           # e.g. "terraform"
PROXMOX_TOKEN_SECRET    = <TOKEN_SECRET>       # e.g. "sad43252-gbw2-fdbv-3242-fdh455k347y6"
CIDR_IP_RANGE           = <CIDR_IP_RANGE>      # e.g. "192.168.0.0/24"

```

## To help out people who stumble on this repo, and want to use it

>  I've assigned `Administrator` API Token permission on `/`. Ofc this can be better done, but it's not part of this. Feel free to create your own groups/roles.