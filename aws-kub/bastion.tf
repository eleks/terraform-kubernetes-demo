#--------------------------------------------------------
#--Bastion host
#--------------------------------------------------------

## prepare cloudinit for all nodes including bastion
data "template_cloudinit_config" "init-common" {
  gzip          = true
  base64_encode = true

  part {
    filename     = "init-common.sh"
    content_type = "text/x-shellscript"
    content      = "${file("${path.module}/provision/init-common.sh")}"
  }
}

resource "aws_instance" "bastion" {
  availability_zone      = "${data.aws_availability_zones.available.names[0]}"
  ami                    = "${data.aws_ami.centos_ami.image_id}"
  instance_type          = "${var.bastion_flavor}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.bastion.id}"]
  subnet_id              = "${aws_subnet.public.0.id}"
  # init instance with init-common.sh
  user_data = "${data.template_cloudinit_config.init-common.rendered}"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "40"
    delete_on_termination = true
  }

  tags = "${ merge(local.tags, map("Name",format("%v-bastion",local.cluster_name))) }"

  lifecycle {
    ignore_changes = [
      "ami",
      "user_data",
      "associate_public_ip_address"
    ]
  }
  ## wait for routing tables ready
  depends_on = ["aws_route_table_association.public","aws_route_table_association.private"]
}
# wait for full host initialization. see provision/init-common.sh
resource "null_resource" "wait-bastion" {
  connection {
    type        = "ssh"
    host        = "${aws_instance.bastion.public_ip}"
    user        = "centos"
    private_key = "${file("${var.key_path_local}${var.key_name}")}"
  }
  # wait for signal from init script
  provisioner "remote-exec" {
    inline = [ "while [ ! -f /tmp/signal ]; do sleep 3; done" ]
  }
  # Changes to any instance of the cluster requires re-provisioning
  triggers {
    cluster_instance_ids = "${join(",", aws_instance.bastion.*.id)}"
  }
  depends_on = ["aws_instance.bastion"]
}

resource "null_resource" "init-bastion" {
  connection {
    type        = "ssh"
    host        = "${aws_instance.bastion.public_ip}"
    user        = "centos"
    private_key = "${file("${var.key_path_local}${var.key_name}")}"
  }
  ## put private key to bastion to access other machines in cloud
  provisioner "file" {
    source        = "${var.key_path_local}${var.key_name}"
    destination   = "/home/centos/.ssh/id_rsa"
  }
  # put shell to instance & init instance
  provisioner "file" {
    content       = "${data.template_file.init-bastion.rendered}"
    destination   = "/home/centos/provision/init-instance.sh"
  }
  ## put static files to master
  provisioner "file" {
    source        = "${path.module}/provision/bastion/"
    destination   = "/home/centos/provision"
  }

  provisioner "remote-exec" {
    inline = [
      "${ file( format("%v/provision/init-instance-inline.sh",path.module) ) }"
    ]
  }
  depends_on=["null_resource.wait-bastion"]
}

# post-init of the bastion
resource "null_resource" "finit-bastion" {
  connection {
    type        = "ssh"
    host        = "${aws_instance.bastion.public_ip}"
    user        = "centos"
    private_key = "${file("${var.key_path_local}${var.key_name}")}"
  }
  # copy kube-config from the master to bastion.
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/centos/.kube",
      "scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null master.${var.dns_domain}:/home/centos/.kube/config /home/centos/.kube/config"
    ]
  }
  depends_on=["null_resource.init-bastion","null_resource.init-master"]
}

# customized post-init of the bastion
resource "null_resource" "bastion_post_init" {
  count = "${ length(var.bastion_post_init)>0 ? 1 : 0 }"
  connection {
    type        = "ssh"
    host        = "${aws_instance.bastion.public_ip}"
    user        = "centos"
    private_key = "${file("${var.key_path_local}${var.key_name}")}"
  }
  # copy kube-config from the master to bastion.
  provisioner "remote-exec" {
    inline = "${var.bastion_post_init}"
  }
  depends_on=["null_resource.init-bastion","null_resource.init-master"]
}

data "template_file" "init-bastion" {
  template = "${file("${path.module}/provision/init-bastion.sh")}"

  vars {
    tf_hostname   = "bastion"
  }
}


