include "root" {
  path = find_in_parent_folders()
  expose = true
}

locals {
  project = include.root.locals.project
  region  = include.root.locals.region
  zones  = include.root.locals.zones
}

dependency "vpc" {
  config_path = "../../network/vpc"
}
# terragrunt output --terragrunt-config terragrunt.hcl

terraform {
  source = "tfr://registry.terraform.io/terraform-google-modules/bastion-host/google?version=7.1.0"
}

inputs = {

  network            = dependency.vpc.outputs.network_name
  subnet             = "shared"
  zone               = local.zones[0]  # List of zones for the cluster
  project        = local.project
  host_project    = local.project

  members = ["user:JohnSavvaidis@gmail.com"]
  additional_ports = ["8888"]
  preemptible = true
  disk_size_gb = 10
  machine_type = "e2-micro"
  # tags = [ "egress-inet" ]

  startup_script = <<-EOF
  sudo apt-get update -y
  sudo apt-get install -y tinyproxy
  sudo awk '{gsub(/^Allow 127\.0\.0\.1$/, "Allow localhost")}1' /etc/tinyproxy/tinyproxy.conf > /tmp/tinyproxy.conf && sudo mv /tmp/tinyproxy.conf /etc/tinyproxy/tinyproxy.conf
  EOF

}
