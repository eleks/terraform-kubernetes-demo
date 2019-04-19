# define external ports on loadbalancer

variable "params" {
  # parameters required for specific port.
  type = "map"
  # defaults:
  # vpc_id          = "${aws_vpc.eleksintegration.id}"
  # certificate_arn = "${aws_iam_server_certificate.eleksintegration.arn}"
  # public_arn      = "${aws_lb.frontend.arn}"
  # target_id       = "${aws_instance.master.0.private_ip}"
  # cluster_name    = "local.cluster_name"
}
variable "port"  {} # port name from ports map 
variable "ports" {
  # ports in format: { port =  "local kuber public ?priv_protocol" } 
  type = "map"
}
variable "tags"  {
  # no need to define tags. however...
  type = "map"
  default = {}
}
# variable to implement depends-on values. not used inside module...
variable "depends_on"{ default = [], type = "list"}
variable "health_interval" {default=300}


locals {
  default_tags = { 
    Env="${terraform.workspace}"
    Terraform="true"
  }
  tags = "${ merge(local.default_tags, var.tags) }"

  port_list = "${ split( " ", var.ports[var.port] ) }"
  public_port = "${local.port_list[2]}"
  target_port = "${local.port_list[1]}"
  public_protocol = "${ length(split("https",var.port))>1 ? "HTTPS" : "HTTP" }"
  target_protocol = "${ length(local.port_list)>3 ? element(local.port_list,3) : local.public_protocol }"

}

output "public_port" {
  value = "${local.public_port}"
}
output "public_protocol" {
  value = "${ lower(local.public_protocol) }"
}
output "target_port" {
  value = "${local.target_port}"
}
output "target_protocol" {
  value = "${local.target_protocol}"
}

#--------------------------------------------------------
#-- Listener 
#--------------------------------------------------------
resource "aws_lb_listener" "listener-https" {
  count = "${ local.public_protocol=="HTTPS" ? 1 : 0 }"
  load_balancer_arn = "${var.params["public_arn"]}"
  port              = "${ local.public_port }"
  protocol          = "${ local.public_protocol }"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-1-2017-01"
  certificate_arn   = "${var.params["certificate_arn"]}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.target.arn}"
  }
}

resource "aws_lb_listener" "listener-http" {
  count = "${ local.public_protocol=="HTTP" ? 1 : 0 }"
  load_balancer_arn = "${var.params["public_arn"]}"
  port              = "${ local.public_port }"
  protocol          = "${ local.public_protocol }"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.target.arn}"
  }
}

#--------------------------------------------------------
#-- Target group
#--------------------------------------------------------
resource "aws_lb_target_group" "target" {
  name = "${var.params["cluster_name"]}-${local.public_port}-to-${local.target_port}"

  deregistration_delay = 30
  port                 = "${ local.target_port }"
  protocol             = "${ local.target_protocol }"
  slow_start           = 30
  target_type          = "ip"
  vpc_id               = "${ var.params["vpc_id"] }"

  health_check {
    healthy_threshold   = 3
    matcher             = "200-399"
    path                = ""
    protocol            = "${ local.target_protocol }"
    timeout             = 5
    unhealthy_threshold = 5
    interval            = "${var.health_interval}"
  }

  stickiness {
    enabled = false
    type    = "lb_cookie"
  }

  tags {
    Env = "${terraform.workspace}"
    Terraform="true"
  }
}
#---------------------------------------------------------
resource "aws_lb_target_group_attachment" "attachment" {
  target_group_arn  = "${aws_lb_target_group.target.arn}"
  target_id         = "${ var.params["target_id"] }"
  #depends_on        = ["aws_instance.master"]
}
