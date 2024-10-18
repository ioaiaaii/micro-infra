include "root" {
  path = find_in_parent_folders()
  expose = true
}

locals {
  project       = include.root.locals.project
  region        = include.root.locals.region
  zones         = include.root.locals.zones
  release_name  = "argo-cd"
  namespace     = "platform"
  chart_path    = "../../../../../../../meta-charts/meta-argo-cd" # Replace with your actual chart path or Helm repository name
  templates_dir = "${local.chart_path}/templates"
  values_file   = "${local.chart_path}/values.yaml"
  chart_file    = "${local.chart_path}/Chart.yaml"

  # Generate SHAs for Chart.yaml and values.yaml separately
  chart_sha     = filesha256(local.chart_file)
  values_sha    = filesha256(local.values_file)
  combined_templates_sha = sha256(join("", [for f in fileset(local.templates_dir, "**/*"): filesha256("${local.templates_dir}/${f}")]))

}

generate "helm_upgrade" {
  path      = "helm_upgrade.tf"
  if_exists = "overwrite"
  contents  = <<EOF
resource "null_resource" "helm_upgrade" {
  triggers = {
    chart_sha  = "${local.chart_sha}"
    values_sha = "${local.values_sha}"
    templates_sha = "${local.combined_templates_sha}"
  }

  provisioner "local-exec" {
    command = <<EOT
      helm upgrade --install ${local.release_name} ${local.chart_path} -n ${local.namespace} --values ${local.values_file} --create-namespace
    EOT
  }
}
EOF
}

inputs = {
  # These inputs can be used to force changes if necessary
  chart_sha  = local.chart_sha
  values_sha = local.values_sha
}

dependency "cluster" {
  config_path = "../../cluster"
}

# Before hooks for Helm dependency management and diff checking
terraform {

  before_hook "helm_dept" {
    commands     = ["plan", "apply"]
    execute      = [
      "helm", "dependency", "build", local.chart_path, "-n", local.namespace
    ]
    run_on_error = true
  }

  before_hook "helm_diff" {
    commands     = ["plan", "apply"]
    execute      = [
      "helm", "diff", "--no-color=false", "--context=1", "upgrade", "--install",
      "--values", local.values_file, local.release_name, local.chart_path, "-n", local.namespace
    ]
    run_on_error = true
  }
}

generate "data" {
  path      = "data.tf"
  if_exists = "overwrite"
  contents  = <<EOF
output "chart_sha" {
  value = "${local.chart_sha}"
}

output "values_sha" {
  value = "${local.values_sha}"
}
EOF
}
