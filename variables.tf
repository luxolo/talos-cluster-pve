## == PROXMOX ==================================================================
variable "PROXMOX_API_ENDPOINT" {
  description = "API endpoint for proxmox"
  type        = string
}

variable "PROXMOX_USERNAME" {
  description = "User name used to login proxmox"
  type        = string
}

variable "PROXMOX_TOKEN_ID" {
  description = "Name of the Proxmox token secret"
  type        = string
}

variable "PROXMOX_TOKEN_SECRET" {
  description = "Secret UUID to authenticate against proxmox"
  type        = string
}

variable "DEFAULT_BRIDGE" {
  description = "Bridge to use when creating VMs in proxmox"
  type        = string
  default     = "vmbr0"
}

variable "vlan_id" {
  description = "VLAN ID for the network in which nodes will be created"
  type        = number
  default     = 0
}

variable "autostart" {
  description = "Enable/Disable VM start on host bootup"
  type        = bool
  default     = true
}

variable "stop_on_destroy" {
  description = "Hard stop VM on terraform destroy"
  type        = bool
}

variable "datastore_id" {
  description = "The identifier for the datastore to create the disk in"
  type = string
  default = "local-lvm"
}

variable "iso-datastore_id" {
  description = "The identifier for the datastore to store ISO images to"
  type = string
  default = "local"
}


## == TALOS/K8s ================================================================

# K8s cluster config
variable "imager_version" {
  type        = string
  default     = "v1.6.7"
}

# K8s cluster config
variable "cluster_name" {
  description = "Cluster name to be used for kubeconfig"
  type        = string
}

# Cluster shared VIP IP
variable "floating_ip" {
  description = "Floating virtual IP address for cluster access"
  type        = string
}

variable "MASTER_COUNT" {
  description = "Number of masters to create"
  type        = number
  validation {
    condition     = var.MASTER_COUNT != 0
    error_message = "Number of master nodes cannot be 0"
  }
}

variable "WORKER_COUNT" {
  description = "Number of workers to create"
  type        = number
}

variable "master_config" {
  description = "Kubernetes master config"
  type = object({
    memory  = string
    vcpus   = number
    sockets = number
  })
}

variable "worker_config" {
  description = "Kubernetes worker config"
  type = object({
    memory  = string
    vcpus   = number
    sockets = number
  })
}
