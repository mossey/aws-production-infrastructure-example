resource "aws_rds_cluster_instance" "cluster_instances" {
  engine             = "aurora-mysql"
  engine_version     = "5.7.mysql_aurora.2.03.2"
  identifier         = "${var.cluster_name}-instance"
  cluster_identifier =  aws_rds_cluster.cluster.id
  instance_class     = var.instance_class
}

resource "aws_rds_cluster" "cluster" {
  engine             = "aurora-mysql"
  engine_version     = "5.7.mysql_aurora.2.03.2"
  cluster_identifier     = var.cluster_name
  database_name          = "sample_rds"
  master_username        = var.username
  master_password        = var.password
  vpc_security_group_ids = [aws_security_group.aurora-sg.id]
  db_subnet_group_name   = var.db-subnet-group-name
  skip_final_snapshot    = true
}

resource "aws_security_group" "aurora-sg" {
  name   = "aurora-security-group"
  vpc_id = aws_vpc.database_vpc.id

  ingress {
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    cidr_blocks = ["10.1.0.0/16", "10.3.0.0/16", "10.2.0.0/16"]
  }

  egress {
    protocol    = -1
    from_port   = 0 
    to_port     = 0 
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "db-subnet-group-name" {
  default = "database_subnet_group"
}
variable "engine" {
  default = "aurora-mysql"
}


variable "cluster_name" {
  default = "production-rds-cluster"
} 
  
variable "instance_class" {
  default = "db.t2.small"
}

variable "username" {
  default = "master"
}

variable "password" {
  default = "password"
}