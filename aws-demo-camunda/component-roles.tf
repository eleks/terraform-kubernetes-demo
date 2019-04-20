#--------------------------------------------------------------------------------
# predefine hosts ports here to use in confgs
#--------------------------------------------------------------------------------

data "null_data_source" "component_hosts" {
  inputs = {
    bpm      = "${module.kub.hostname}"
    grafana  = "${module.kub.hostname}"
  }
}


## hosts and ports separated because hosts are evaluated and ports - are constants
locals {
  component_ports = {
    # port_name = "local node public"
    bpm = {
      http    = "8080 31180 8080 HTTP"
      # https   = "8080 31180 8043 HTTP"   # expose https=8043
    }
    grafana = {
      https   = "3000 31190 3000 HTTP"
    }
  }
}

