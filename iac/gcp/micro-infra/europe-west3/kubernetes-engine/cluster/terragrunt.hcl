include "root" {
  path = find_in_parent_folders()
  expose = true
}

locals {
  project = include.root.locals.project
  region  = include.root.locals.region
  zones  = include.root.locals.zones
  kubernetes_version = "1.30"
}

# terragrunt output --terragrunt-config terragrunt.hcl

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF

provider "google" {
  project = "${local.project}"
  region  = "${local.region}"
}

EOF
}

dependency "data" {
  config_path = "../data"
}

dependency "vpc" {
  config_path = "../../network/vpc"
}

terraform {
  source = "tfr://registry.terraform.io/terraform-google-modules/kubernetes-engine/google//modules/private-cluster?version=33.1.0"
}

inputs = {
  # Control Plane Essentials
  kubernetes_version = dependency.data.outputs.latest_gke_master_version
  release_channel    = "UNSPECIFIED"
  project_id         = local.project
  name               = "ioaiaaii"
  region             = local.region
  regional           = false    # Not a regional cluster, zonal cluster instead
  zones              = local.zones  # List of zones for the cluster
  network            = dependency.vpc.outputs.network_name  # Use the VPC from the VPC module
  subnetwork         = "workload"  # Select the first subnetwork
  ip_range_pods      = "pod"  # Pod IP range for the GKE cluster
  ip_range_services  = "svc" # Service IP range for the GKE cluster
  master_ipv4_cidr_block = "172.16.0.0/28" # Control plane (master) IP range
  
  deletion_protection = false  # Disable deletion protection for easier cluster deletion

  # Security Improvements
  enable_private_nodes    = true  # Ensure the nodes are private (not publicly accessible)
  enable_private_endpoint = true  # Only allow API access over internal/private IPs

  add_cluster_firewall_rules        = true
  add_master_webhook_firewall_rules = true
  add_shadow_firewall_rules         = true
  shadow_firewall_rules_log_config = null # to save some $ on logs

  firewall_inbound_ports            = ["8443", "9443", "15017"] #List of TCP ports for admission/webhook controllers

  # https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/pull/1894    
  #https://github.com/terraform-google-modules/terraform-google-kubernetes-engine/issues/1706
  monitoring_enable_managed_prometheus = false
  monitoring_enabled_components = ["SYSTEM_COMPONENTS"]

  # Disable Cloud Monitoring and Logging
  monitoring_service = "none"
  logging_enabled_components = "[]"
  logging_service = "none"

  # Master Authorized Networks
  # Only allow access to the control plane from the subnetwork's CIDR block
  master_authorized_networks = [
      {
      cidr_block   = "10.10.0.0/20"
      display_name = "Worker Nodegroup"  # This will display as "VPC" in GCP UI
      },
      {
      cidr_block   = "10.0.1.0/29"
      display_name = "Shared Subnet"  # This will display as "VPC" in GCP UI
      },        
  ]
  grant_registry_access = true

  # Node pool settings
  remove_default_node_pool = true  # Remove the default node pool to define custom node pools

  # Define a custom node pool for workers
  node_pools = [{
      version = dependency.data.outputs.latest_gke_node_version  # Specify the Kubernetes version for the nodes
      auto_upgrade       = false   # Enable auto-upgrades for the node pool
      name               = "workers-base-pool"  # Name of the node pool
      machine_type       = "e2-small"  # Use cost-effective machine types
      spot               = true  # Use spot (preemptible) instances for cost savings
      min_count          = 1  # Minimum number of nodes in the pool
      max_count          = 2  # Maximum number of nodes in the pool
      initial_node_count = 1  # Initial number of nodes at cluster creation
      disk_size_gb       = 20  # Disk size for each node
      enable_secure_boot  = true  # Enable secure boot to ensure the node's integrity
  }]
  # node_pools_tags = {
  #   all = [ "egress-inet", "allow-google-apis" ]
  # }
  # Security - Enable Shielded Nodes for enhanced protection
  enable_shielded_nodes = true  # Use Shielded VMs to protect against rootkits and bootkits
}

# module "gke_auth" {
#   source  = "terraform-google-modules/kubernetes-engine/google//modules/auth"
#   version = "~> 33.0"

#   project_id   = var.project_id
#   location     = module.gke.location
#   cluster_name = module.gke.name
#   use_private_endpoint = true

# }