include "root" {
  path = find_in_parent_folders()
  expose = true
}

locals {
  project = include.root.locals.project
  region  = include.root.locals.region
  zones  = include.root.locals.zones
}

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

terraform {
  source = "tfr://registry.terraform.io/terraform-google-modules/service-accounts/google?version=4.4.0"
}

inputs = {
  project_id    = local.project
  prefix        = "managed-sa"
  names         = ["gh"]
  project_roles = [
    "${local.project}=>roles/artifactregistry.writer",
    "${local.project}=>roles/iam.serviceAccountTokenCreator",
    "${local.project}=>roles/iam.workloadIdentityUser",
    "${local.project}=>roles/storage.objectAdmin",
  ]
}
