terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.49.0"
    }
    talos = {
      source = "siderolabs/talos"
      version = "0.4.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.6.0"
    }
    time = {
      source = "hashicorp/time"
      version = "0.11.1"
    }
    http = {
      source = "hashicorp/http"
      version = "3.4.2"
    }
  }
}

provider "proxmox" {
  endpoint = var.PROXMOX_API_ENDPOINT
  api_token = "${var.PROXMOX_USERNAME}@pam!${var.PROXMOX_TOKEN_ID}=${var.PROXMOX_TOKEN_SECRET}"
  insecure = true
  ssh {
    agent = true
    username = var.PROXMOX_USERNAME
  }
}

