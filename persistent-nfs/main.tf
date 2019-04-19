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
      "echo ${ join(",",var.depends_on) }",    ## just to make the depends_on parameter working
      "find /var/nfs -type f -delete",         ## delete files and not the folders to keep nfs mount
      #"rm -rf ${var.persistent_remote}/*",
      #"rm -rf ${var.persistent_remote}/.??*",
      "unzip -o ${local.remote_zip} -d ${var.persistent_remote}",
      "rm -f ${local.remote_zip}"
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

