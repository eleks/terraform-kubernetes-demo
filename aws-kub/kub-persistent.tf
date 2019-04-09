#----------------------------------------------------------------------------
#-- declare default persistent storage in the kubicus vulgaris :)
#----------------------------------------------------------------------------

# declare persistent storage 
resource "kubernetes_persistent_volume" "default-nfs-volume" {
  metadata {
    name = "default-nfs-volume"
    annotations = "${local.tags}"
  }
  spec {
    capacity {
      storage = "2Gi"
    }
    access_modes = ["ReadWriteMany"]
    persistent_volume_source {
      nfs {
        server = "${aws_route53_record.bastion.fqdn}"
        path   = "/var/nfs/persistent"
      }
    }
  }
  # master & api must be ready
  depends_on = ["null_resource.init-master", "module.port-kubeapi" ]
}
# declare claim
resource "kubernetes_persistent_volume_claim" "default-nfs-claim" {
  metadata {
    name = "default-nfs-claim"
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests {
        storage = "2Gi"
      }
    }
    volume_name = "${kubernetes_persistent_volume.default-nfs-volume.metadata.0.name}"
  }
}

