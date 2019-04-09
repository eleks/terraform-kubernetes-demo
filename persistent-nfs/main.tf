# init default persistent if persistent_dir provided

locals {
  local_zip = "./.terraform/tmp-persistent-nfs.zip"
  remote_zip = "/home/${var.ssh_user}/tmp-persistent-nfs.zip"
}

# zip 
data "archive_file" "persistent-zip" {
  type        = "zip"
  source_dir  = "${var.persistent_local}"
  output_path = "${local.local_zip}"
}

resource "null_resource" "deploy" {
  connection {
    type        = "ssh"
    host        = "${var.ssh_host}"
    user        = "${var.ssh_user}"
    private_key = "${file("${var.key_path_local}${var.key_name}")}"
  }
   
  provisioner "file" "persistent-zip" {
    source        = "${local.local_zip}"
    destination   = "/home/${var.ssh_user}/tmp-persistent-nfs.zip"
  }

  provisioner "remote-exec" {
    inline = [
      "echo ${ join(",",var.depends_on) }",    ## just to make depends_on working
      "rm -rf ${var.persistent_remote}/*",
      "unzip -o ${local.remote_zip} -d ${var.persistent_remote}",
      "rm -f ${local.remote_zip}"
      # "find ${var.persistent_remote} -name *.tft -delete"
    ]
  }
}

# render templates here
data "template_file" "templates" {
  count = "${ length(var.templates) }"
  template = "${file( "${var.persistent_local}/${var.templates[count.index]}" )}"
  vars  = "${var.vars}"
}

resource "null_resource" "templates" {
  count = "${ length(var.templates) }"

  connection {
    type        = "ssh"
    host        = "${var.ssh_host}"
    user        = "${var.ssh_user}"
    private_key = "${file("${var.key_path_local}${var.key_name}")}"
  }
   
  provisioner "file" "template-put" {
    content       = "${data.template_file.templates.*.rendered[count.index]}"
    #content       = "..."
    destination   = "${var.persistent_remote}/${var.templates[count.index]}"
  }
  # forced to be triggered with
  triggers {
    cluster_instance_ids = "${join(",", null_resource.deploy.*.id)}"
  }
  depends_on = [ "null_resource.deploy", "data.template_file.templates" ]
}



/*
  # clean
  provisioner "remote-exec" "clean" {
    inline = [
      "echo ${ join(",",var.depends_on) }",    ## just to make depends_on working
      "${local.cmd_clean}"
    ]
  }
  # put static files
  provisioner "file" "persistent-dir" {
    source        = "${var.persistent_local}/*"
    destination   = "${var.persistent_remote}"
  }

# process template to write 00-cloud.yaml
# it can be used inside docker containers to do correct ititialization
data "template_file" "00-cloud-yaml" {
  template = "${file("${path.module}/persistent/.cloud/00-cloud.yaml")}"
  vars {
    public_host_name  = "${aws_lb.frontend.dns_name}"
    domain            = "default.svc.cluster.local"
    component_ports   = "${jsonencode(local.component_ports)}"
    component_hosts   = "${jsonencode(data.null_data_source.component_hosts.outputs)}"
  }
}


## (re)init persistent content
resource "null_resource" "deploy" {
  connection = "${zipmap(module.kub.bastion_connection_keys, module.kub.bastion_connection_values)}"

  provisioner "file" "persistent-dir" {
    source        = "${var.persistent_dir}"
    destination   = "/var/nfs/persistent"
  }
  provisioner "remote-exec" {
    inline = [
      "rm -rf /var/nfs/persistent",
      "unzip /home/${local.config["username"]}/persistent.zip -d /var/nfs/persistent",
      "rm -f /home/${local.config["username"]}/persistent.zip",
      "find /var/nfs/persistent -name *.tft -delete"
    ]
  }
  #write previously prepared template to a remote file
  provisioner "file" "00-cloud-yaml" {
    content     = "${data.template_file.00-cloud-yaml.rendered}"
    destination = "/var/nfs/persistent/.cloud/00-cloud.yaml"
  }
  depends_on = ["module.kub"]
}
*/