# create demo cluster

# init demo certificates
module "default-certs" {
  source = "../certificates"
}

module "kub" {
  source    = "../aws-kub"

  #aws_access_key   =  "${var.aws_access_key}"
  #aws_secret_key   =  "${var.aws_secret_key}"
  kubeapi_token    =  "${var.kubeapi_token}"

  cluster_name     = "bpm-${terraform.workspace}"
  k8s_worker_count = 1

  certificate_key  = "${module.default-certs.key}"
  certificate_body = "${module.default-certs.crt}"

  bastion_post_init=[
    "sudo yum install -y mysql"
  ]
}

# default params for port listeners defined inside kub module
data "null_data_source" "default_port_params" {
  inputs = "${ zipmap(module.kub.default_port_keys, module.kub.default_port_values) }"
}

# deploy some artifacts
module "persistent" {
  source    = "../persistent-nfs"
  ssh_host = "${module.kub.bastion-ip}"
  persistent_local = "./persistent"
  templates=[
    ".cloud/00-cloud.yaml"
  ]
  vars = {
    public_host_name  = "${module.kub.hostname}"
    domain            = "default.svc.cluster.local"
    component_ports   = "${jsonencode(local.component_ports)}"
    component_hosts   = "${jsonencode(data.null_data_source.component_hosts.outputs)}"
  }
  depends_on = ["${module.kub.ready}"]
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

#output "default_port_params" {
#  value = "${jsonencode(data.null_data_source.default_port_params.outputs)}"
#}
