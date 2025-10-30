# output "vpc_id" {
#   value       = aws_vpc.vpc.id
#   description = "ID of the OTMS VPC"
# }

# output "vpc_cidr_block" {
#   description = "The CIDR block of the VPC"
#   value       = aws_vpc.vpc.cidr_block
# }



# output "igw_id" {
#   description = "Internet Gateway ID"
#   value       = aws_internet_gateway.igw.id
# }

# output "nat_gateway_ids" {
#   description = "List of NAT Gateway IDs"
#   value       = [for nat in aws_nat_gateway.nat_gateway : nat.id]
# }

# output "public_rt_id" {
#   value = aws_route_table.public_rt.id
# }

# output "privat_rt_id" {
#   value = aws_route_table.private_rt.id
# }


# output "subnet_ids" {
#   value = {
#     for subnet in aws_subnet.subnets :
#     subnet.tags.Name => subnet.id
#   }
# }


# output "public_subnet_ids" {
#   description = "List of public subnet IDs"
#   value       = local.public_subnet_ids
# }

# output "private_subnet_ids" {
#   description = "List of private subnet IDs"
#   value       = local.private_subnet_ids
# }

# output "application_subnet_ids" {
#   description = "List of application subnet IDs"
#   value       = local.application_subnet_ids
# }

# output "database_subnet_ids" {
#   description = "List of database subnet IDs"
#   value       = local.database_subnet_ids
# }



output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc.id
}

output "default_security_group_id" {
  description = "The ID of the default security group created with VPC"
  value       = aws_vpc.vpc.default_security_group_id
}

output "igw_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.igw.id
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs (if created)"
  value       = var.create_nat_gateway ? [for nat in aws_nat_gateway.nat_gateway : nat.id] : []
}

output "public_route_table_id" {
  description = "Public route table ID"
  value       = aws_route_table.public_rt.id
}

output "private_route_table_id" {
  description = "Private route table ID"
  value       = aws_route_table.private_rt.id
}

output "subnet_ids" {
  description = "Map of subnet name => id"
  value = {
    for subnet in aws_subnet.subnets :
    subnet.tags["Name"] => subnet.id
  }
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = local.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = local.private_subnet_ids
}

output "application_subnet_ids" {
  description = "List of application subnet IDs"
  value       = local.application_subnet_ids
}

output "database_subnet_ids" {
  description = "List of database subnet IDs"
  value       = local.database_subnet_ids
}

output "nacl_ids" {
  description = "Map of NACL name => id"
  value = var.create_nacl ? { for k, v in aws_network_acl.nacls : k => v.id } : {}
}

output "security_group_ids" {
  description = "Map of custom security group key => id"
  value = var.create_sg ? { for k, v in aws_security_group.sg : k => v.id } : {}
}



##########################################
# Key Pair
##########################################
output "key_pair_name" {
  description = "Key pair name"
  value       = aws_key_pair.key_pair[0].key_name
}

output "private_key_path" {
  description = "Path to generated private key"
  value       = "${var.key_output_dir}/${var.key_pair_name}.pem"
}

##########################################
# EC2 Instances
##########################################
output "bastion_instance_public_ip" {
  description = "Bastion public IP (Elastic IP)"
  value       = var.allocate_elastic_ip ? aws_eip.bastion_eip[0].public_ip : null
}

output "private_instance_ids" {
  description = "Private instance IDs"
  value       = [for instance in aws_instance.private_instances : instance.id]
}

