## terraform file to use certificates as module 

output "key" {
  value = "${ file("${path.module}/web-key.pem") }"
}

output "crt" {
  value = "${ file("${path.module}/web-crt.pem") }"
}
