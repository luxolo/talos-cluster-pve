# Create Talos secrets
resource "talos_machine_secrets" "talos_secret" {}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  machine_type     = "controlplane"
  cluster_endpoint = "https://${var.floating_ip}:6443"
  machine_secrets  = talos_machine_secrets.talos_secret.machine_secrets
}

data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster_name
  machine_type     = "worker"
  cluster_endpoint = "https://${var.floating_ip}:6443"
  machine_secrets  = talos_machine_secrets.talos_secret.machine_secrets
}

data "talos_client_configuration" "client_config" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.talos_secret.client_configuration
  endpoints            = [ for k,v in module.master_nodes : v.address ]
  nodes                = [ for k,v in concat(module.master_nodes,module.worker_nodes) : v.address ]
}

resource "talos_machine_configuration_apply" "controlplane" {
  for_each  = { for k,v in module.master_nodes : k => v.address }
  client_configuration        = talos_machine_secrets.talos_secret.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = each.value
  config_patches = [
    templatefile("${path.module}/templates/patch-control.tmpl", {
      floating_ip   = var.floating_ip
    })
  ]
}

resource "talos_machine_configuration_apply" "worker" {
  for_each  = { for k,v in module.worker_nodes : k => v.address }
  client_configuration        = talos_machine_secrets.talos_secret.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = each.value
  config_patches = [
    templatefile("${path.module}/templates/patch-worker.tmpl", {
      
    })
  ]
}

resource "local_file" "talos_config" {
    content  = data.talos_client_configuration.client_config.talos_config
    filename = ".talosconfig"
}

resource "time_sleep" "wait_15_seconds" {
  depends_on = [
    talos_machine_configuration_apply.controlplane,
    talos_machine_configuration_apply.worker
  ]

  create_duration = "15s"
}

resource "talos_machine_bootstrap" "bootstrap" {
  depends_on = [
    time_sleep.wait_15_seconds
  ]
  node                 = module.master_nodes[0].address
  client_configuration = talos_machine_secrets.talos_secret.client_configuration
}

data "talos_cluster_kubeconfig" "config" {
  depends_on = [
    talos_machine_bootstrap.bootstrap
  ]
  client_configuration = talos_machine_secrets.talos_secret.client_configuration
  node                 = module.master_nodes[0].address
}

resource "local_file" "kubeconfig" {
    content  = data.talos_cluster_kubeconfig.config.kubeconfig_raw 
    filename = ".kubeconfig"
}
