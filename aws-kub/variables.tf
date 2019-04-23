#--------------------------------------------------------
#--General variables section
#--------------------------------------------------------
#variable "aws_access_key"     {}
#variable "aws_secret_key"     {}
variable "kubeapi_token"      { default = "" }  # predefined token to access kubernetes api&dashboard. if empty it will be generated automatically

variable "cluster_name"       { default = "" }
#variable "aws_region"         { default = "us-west-1" }
variable "aws_az_count"       { default = 2 } # must be minimum 2 to use load balancer

variable "aws_cidr"           { default = "172.16.0.0/16" }
variable "flannel_cidr"       { default = "10.244.0.0/16" }
variable "key_name"           { default = "deployer-key" }
variable "key_path_local"     { default = "~/.ssh/" }
variable "dns_domain"         { default = "cloud.local" }
variable "tags"               {
  type = "map"
  default = {}
}

variable "k8s_worker_count"   { default = 1 }
variable "master_flavor"      { default = "t2.medium" }
variable "worker_flavor"      { default = "t2.medium" }
variable "bastion_flavor"     { default = "t2.micro" }

variable "certificate_key"    {  }
variable "certificate_body"   {  }

# shell commands to run on bastion after initialization finished on bastion and kub-master
variable "bastion_post_init"  {
  type    = "list"
  default = []
}

locals {
  cluster_name = "${ length(var.cluster_name)>0 ? var.cluster_name : terraform.workspace }"
  default_tags = {
    Env="${terraform.workspace}"
    Terraform="true"
  }
  tags = "${ merge(local.default_tags, var.tags) }"
}
