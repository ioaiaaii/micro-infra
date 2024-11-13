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
  source = "git::https://github.com/ioaiaaii/ioaiaaii.net.git//deploy/iac?ref=feat/styling-improv"
}

inputs = {
  project = local.project
  location    = local.region
}
