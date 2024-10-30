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
  source = "tfr://registry.terraform.io/terraform-google-modules/github-actions-runners/google//modules/gh-oidc?version=4.0.0"
}

dependency "sa" {
  config_path = "../service-accounts"
}

inputs = {

  project_id  = local.project
  pool_id     = "cicd"
  provider_id = "github"
  attribute_condition = "assertion.repository_owner_id=='49158979'"
  sa_mapping = {
    "${dependency.sa.outputs.service_accounts[0].account_id}" = {
      sa_name   = "projects/${local.project}/serviceAccounts/${dependency.sa.outputs.service_accounts[0].account_id}@${local.project}.iam.gserviceaccount.com"
      attribute = "attribute.repository/ioaiaaii/ioaiaaii.net"
    }
  }  
}
