#--------------------------------------------------------
#--Create private DNS entries
#--------------------------------------------------------
resource "aws_route53_zone" "private" {
  name = "${var.dns_domain}"

  vpc {
    vpc_id = "${aws_vpc.home.id}"
  }

  tags = "${ merge(local.tags, map("Name",format("%v private zone",local.cluster_name))) }"
}
#--------------------------------------------------------
#--Register bastion node
#--------------------------------------------------------
resource "aws_route53_record" "bastion" {
  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "bastion"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.bastion.private_ip}"]

  depends_on = ["aws_instance.bastion"]
}
#--------------------------------------------------------
#--Register baster nodes
#--------------------------------------------------------

resource "aws_route53_record" "master" {
  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "master"
  type    = "A"
  ttl     = "300"
  records = ["${element(aws_instance.master.*.private_ip, 0)}"]

  depends_on = ["aws_instance.master"]
}
#--------------------------------------------------------
#--Register worker nodes
#--------------------------------------------------------
resource "aws_route53_record" "worker" {
  count   = "${var.k8s_worker_count}"

  zone_id = "${aws_route53_zone.private.zone_id}"
  name    = "worker-${format("%02d",count.index)}"
  type    = "A"
  ttl     = "300"
  records = ["${element(aws_instance.worker.*.private_ip, count.index)}"]

  depends_on = ["aws_instance.worker"]
}
