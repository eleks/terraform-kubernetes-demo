## module to declare wso2 component in kubernetes

# variables
variable "name"      {}
variable "namespace" { default = "default" }
variable "image"     {}
variable "replicas"  {}
variable "mem_min"   {}
variable "mem_max"   {}
variable "cpu_min"   {}
variable "cpu_max"   {}
variable "command"   { default="wso2server.sh" }
variable "ports"     {
  # this parameter used to expose service ports on nodes
  type = "map"
  default = {}
}
variable "persistent_root" {
  default = "/opt/persistent"
}
# variable just to implement depends-on values
variable "depends_on"{ default = [], type = "list"}

locals {
  ports = "${values(var.ports)}"
}

output "ports"{
  value = "${jsonencode(var.ports)}"
}

resource "kubernetes_deployment" "component-deploy" {
  metadata {
    name = "${var.name}"
    namespace = "${var.namespace}"
    labels {
      name = "${var.name}"
    }
    annotations {
      depends_on = "${jsonencode(var.depends_on)}"
    }
  }
  lifecycle {
    ignore_changes = [
      "metadata.0.annotations.depends_on",
      "metadata.0.annotations.%",
    ]
  }

  spec {
    selector {
      match_labels {
        name = "${var.name}"
      }
    }
    replicas = "${var.replicas}"

    template {
      metadata {
        labels {
          name = "${var.name}"
        }
      }
      spec {
        container {
          name  = "${var.name}"
          image = "${var.image}"
          #command = "${var.command}"

          resources{
            limits{
              cpu    = "${var.cpu_max}"
              memory = "${var.mem_max}"
            }
            requests{
              cpu    = "${var.cpu_min}"
              memory = "${var.mem_min}"
            }
          }
          env {
            name  = "ENTRYPOINT"
            value = "${var.command}"
          }
          env {
            name  = "ROLE"
            value = "${var.name}"
          }
          env {
            name  = "PERSISTENT_ROOT"
            value = "${var.persistent_root}"
          }
          volume_mount {
            name      = "mnt-volume"
            mount_path = "/opt/persistent"
          }

        }
        volume {
          name = "mnt-volume"
          persistent_volume_claim {
            claim_name = "default-nfs-claim"
          }
        }
      }
    }
  }
}
