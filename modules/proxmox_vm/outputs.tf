locals {
  # address_ipv4_list = [for ip in flatten(proxmox_virtual_environment_vm.node.ipv4_addresses) : ip if can(regex("192..*", ip))]
  address_ipv4_list = [for ip in flatten(proxmox_virtual_environment_vm.node.ipv4_addresses) : ip if contains(module.cidr_block.ip_addresses, ip)]
  address = length(local.address_ipv4_list) > 0 ? local.address_ipv4_list[0] : ""
}

output "address" {
  value       = local.address
  description = "IP Address of the node"
}

output "name" {
  value       = proxmox_virtual_environment_vm.node.name
  description = "Name of the node"
}
