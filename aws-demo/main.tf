#--------------------------------------------------------

terraform {
    required_version = "> 0.11.0"
}
#--------------------------------------------------------
provider "aws" {
  version = "~> 1.56"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

provider "kubernetes" {
  host  = "https://${module.kub.hostname}:6443"
  token = "${var.kubeapi_token}"
}
