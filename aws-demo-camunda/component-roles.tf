#--------------------------------------------------------------------------------
# predefine hosts ports here to use in confgs
#--------------------------------------------------------------------------------

data "null_data_source" "component_hosts" {
  inputs = {
    bpm  = "${module.kub.hostname}"
  }
}


## hosts and ports separated because hosts are evaluated and ports - are constants
locals {
  component_ports = {
    # port_name = "local node public"
    bpm = {
      http   = "8080 31180 8080 HTTP"
    }
  }
}

