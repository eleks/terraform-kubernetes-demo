# database mysql
output "mysql-address" {
  value = "${aws_db_instance.mysql.address}:${aws_db_instance.mysql.port}"
}

resource "aws_security_group" "mysql" {
  name        = "${terraform.workspace}-mysql-sg"
  description = "Security group for mysql"
  # vpc_id      = "${module.kub.vpc_id}"

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags={
    Env="${terraform.workspace}"
    Terraform="true"
  }
}

resource "aws_db_instance" "mysql" {
  identifier          = "${terraform.workspace}-db"
  allocated_storage    = 20
  storage_type         = "standard"  #gp2
  engine               = "mysql"
  engine_version       = "5.6"
  instance_class       = "db.t2.micro"
  name                 = "camunda_demo"
  username             = "${var.tf_db_user}"
  password             = "${var.tf_db_pass}"
  parameter_group_name = "default.mysql5.6"
  skip_final_snapshot = true
  vpc_security_group_ids=[ "${aws_security_group.mysql.id}" ]
  copy_tags_to_snapshot=true
  publicly_accessible = true
  tags={
    Env="${terraform.workspace}"
    Terraform="true"
  }
}

module "db-init" {
  source = "../bastion-sh"
  ssh_host = "${module.kub.bastion-ip}"
  inline = [
    "mysql -u${var.tf_db_user} -p${var.tf_db_pass} -h${aws_db_instance.mysql.address} -P${aws_db_instance.mysql.port} < /var/nfs/persistent/bpm-sql/camunda.sql",
    "mysql -u${var.tf_db_user} -p${var.tf_db_pass} -h${aws_db_instance.mysql.address} -P${aws_db_instance.mysql.port} < /var/nfs/persistent/bpm-sql/camunda_demo.sql",
  ]
}


#resource "aws_db_snapshot" "mysql" {
#  db_instance_identifier = "${aws_db_instance.mysql.id}"
#  db_snapshot_identifier = "${terraform.workspace}-snapshot"
#}
