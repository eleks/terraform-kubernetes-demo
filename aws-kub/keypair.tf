#--------------------------------------------------------
#--Import pre-generated key-pair to aws
#--------------------------------------------------------
resource "aws_key_pair" "deployer" {
  key_name   = "${var.key_name}"
  public_key = "${file("${var.key_path_local}${var.key_name}.pub")}"
}