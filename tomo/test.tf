module "cidr_block" {
  source = "../modules/cidr-expand"
  cidr   = var.cidr_ip_range
}

# module "master_nodes" {

#   source          = "../modules/proxmox_vm"
#   count           = 1
#   name            = format("talos-master-%s", count.index)
#   memory          = 2048
#   vcpus           = 2
#   sockets         = 1
#   autostart       = true
#   stop_on_destroy = true
#   default_bridge  = "vmbr0"
#   target_node     = "pve"
#   source_node     = "pve"
#   vlan_id         = var.vlan_id
#   cidr_ip_range   = var.cidr_ip_range
# }

# resource "proxmox_virtual_environment_vm" "node" {
#   name                = "tomo"
#   on_boot             = true
#   node_name           = "pve"
#   scsi_hardware       = "virtio-scsi-single"
#   timeout_shutdown_vm = 300
#   stop_on_destroy     = true

#   memory {
#     dedicated = 2048
#   }

#   cpu {
#     cores   = 2
#     type    = "host"
#     sockets = 1
#   }

#   agent {
#     enabled = true
#     timeout = "1m"
#   }

#   clone {
#     retries = 3
#     vm_id   = 8000
#     node_name = "pve"
#   }

#   network_device {
#     model  = "virtio"
#     bridge = "vmbr0"
#   }
# }

resource "proxmox_vm_qemu" "resource-name" {
  name        = "tomo"
  target_node = "pve"
  boot        = "order=ide3;scsi1;net0"

  ### or for a Clone VM operation
  clone = "talos-template"
  agent=1

  ### or for a PXE boot VM operation
  # pxe = true
  # boot = "scsi0;net0"
  # agent = 0
}

