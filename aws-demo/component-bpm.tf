## define bpm master component

module "bpm" {
  //source    = "github.com/eleks/terraform-kubernetes-demo/kub-component-java-base"
  source    = "../kub-component-java-base"

  name      = "bpm"
  namespace = "default"
  image     = "eleks/base-camunda-bpm-tomcat-7.10.0"
  replicas  = 1
  command   = "server/apache-tomcat-9.0.12/bin/catalina.sh run"

  mem_min   = "1Gi"
  mem_max   = "2Gi"
  cpu_min   = "0.5"
  cpu_max   = "1"
  ports     = "${local.component_ports["bpm"]}"
  persistent_root = "/opt/persistent/bpm"
  ## wait for kubernetes and persistent ready
  depends_on = ["${module.kub.ready}", "${module.persistent.ready}"]
}

## expose public ports
module "port-bpm-http" {
  //source          = "github.com/eleks/terraform-kubernetes-demo/aws-listener"
  source          = "../aws-listener"
  port            = "http"
  ports           = "${local.component_ports["bpm"]}"
  params          = "${ data.null_data_source.default_port_params.outputs }"
}

output "component-bpm" {
  value = "${module.port-bpm-http.public_protocol}://${data.null_data_source.component_hosts.outputs["bpm"]}:${module.port-bpm-http.public_port}"
}

