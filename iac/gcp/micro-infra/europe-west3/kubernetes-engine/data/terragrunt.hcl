include "root" {
  path = find_in_parent_folders()
  expose = true
}

locals {
  kubernetes_vars = read_terragrunt_config(find_in_parent_folders("kubernetes.hcl"))

  project = include.root.locals.project
  region  = include.root.locals.region
  zones  = include.root.locals.zones
  kubernetes_version = local.kubernetes_vars.locals.kubernetes_version
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

generate "data" {
  path      = "data.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF

data "google_container_engine_versions" "gke_version" {
  provider       = google
  location       = "${local.zones[0]}"
  version_prefix = "${local.kubernetes_version}."  # Fetch versions that match the provided prefix
}

  # Output for the latest available GKE master (control plane) version
output "latest_gke_master_version" {
  value = data.google_container_engine_versions.gke_version.latest_master_version
}

# Output for the latest available GKE node version
output "latest_gke_node_version" {
  value = data.google_container_engine_versions.gke_version.latest_node_version
}
EOF
}
