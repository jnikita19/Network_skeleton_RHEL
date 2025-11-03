
output "private_instance_ids" {
  description = "IDs of the private EC2 instances"
  value       = aws_instance.private_instances[*].id
}

output "private_instance_private_ips" {
  description = "Private IP addresses of the EC2 instances"
  value       = aws_instance.private_instances[*].private_ip
}

output "private_instance_availability_zones" {
  description = "Availability zones of the EC2 instances"
  value       = aws_instance.private_instances[*].availability_zone
}

output "private_instance_subnet_ids" {
  description = "Subnet IDs where the private instances are launched"
  value       = aws_instance.private_instances[*].subnet_id
}

output "private_instance_tags" {
  description = "Tags assigned to each private instance"
  value       = aws_instance.private_instances[*].tags
}

output "key_pair_used" {
  description = "The key pair used for private EC2 instances"
  value       = var.key_name
}

output "security_group_used" {
  description = "The security group associated with the private EC2 instances"
  value       = var.security_group_id
}
