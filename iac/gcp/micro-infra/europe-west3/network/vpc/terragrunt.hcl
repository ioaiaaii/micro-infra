include "root" {
  path = find_in_parent_folders()
}

locals {
  ## Load Vars
  ### Automatically load project-level variables
  project_vars = read_terragrunt_config(find_in_parent_folders("project.hcl"))

  ### Automatically load location-level variables  
  location_vars = read_terragrunt_config(find_in_parent_folders("location.hcl"))

  ### Extract Vars
  project = local.project_vars.locals.project
  region = local.location_vars.locals.region
}

terraform {
  source = "tfr://registry.terraform.io/terraform-google-modules/network/google?version=9.3.0"
}

inputs = {
  # Project and VPC basic settings
  project_id   = local.project
  network_name = "micro-network"
  # Disable automatic creation of subnetworks (we are defining our own subnets)
  auto_create_subnetworks = false
  delete_default_internet_gateway_routes = true
  routing_mode = "GLOBAL"

  # Define the primary subnet
  subnets = [
    {
      subnet_name           = "workload"  # Name of the subnet
      subnet_ip             = "10.10.0.0/20"  # /20 CIDR block provides 4096 IP range for the primary subnet
      subnet_region         = local.region          # Region where the subnet will be created
      subnet_private_access = "true"
      subnet_flow_logs      = "false"
    },
    {
      subnet_name           = "shared"  # Name of the subnet
      subnet_ip             = "10.0.1.0/29"  # /29 CIDR block provides 6 IP range for the primary subnet
      subnet_region         = local.region           # Region where the subnet will be created
      subnet_private_access = "true"  # Enable private access to Google APIs without public IPs
      subnet_flow_logs      = "false"  # Enable VPC flow logs for traffic visibility
    }    
  ]
  # Define secondary IP ranges for Pods and Services (used in GKE)
  secondary_ranges = {
    workload = [
      {
        range_name    = "pod"      # Secondary range for Pod IPs
        ip_cidr_range = "192.168.0.0/18"    # /18 CIDR block provides 16,384 total Pod IP range
      },
      {
        range_name    = "svc"  # Secondary range for Service IPs
        ip_cidr_range = "192.168.64.0/18"      #/18 CIDR block provides 16,384 Service IP range
      }
    ]
  }
  # routes = [
  #   {
  #     name              = "egress-internet"
  #     description       = "Tag based route through IGW to access internet"
  #     destination_range = "0.0.0.0/0"
  #     tags              = "egress-inet"
  #     next_hop_internet = "true"
  #   }
  # ]
}
