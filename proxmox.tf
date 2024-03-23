## == Proxmox node picker=======================================================
# List all nodes in the cluster
data "proxmox_virtual_environment_nodes" "available_nodes" {}

resource "random_shuffle" "control_nodes" {
  input        = data.proxmox_virtual_environment_nodes.available_nodes.names
  result_count = var.MASTER_COUNT
}

resource "random_shuffle" "worker_nodes" {
  input        = data.proxmox_virtual_environment_nodes.available_nodes.names
  result_count = var.WORKER_COUNT
}

## == Create an ISO image using ================================================
## == Talos Image Factory ======================================================

data "http" "talos_image_id" {
  url    = "https://factory.talos.dev/schematics"
  method = "POST"

  request_body = file("${path.module}/templates/schematic.yaml")
}

## == Download image and create template =======================================

resource "proxmox_virtual_environment_download_file" "talos_template" {
  depends_on   = [
    data.http.talos_image_id
  ]
  content_type = "iso"
  datastore_id = var.iso-datastore_id
  node_name    = data.proxmox_virtual_environment_nodes.available_nodes.names[0]
  url          = "https://factory.talos.dev/image/${jsondecode(data.http.talos_image_id.response_body).id}/${var.imager_version}/metal-amd64.iso"
  file_name    = "talos.iso"
}

resource "proxmox_virtual_environment_vm" "talos_template" {
  depends_on  = [proxmox_virtual_environment_download_file.talos_template]
  name        = "talos-template"
  description = "Managed by Terraform"
  tags        = ["terraform", "talos"]
  started     = false
  vm_id       = 8000
  template    = true
  node_name   = proxmox_virtual_environment_download_file.talos_template.node_name
  
  memory {
    dedicated = 2048
  }
  cpu {
    cores   = 2
    type    = "host"
    sockets = 1
  }
  network_device {
    model  = "virtio"
    bridge = var.DEFAULT_BRIDGE
    vlan_id = var.vlan_id
  }
  cdrom {
    enabled = true
    file_id = proxmox_virtual_environment_download_file.talos_template.id
  }
  scsi_hardware     =   "lsi"
  disk {
    backup  =   false
    datastore_id = var.datastore_id
    file_format  = "raw"
    interface    = "scsi1"
    size         = 32
  }
}

## == VM creation ==============================================================

module "master_domain" {

  depends_on = [proxmox_virtual_environment_vm.talos_template]

  source          = "./modules/proxmox_vm"
  count           = var.MASTER_COUNT
  name            = format("talos-master-%s", count.index)
  memory          = var.master_config.memory
  vcpus           = var.master_config.vcpus
  sockets         = var.master_config.sockets
  autostart       = var.autostart
  stop_on_destroy = var.stop_on_destroy
  default_bridge  = var.DEFAULT_BRIDGE
  target_node     = random_shuffle.control_nodes.result[count.index]
  source_node     = proxmox_virtual_environment_vm.talos_template.node_name
  vlan_id         = var.vlan_id
}

module "worker_domain" {

  depends_on = [proxmox_virtual_environment_vm.talos_template]

  source         = "./modules/proxmox_vm"
  count          = var.WORKER_COUNT
  name           = format("talos-worker-%s", count.index)
  memory         = var.worker_config.memory
  vcpus          = var.worker_config.vcpus
  sockets        = var.worker_config.sockets
  autostart      = var.autostart
  stop_on_destroy = var.stop_on_destroy
  default_bridge = var.DEFAULT_BRIDGE
  target_node    = random_shuffle.worker_nodes.result[count.index]
  source_node    = proxmox_virtual_environment_vm.talos_template.node_name
  vlan_id        = var.vlan_id
}
