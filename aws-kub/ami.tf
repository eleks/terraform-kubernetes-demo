#-----------------------------------------------------------------
#--Get available Amazon Machine Image Names
#-----------------------------------------------------------------
data "aws_availability_zones" "available" {}
data "aws_ami" "centos_ami" {
  most_recent      = true
  owners           = ["amazon","self","aws-marketplace"]

  filter {
    name   = "name"
    values = ["${var.image_filter_name}"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}
