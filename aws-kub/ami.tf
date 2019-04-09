#-----------------------------------------------------------------
#--Get available Amazon Machine Image Names
#-----------------------------------------------------------------
data "aws_availability_zones" "available" {}
data "aws_ami" "centos_ami" {
  most_recent      = true

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
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
