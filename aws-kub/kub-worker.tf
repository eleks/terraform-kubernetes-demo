#--------------------------------------------------------
#--Create EC2 instances
#--------------------------------------------------------
#--Workers
#--------------------------------------------------------
resource "aws_instance" "worker" {
  count                  = "${var.k8s_worker_count}"

  availability_zone      = "${data.aws_availability_zones.available.names[count.index]}"
  ami                    = "${data.aws_ami.centos_ami.image_id}"
  instance_type          = "${var.worker_flavor}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.worker.id}"]
  subnet_id              = "${element(aws_subnet.private.*.id, count.index)}"
  # init instance with init-common.sh
  user_data = "${data.template_cloudinit_config.init-common.rendered}"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "50"
    delete_on_termination = true
  }

  tags = "${ merge(local.tags, map("Name",format("%v-worker-%02d",local.cluster_name,count.index))) }"

  lifecycle {
    ignore_changes = [
      "user_data"
    ]
  }
  ## wait for routing tables ready
  depends_on = ["aws_route_table_association.public","aws_route_table_association.private"]
}

# wait for full host initialization. see provision/init-common.sh
resource "null_resource" "wait-worker" {
  count                  = "${var.k8s_worker_count}"

  connection {
    bastion_host= "${aws_instance.bastion.public_ip}"
    type        = "ssh"
    host        = "worker-${format("%02d",count.index)}.${var.dns_domain}"
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
  depends_on = ["aws_instance.worker"]
}

resource "null_resource" "init-worker" {
  count                  = "${var.k8s_worker_count}"

  connection {
    bastion_host= "${aws_instance.bastion.public_ip}"
    type        = "ssh"
    host        = "worker-${format("%02d",count.index)}.${var.dns_domain}"
    user        = "centos"
    private_key = "${file("${var.key_path_local}${var.key_name}")}"
  }
  # put shell to instance & init instance
  provisioner "file" {
    content       = "${element(data.template_file.init-worker.*.rendered,count.index)}"
    destination   = "/home/centos/provision/init-instance.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "${ file( format("%v/provision/init-instance-inline.sh",path.module) ) }"
    ]
  }
  depends_on=["null_resource.wait-worker"]
}

data "template_file" "init-worker" {
  count                  = "${var.k8s_worker_count}"

  template = "${file("${path.module}/provision/init-worker.sh")}"

  vars {
    tf_hostname      = "worker-${format("%02d",count.index)}"
    tf_kubeadm_token = "${data.template_file.kubeadm_token.rendered}"
    tf_master_host   = "master.${var.dns_domain}"
  }
}
