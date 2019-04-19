# deploy some artifacts
module "persistent" {
  # source    = "github.com/eleks/terraform-kubernetes-demo/persistent-nfs"
  source    = "../persistent-nfs"
  ssh_host = "${module.kub.bastion-ip}"
  persistent_local = "./persistent"
  templates=[
    "bpm/conf/00-camunda.yaml",
    ".cloud/00-cloud.yaml",
    "grafana/datasources/camunda.yaml"
  ]
  vars = {
    public_host_name  = "${module.kub.hostname}"
    domain            = "default.svc.cluster.local"
    component_ports   = "${jsonencode(local.component_ports)}"
    component_hosts   = "${jsonencode(data.null_data_source.component_hosts.outputs)}"
    tf_db_host        = "${aws_db_instance.mysql.address}"
    tf_db_port        = "${aws_db_instance.mysql.port}"
    tf_db_user        = "${var.tf_db_user}"
    tf_db_pass        = "${var.tf_db_pass}"
    tf_mail_user      = "${var.tf_mail_user}"
    tf_mail_pass      = "${var.tf_mail_pass}"
    tf_jira_auth      = "${var.tf_jira_auth}"
  }
  depends_on = ["${module.kub.ready}","${aws_db_instance.mysql.address}"]
}
