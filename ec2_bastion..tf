data "aws_ami" "ec2_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"]
}

resource "aws_kms_key" "ebs" {
  description             = "KMS key to encrypt EBS"
  enable_key_rotation     = true
  deletion_window_in_days = 30
}

resource "aws_kms_key_policy" "ebs" {
  key_id = aws_kms_key.ebs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "${local.env}-${local.platform}-${local.app}-kms-01"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        },
        Action   = "kms:*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_instance" "ec2_bastion" {
  ami                         = data.aws_ami.ec2_ami.id
  instance_type               = var.asg_instance_type
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  subnet_id                   = aws_subnet.bastion.id
  monitoring                  = true
  associate_public_ip_address = true
  ebs_optimized               = true

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type           = var.ebs_volume_type
    volume_size           = var.ebs_volume_size
    delete_on_termination = true
    encrypted             = true
    kms_key_id            = aws_kms_key.ebs.id
  }

  tags = local.tags
}