# create cluster

# init demo certificates
module "default-certs" {
  # source = "github.com/eleks/terraform-kubernetes-demo/certificates"
  source = "../certificates"
}

module "kub" {
  # source    = "github.com/eleks/terraform-kubernetes-demo/aws-kub"
  source    = "../aws-kub"

  kubeapi_token    = "${var.kubeapi_token}"
  cluster_name     = "${terraform.workspace}"
  k8s_worker_count = 2

  certificate_key  = "${module.default-certs.key}"
  certificate_body = "${module.default-certs.crt}"

  bastion_post_init=[
    "sudo yum install -y -q mysql"
  ]
}


output "bastion-ip" {
  value = "${module.kub.bastion-ip}"
}

output "kub-dashboard" {
  value = "${module.kub.dashboard}"
}

output "kub-token" {
  value = "${var.kubeapi_token}"
}

