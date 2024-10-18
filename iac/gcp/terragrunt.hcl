# TERRAGRUNT CONFIGURATION
terraform_version_constraint = ">= 1.9"
terragrunt_version_constraint = ">= 0.68"

## Variable Management
locals {
  ## Load Vars
  ### Automatically load project-level variables
  project_vars = read_terragrunt_config(find_in_parent_folders("project.hcl"))

  ### Automatically load location-level variables  
  location_vars = read_terragrunt_config(find_in_parent_folders("location.hcl"))

  ### Extract Vars
  project = local.project_vars.locals.project
  region = local.location_vars.locals.region
  zones = local.location_vars.locals.zones
}

## Remote state and Generated backend
remote_state {
  backend = "gcs"
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
  config = {
    bucket   = "terraform-state-${local.project}"
    prefix   = "${path_relative_to_include()}/terraform.tfstate"
    location = local.region
    project  = local.project
    gcs_bucket_labels = {
      managed = "terragrunt"
    }
  }
}

# ---------------------------------------------------------------------------------------------------------------------
# GLOBAL PARAMETERS
# These variables apply to all configurations in this subfolder. These are automatically merged into the child
# `terragrunt.hcl` config via the include block.
# ---------------------------------------------------------------------------------------------------------------------

# Configure root level variables that all resources can inherit. This is especially helpful with multi-account configs
# where terraform_remote_state data sources are placed directly into the modules.
inputs = merge(
  local.project_vars.locals,
  local.location_vars.locals,
)
