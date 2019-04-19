#--------------------------------------------------------
#--Create Application LoadBalancer
#--------------------------------------------------------

#--------------------------------------------------------
#--Creating self-signed certificates
#--------------------------------------------------------
resource "aws_iam_server_certificate" "web" {
  name             = "web"
  private_key      = "${var.certificate_key}"
  certificate_body = "${var.certificate_body}"
  lifecycle {
    ignore_changes = [
      # somehow following tags in state differ from specified in the input///
      "id", "certificate_body", "certificate_chain"
    ]
  }
}

#--------------------------------------------------------
#--Create Application LoadBalancer
#--------------------------------------------------------
resource "aws_lb" "frontend" {
  name               = "${local.cluster_name}-alb"

  enable_deletion_protection = false
  enable_http2               = true
  idle_timeout               = 60
  internal                   = false
  ip_address_type            = "ipv4"
  load_balancer_type         = "application"
  security_groups            = ["${aws_security_group.lb.id}"]
  subnets                    = ["${aws_subnet.public.*.id}"]

  tags = "${ merge(local.tags, map("Name",format("%v front load balancer",local.cluster_name))) }"
}
