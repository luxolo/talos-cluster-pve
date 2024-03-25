terraform {
  required_providers {
    # proxmox = {
    #   source  = "bpg/proxmox"
    #   version = "0.49.0"
    # }
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
    proxmox = {
      source = "Telmate/proxmox"
      version = "3.0.1-rc1"
    }
  }
}

# provider "proxmox" {
#   endpoint = var.PROXMOX_API_ENDPOINT
#   api_token = "${var.PROXMOX_USERNAME}@pam!${var.PROXMOX_TOKEN_ID}=${var.PROXMOX_TOKEN_SECRET}"
#   insecure = true
#   ssh {
#     agent = true
#     username = var.PROXMOX_USERNAME
#   }
# }

provider "proxmox" {
  pm_api_url = var.PROXMOX_API_ENDPOINT
  pm_api_token_id = "tommij@pam!terraform"
  pm_api_token_secret = "a3a09775-2ba6-4587-b1af-b0e1079dc58b"
  pm_tls_insecure = true
#   ssh {
#     agent = true
#     username = var.PROXMOX_USERNAME
#   }
}
