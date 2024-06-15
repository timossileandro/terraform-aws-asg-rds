resource "aws_kms_key" "db" {
  description             = "KMS key to be used by RDS"
  enable_key_rotation     = true
  deletion_window_in_days = 30
}

resource "aws_rds_cluster" "aurora" {
  cluster_identifier     = var.db_identifier
  engine                 = var.db_engine
  master_username        = var.db_user
  master_password        = var.db_pass
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
}

resource "aws_rds_cluster_instance" "aurora_instances" {
  count                = 2
  identifier           = "${var.db_identifier}-instance-${count.index}"
  cluster_identifier   = aws_rds_cluster.aurora.id
  instance_class       = var.db_instance_class
  engine               = aws_rds_cluster.aurora.engine
  engine_version       = aws_rds_cluster.aurora.engine_version
  publicly_accessible  = false
  db_subnet_group_name = aws_db_subnet_group.rds.id
}