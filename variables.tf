variable "aws_region" {
  description = "AWS Region, i.e. us-west-1"
  type        = string
  default     = "ap-southeast-2"
}


# EC2 Auto Scaling
variable "asg_instance_type" {
  description = "Auto scaling group instace type"
  type        = string
  default     = "t2.micro"
}

variable "asg_name_prefix" {
  description = "Prefix name to be used in the ASG resource"
  type        = string
  default     = "asg_template"
}

variable "ebs_device_name" {
  description = "EBS device name"
  type        = string
  default     = "/dev/xvda"
}

variable "ebs_volume_size" {
  description = "EBS device size"
  type        = number
  default     = 20
}

variable "ebs_volume_type" {
  description = "EBS device type"
  type        = string
  default     = "gp2"
}


# ELB
variable "ssl_certificate_id" {
  description = "SSL Certificate ID to be used as HTTPS listener in the ELB."
  type        = string
  default     = "" # SSL Certificate required
}


# Route 53
variable "dns_zone_name" {
  description = "Name of the DNS Zone."
  type        = string
  default     = "an-example-of-aws-with-terraform.co.nz"
}

variable "dns_record_admins" {
  description = "Record A for allow accessing Admins using DNS."
  type        = string
  default     = "management.an-example-of-aws-with-terraform.co.nz"
}


# RDS AURORA
variable "db_engine" {
  description = "Type of RDS engine"
  type        = string
  default     = "aurora-mysql"
}

variable "db_identifier" {
  description = "Identifier to be used by the RDS Cluster"
  type        = string
  default     = "aurora-cluster"
}

variable "db_instance_class" {
  description = "Instance class for the RDS instances"
  type        = string
  default     = "db.t3.small"
}

variable "db_user" {
  description = "Username to be used by the RDS instances"
  type        = string
  default     = "" # It will be override for Github Actions Secrets. DO NOT USE CREDENTIALS IN THE CODE, NEVER.
}

variable "db_pass" {
  description = "Password to be used by the RDS instances"
  type        = string
  default     = "" # It will be override for Github Actions Secrets. DO NOT USE CREDENTIALS IN THE CODE, NEVER.
}