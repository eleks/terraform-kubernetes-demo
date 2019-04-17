## all module outputs here

output "bastion-ip" {
  value = "${join(",",aws_instance.bastion.*.public_ip)}"
}

output "vpc_id" {
  value = "${aws_vpc.home.id}"
}

output "dashboard" {
  value = "https://${aws_lb.frontend.dns_name}"
}

output "hostname" {
  value = "${aws_lb.frontend.dns_name}"
}
# the `key` that represents that kub is ready
output "ready" {
  value = "${kubernetes_persistent_volume_claim.default-nfs-claim.metadata.0.uid}"
}

# use the following to use as default listeners params:
# to combine it back to map use:
# zipmap(module.kub.default_port_keys, module.kub.default_port_values)
output "default_port_keys" {
  value = "${ keys(data.null_data_source.default_port_params.outputs) }"
}
output "default_port_values" {
  value = "${ values(data.null_data_source.default_port_params.outputs) }"
}

