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
  source = "tfr://registry.terraform.io/terraform-google-modules/kubernetes-engine/google//modules/workload-identity?version=34.0.0"
}

dependency "sa" {
  config_path = "../../service-accounts/opencost"
}

inputs = {
  project_id  = local.project
  use_existing_gcp_sa = true
  use_existing_k8s_sa = true
  k8s_sa_name = "opencost"
  namespace = "observability"
  gcp_sa_name = "${dependency.sa.outputs.service_accounts[0].account_id}"
  name = "opencost"
  annotate_k8s_sa = false
}
