# the `key` that represents that odule is ready
output "ready" {
  value = "${null_resource.deploy.id}"
}
