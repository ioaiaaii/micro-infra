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
  source = "tfr://registry.terraform.io/terraform-google-modules/cloud-router/google?version=6.1.0"
}

dependency "vpc" {
  config_path = "../../network/vpc"
}

inputs = {
  project   = local.project
  region    = local.region

  name = "micro-router"
  network            = dependency.vpc.outputs.network_name

  nats = [{
    name                               = "micro-nat-gateway"
    source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
    subnetworks = [
      {
        name                     = dependency.vpc.outputs.subnets["${local.region}/workload"].id
        source_ip_ranges_to_nat  = ["PRIMARY_IP_RANGE", "LIST_OF_SECONDARY_IP_RANGES"]
        secondary_ip_range_names = dependency.vpc.outputs.subnets["${local.region}/workload"].secondary_ip_range[*].range_name
      },
      {
        name                     = dependency.vpc.outputs.subnets["${local.region}/shared"].id
        source_ip_ranges_to_nat  = ["PRIMARY_IP_RANGE"]
      }      
    ]
  }]
}
