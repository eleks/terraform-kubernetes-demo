#--------------------------------------------------------
#--kube port listeners
#--------------------------------------------------------

# default params for port listeners
data "null_data_source" "default_port_params" {
  inputs = {
    vpc_id          = "${aws_vpc.home.id}"
    certificate_arn = "${aws_iam_server_certificate.web.arn}"
    public_arn      = "${aws_lb.frontend.arn}"
    target_id       = "${aws_instance.master.0.private_ip}"
    cluster_name    = "${local.cluster_name}"
  }
}

# the port 30080 defined in dashboard service definition `./provision/master/dashboard.yaml`
module "port-kubedash" {
  source          = "../aws-listener"
  port            = "https"
  ports           = { https = "8443 30080 443" }
  params          = "${ data.null_data_source.default_port_params.outputs }"
}

# publish kubeapi port 6443 to access it from your local machine (manage through terraform)
module "port-kubeapi" {
  source          = "../aws-listener"
  port            = "https"
  ports           = { https = "6443 6443 6443" }
  params          = "${ data.null_data_source.default_port_params.outputs }"
}
