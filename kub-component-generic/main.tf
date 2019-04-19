## module to declare some generic component in kubernetes

# deploy variables
variable "ssh_host"           {}
variable "ssh_user"           { default = "centos" }
variable "key_path_local"     { default = "~/.ssh/" }
variable "key_name"           { default = "deployer-key" }

# component variables
variable "name"      {}
variable "namespace" { default = "default" }
variable "image"     {}
variable "replicas"  { default="1"     }
variable "mem_min"   { default="256Mi" }
variable "mem_max"   { default="1Gi"   }
variable "cpu_min"   { default="0.5"   }
variable "cpu_max"   { default="1"     }
variable "command"   { default=""      }
variable "ports"     {
  # this parameter used to expose service ports on nodes
  # in format     name = "local node public"   (only local and node used)
  type = "map"
  default = {}
}
# NOTE: just one volume for now supported! waiting for v0.12 for more
# calin-based volumes definition. list in format claim-name:mount-folder:subpath
variable "claim_volumes" {
  type = "list"
  default = [ "default-nfs-claim:/opt/persistent:" ]
}

variable "env"     {
  # environment variables
  type = "map"
  default = {}
}

# variable just to implement depends-on values
variable "depends_on"{ default = [], type = "list"}

locals {
  ports = "${values(var.ports)}"
}

output "ports"{
  value = "${jsonencode(var.ports)}"
}

data "template_file" "env" {
  count    = "${length( keys(var.env) )}"
  template = "${file( "${path.module}/templates/env.yml" )}"
  vars {
    tf_key   = "${ element(keys(var.env),count.index) }"
    tf_value = "${ element(values(var.env),count.index) }"
  }
}

data "template_file" "claim_mounts" {
  count    = "${length( var.claim_volumes )}"
  template = "${file( "${path.module}/templates/claim_mounts.yml" )}"
  vars {
    tf_name       = "${replace(var.claim_volumes[count.index], "/[^a-zA-Z]+/", "-")}${count.index}"
    tf_mount_path = "${ element(split(":", "${var.claim_volumes[count.index]}::"),1) }"
    tf_sub_path   = "${ element(split(":", "${var.claim_volumes[count.index]}::"),2) }"
  }
}

data "template_file" "claim_volumes" {
  count    = "${length( var.claim_volumes )}"
  template = "${file( "${path.module}/templates/claim_volumes.yml" )}"
  vars {
    tf_name       = "${replace(var.claim_volumes[count.index], "/[^a-zA-Z]+/", "-")}${count.index}"
    tf_claim_name = "${ element(split(":", "${var.claim_volumes[count.index]}::"),0) }"
  }
}

data "template_file" "service_ports" {
  count    = "${length( local.ports )}"
  template = "${file( "${path.module}/templates/service_ports.yml" )}"
  vars {
    tf_name       = "${ var.name }"
    tf_port_local = "${ element(split(" ",element(local.ports,count.index)),0) }"
    tf_port_node  = "${ element(split(" ",element(local.ports,count.index)),1) }"
  }
}

# render templates here
data "template_file" "component-yml" {
  template = "${file( "${path.module}/templates/component.yml" )}"
  vars  = {
    tf_name      = "${var.name}"
    tf_namespace = "${var.namespace}"
    tf_image     = "${var.image}"
    tf_env       = "${ join("", data.template_file.env.*.rendered) }"
    tf_cpu_max   = "${var.cpu_max}"
    tf_mem_max   = "${var.mem_max}"
    tf_cpu_min   = "${var.cpu_min}"
    tf_mem_min   = "${var.mem_min}"
    tf_claim_mounts    = "${ join("", data.template_file.claim_mounts.*.rendered) }"
    tf_claim_volumes   = "${ join("", data.template_file.claim_volumes.*.rendered) }"
    tf_service_ports   = "${ join("", data.template_file.service_ports.*.rendered) }"
  }
}

resource "null_resource" "apply" {
  count = "1"
  connection {
    type        = "ssh"
    host        = "${var.ssh_host}"
    user        = "${var.ssh_user}"
    private_key = "${file("${var.key_path_local}${var.key_name}")}"
  }

  provisioner "file" "component-yml" {
    when = "create"
    content       = "${data.template_file.component-yml.rendered}"
    destination   = "/home/${var.ssh_user}/provision/kub-component-${var.namespace}-${var.name}.yml"
  }

  provisioner "remote-exec" "apply"{
    when = "create"
    inline = [
      "echo ${ join(",",var.depends_on) }",    ## just to make the depends_on parameter working
      "kubectl apply -f /home/${var.ssh_user}/provision/kub-component-${var.namespace}-${var.name}.yml"
    ]
  }

  provisioner "remote-exec" "destroy"{
    when = "destroy"
    inline = [
      ## "echo ${ join(",",var.depends_on) }",    ## just to make the depends_on parameter working
      "kubectl delete -f /home/${var.ssh_user}/provision/kub-component-${var.namespace}-${var.name}.yml",
      "mv -f /home/${var.ssh_user}/provision/kub-component-${var.namespace}-${var.name}.yml /home/${var.ssh_user}/provision/kub-component-${var.namespace}-${var.name}.yml.bak"
    ]
  }
}

