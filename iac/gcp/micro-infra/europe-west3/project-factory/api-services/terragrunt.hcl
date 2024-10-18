include "root" {
  path = find_in_parent_folders()
}

locals {
  # read
  project_vars = read_terragrunt_config(find_in_parent_folders("project.hcl"))

  # parse
  project = local.project_vars.locals.project
}

terraform {
  source = "tfr://registry.terraform.io/terraform-google-modules/project-factory/google//modules/project_services?version=17.0.0"
}

inputs = {

  project_id = local.project

  disable_services_on_destroy = false

  activate_apis = [
    "iam.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "containerregistry.googleapis.com",
    "containersecurity.googleapis.com",
    "container.googleapis.com",
    "binaryauthorization.googleapis.com",
    "stackdriver.googleapis.com",
    "iap.googleapis.com",
    "storage-api.googleapis.com",
    "oslogin.googleapis.com",
    "servicenetworking.googleapis.com",
    "secretmanager.googleapis.com",
  ]
}
