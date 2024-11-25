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
  description   = "Compute Read Only Account Created For OpenCost"
  names         = ["compute-viewer-opencost"]
  grant_billing_role  = true
  billing_account_id = "01BB57-160805-3E7BAE"
  project_roles = [
    "${local.project}=>roles/compute.viewer",
    "${local.project}=>roles/bigquery.user",
    "${local.project}=>roles/bigquery.dataViewer",
    "${local.project}=>roles/bigquery.jobUser",
    "${local.project}=>roles/iam.serviceAccountTokenCreator",
  ]
}
