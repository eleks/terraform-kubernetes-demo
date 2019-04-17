# init default persistent if persistent_dir provided

resource "null_resource" "deploy" {
  connection {
    type        = "ssh"
    host        = "${var.ssh_host}"
    user        = "${var.ssh_user}"
    private_key = "${file("${var.key_path_local}${var.key_name}")}"
  }

  provisioner "remote-exec" "dependency" {
    inline = [
      "echo ${ join(",",var.depends_on) }",    ## just to make the depends_on parameter working
    ]
  }
  provisioner "remote-exec" "inline"{
    inline = "${var.inline}"
  }
}

