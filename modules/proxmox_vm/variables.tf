variable "name" {
  description = "Name of node"
  type        = string
}

variable "memory" {
  description = "Amount of memory needed"
  type        = string
}

variable "vcpus" {
  description = "Number of vcpus"
  type        = number
}

variable "sockets" {
  description = "Number of sockets"
  type        = number
}

variable "autostart" {
  description = "Enable/Disable VM start on host bootup"
  type        = bool
}

variable "stop_on_destroy" {
  description = "Hard stop VM on terraform destroy"
  type        = bool
}

variable "default_bridge" {
  description = "Bridge to use when creating VMs in proxmox"
  type        = string
}

variable "target_node" {
  description = "Target node name in proxmox"
  type        = string
}

variable "source_node" {
  description = "Source node name in proxmox for a template"
  type        = string
  default     = ""
}

variable "vlan_id" {
  description = "VLAN ID for the node"
  type = number
}

variable "cidr_ip_range" {
  description = "IP range where the VMs will get an IP from"
  type        = string  
}