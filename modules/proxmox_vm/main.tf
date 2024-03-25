module "cidr_block" {
  source = "../cidr-expand"
  cidr   = var.cidr_ip_range
}

resource "proxmox_virtual_environment_vm" "node" {
  name                = var.name
  on_boot             = var.autostart
  node_name           = var.target_node
  scsi_hardware       = "virtio-scsi-single"
  timeout_shutdown_vm = 300
  stop_on_destroy     = var.stop_on_destroy

  memory {
    dedicated = var.memory
  }

  cpu {
    cores   = var.vcpus
    type    = "host"
    sockets = var.sockets
  }

  agent {
    enabled = true
    timeout = "1m"
  }

  clone {
    retries = 3
    vm_id   = 8000
    node_name = var.source_node
  }

  network_device {
    model  = "virtio"
    bridge = var.default_bridge
    vlan_id = var.vlan_id
  }
}
