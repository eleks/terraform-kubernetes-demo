#--------------------------------------------------------
#--Create EC2 instances
#--------------------------------------------------------
#--Masters
#--------------------------------------------------------
resource "aws_instance" "master" {
  availability_zone      = "${data.aws_availability_zones.available.names[0]}"
  ami                    = "${data.aws_ami.centos_ami.image_id}"
  instance_type          = "${var.master_flavor}"
  key_name               = "${var.key_name}"
  vpc_security_group_ids = ["${aws_security_group.master.id}"]
  subnet_id              = "${aws_subnet.private.0.id}"
  # init instance with init-common.sh
  user_data = "${data.template_cloudinit_config.init-common.rendered}"

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "50"
    delete_on_termination = true
  }

  tags = "${ merge(local.tags, map("Name",format("%v-master",local.cluster_name))) }"

  lifecycle {
    ignore_changes = [
      "user_data"
    ]
  }
  ## wait for routing tables ready
  depends_on = ["aws_route_table_association.public","aws_route_table_association.private"]
}

# wait for full host initialization. see provision/init-common.sh
resource "null_resource" "wait-master" {
  connection {
    bastion_host= "${aws_instance.bastion.public_ip}"
    type        = "ssh"
    host        = "master.${var.dns_domain}"
    user        = "centos"
    private_key = "${file("${var.key_path_local}${var.key_name}")}"
  }
  # wait for signal from init script
  provisioner "remote-exec" {
    inline = [ "while [ ! -f /tmp/signal ]; do sleep 3; done" ]
  }
  # Changes to any instance of the cluster requires re-provisioning
  triggers {
    cluster_instance_ids = "${join(",", aws_instance.master.*.id)}"
  }
  depends_on = [ "aws_instance.master" ]
}

resource "null_resource" "init-master" {
  connection {
    bastion_host= "${aws_instance.bastion.public_ip}"
    type        = "ssh"
    host        = "master.${var.dns_domain}"
    user        = "centos"
    private_key = "${file("${var.key_path_local}${var.key_name}")}"
  }
  ## put static files to master
  provisioner "file" {
    source        = "${path.module}/provision/master/"
    destination   = "/home/centos/provision"
  }
  # put shell to instance & init instance
  provisioner "file" {
    content       = "${data.template_file.init-master.rendered}"
    destination   = "/home/centos/provision/init-instance.sh"
  }
  # auth static file for kubeapi
  provisioner "file" {
    content       = "${var.kubeapi_token},deployer,1"
    destination   = "/home/centos/provision/auth.csv"
  }

  provisioner "remote-exec" {
    inline = [
      "${ file( format("%v/provision/init-instance-inline.sh",path.module) ) }"
      #"set -e",
      #"chmod +x /home/centos/provision/init-instance.sh",
      #"LOG_FILE=/home/centos/provision/init-instance.log",
      #"/home/centos/provision/init-instance.sh &> $LOG_FILE || (>&2 tail -20 $LOG_FILE && exit 1 )" ,
      #"echo SUCCESS"
    ]
  }
  depends_on=["null_resource.wait-master"]
}


# generate bootstapped token for kubeadm
resource "random_shuffle" "kubeadm_token1" {
  input = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "a", "b", "c", "d", "e", "f", "g", "h", "i", "t", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
  result_count = 6
}

resource "random_shuffle" "kubeadm_token2" {
  input = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "a", "b", "c", "d", "e", "f", "g", "h", "i", "t", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
  result_count = 16
}

data "template_file" "kubeadm_token" {
  template = "$${v1}.$${v2}"
  vars {
    v1 = "${join("",random_shuffle.kubeadm_token1.result)}"
    v2 = "${join("",random_shuffle.kubeadm_token2.result)}"
  }
}


data "template_file" "init-master" {
  template = "${file("${path.module}/provision/init-master.sh")}"

  vars {
    tf_hostname      = "master"
    tf_kubeadm_token = "${data.template_file.kubeadm_token.rendered}"
    tf_kubeadm_host  = "${aws_lb.frontend.dns_name}"
    tf_master_ip     = "${element(aws_instance.master.*.private_ip, 0)}"
  }
}
