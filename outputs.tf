output "account_id" {
  description = "AWS Account ID."
  value       = data.aws_caller_identity.current.account_id
}

output "elb_dns" {
  description = "Elastic Load Balancer URL."
  value       = aws_lb.app.dns_name
}

output "rds_endpoint" {
  description = "Aurora DB endpoint."
  value       = aws_rds_cluster.aurora.endpoint
}