# service with 3 ports

resource "kubernetes_service" "component-service-p3" {
  ## run this one or not. in terraform 0.12 we could use for_each
  count = "${length(var.ports) == 3 ? 1 : 0}"

  metadata {
  	## service name to access inside kuber
    name = "${var.name}"
    namespace = "${var.namespace}"
    labels{
      name = "${var.name}"
    }
  }
  spec {
    selector {
      name = "${var.name}"
    }
    session_affinity = "ClientIP"
    type = "NodePort"

    port {
      name        = "port-${var.name}-${ element(split(" ",element(local.ports,0)),0) }-${ element(split(" ",element(local.ports,0)),1) }"
      port        =                  "${ element(split(" ",element(local.ports,0)),0) }"
      target_port =                  "${ element(split(" ",element(local.ports,0)),0) }"
      node_port   =                  "${ element(split(" ",element(local.ports,0)),1) }"
    }
    port {
      name        = "port-${var.name}-${ element(split(" ",element(local.ports,1)),0) }-${ element(split(" ",element(local.ports,1)),1) }"
      port        =                  "${ element(split(" ",element(local.ports,1)),0) }"
      target_port =                  "${ element(split(" ",element(local.ports,1)),0) }"
      node_port   =                  "${ element(split(" ",element(local.ports,1)),1) }"
    }
    port {
      name        = "port-${var.name}-${ element(split(" ",element(local.ports,2)),0) }-${ element(split(" ",element(local.ports,2)),1) }"
      port        =                  "${ element(split(" ",element(local.ports,2)),0) }"
      target_port =                  "${ element(split(" ",element(local.ports,2)),0) }"
      node_port   =                  "${ element(split(" ",element(local.ports,2)),1) }"
    }
  }
  depends_on = ["kubernetes_deployment.component-deploy"]
}

