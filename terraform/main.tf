

######################################
# VPC
######################################
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = var.instance_tenancy
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    {
      Name = "${local.base_name}-vpc"
    },
    local.common_tags
  )
}

######################################
# Subnets
######################################
resource "aws_subnet" "subnets" {
  count = length(local.subnets)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = local.subnets[count.index].cidr
  availability_zone = local.subnets[count.index].avail_zone

  tags = merge(
    {
      Name = local.subnets[count.index].name
      # add cluster tag only if needed
      "kubernetes.io/cluster/${var.env}-${var.program}-eks-cluster" = "owned"
    },
    local.common_tags
  )
}

######################################
# Internet Gateway
######################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    {
      Name = "${local.base_name}-igw"
    },
    local.common_tags
  )
}

######################################
# Elastic IPs for NAT Gateways
######################################
resource "aws_eip" "nat" {
  count  = var.create_nat_gateway ? var.nat_gateway_count : 0
  domain = "vpc"

  tags = merge(
    {
      Name = "${local.base_name}-nat-eip-${count.index + 1}"
    },
    local.common_tags
  )

  depends_on = [aws_internet_gateway.igw]
}

######################################
# NAT Gateways
######################################
resource "aws_nat_gateway" "nat_gateway" {
  count         = var.create_nat_gateway ? var.nat_gateway_count : 0
  subnet_id     = local.public_subnet_ids[count.index]
  allocation_id = aws_eip.nat[count.index].id

  tags = merge(
    {
      Name = "${local.base_name}-nat-${count.index + 1}"
    },
    local.common_tags
  )

  depends_on = [aws_internet_gateway.igw]
}

######################################
# Route Tables
######################################
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.public_rt_cidr_block
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(
    {
      Name = "${local.base_name}-public-rt"
    },
    local.common_tags
  )
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = var.private_rt_cidr_block
    nat_gateway_id = var.create_nat_gateway && length(aws_nat_gateway.nat_gateway) > 0 ? aws_nat_gateway.nat_gateway[0].id : null
  }

  tags = merge(
    {
      Name = "${local.base_name}-private-rt"
    },
    local.common_tags
  )
}

resource "aws_route_table_association" "public_rt_association" {
  for_each = { for idx in var.public_subnet_indexes : idx => aws_subnet.subnets[idx].id }

  subnet_id      = each.value
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rt_association" {
  for_each = {
    for idx, subnet in aws_subnet.subnets : idx => subnet.id
    if !contains(var.public_subnet_indexes, idx)
  }

  subnet_id      = each.value
  route_table_id = aws_route_table.private_rt.id
}

######################################
# NACLs
######################################
resource "aws_network_acl" "nacls" {
  for_each = var.create_nacl ? local.nacl_config : {}

  vpc_id     = aws_vpc.vpc.id
  subnet_ids = each.value.subnet_ids

  tags = merge(
    {
      Name = each.value.name
    },
    local.common_tags
  )

  dynamic "ingress" {
    for_each = each.value.ingress
    content {
      protocol   = ingress.value.protocol
      rule_no    = ingress.value.rule_no
      action     = ingress.value.action
      cidr_block = ingress.value.cidr_block
      from_port  = ingress.value.from_port
      to_port    = ingress.value.to_port
    }
  }

  dynamic "egress" {
    for_each = each.value.egress
    content {
      protocol   = egress.value.protocol
      rule_no    = egress.value.rule_no
      action     = egress.value.action
      cidr_block = egress.value.cidr_block
      from_port  = egress.value.from_port
      to_port    = egress.value.to_port
    }
  }
}

# #################### Security Groups ########################

resource "aws_security_group" "sg" {
  for_each = var.create_sg ? local.security_group_config : {}

  name   = each.value.name
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    {
      Name  = each.value.name
      env   = var.env
      owner = var.owner
    },
    local.common_tags
  )
}

# Ingress rules (cidr or source security-group)
resource "aws_security_group_rule" "ingress" {
  for_each = var.create_sg ? {
    for idx, rule in local.flattened_ingress_rules :
    idx => rule if rule.rule_type == "cidr" || rule.rule_type == "sg"
  } : {}

  type              = var.sg_ingress_type
  from_port         = each.value.rule.from_port
  to_port           = each.value.rule.to_port
  protocol          = each.value.rule.protocol
  description       = each.value.rule.description
  security_group_id = aws_security_group.sg[each.value.sg_name].id

  cidr_blocks              = each.value.rule_type == "cidr" ? try(each.value.rule.cidr_blocks, []) : []
  source_security_group_id = each.value.rule_type == "sg" ? aws_security_group.sg[each.value.rule.source_sg_names[0]].id : null
}

# Egress rules
resource "aws_security_group_rule" "egress" {
  for_each = var.create_sg ? {
    for idx, rule in local.flattened_egress_rules :
    idx => rule if rule.rule_type == "cidr" || rule.rule_type == "sg"
  } : {}

  type              = var.sg_egress_type
  from_port         = each.value.rule.from_port
  to_port           = each.value.rule.to_port
  protocol          = each.value.rule.protocol
  description       = each.value.rule.description
  security_group_id = aws_security_group.sg[each.value.sg_name].id

  cidr_blocks              = each.value.rule_type == "cidr" ? try(each.value.rule.cidr_blocks, []) : []
  source_security_group_id = each.value.rule_type == "sg" ? aws_security_group.sg[each.value.rule.source_sg_names[0]].id : null
}




# ##################333

###########################################
# KEY PAIR HANDLING (Bastion + Private)
###########################################
resource "tls_private_key" "ec2_key" {
  count     = var.create_key_pair && var.create_private_key ? 1 : 0
  algorithm = var.private_key_algorithm
  rsa_bits  = var.private_key_rsa_bits
}

resource "aws_key_pair" "key_pair" {
  count      = var.create_key_pair ? 1 : 0
  key_name   = var.key_pair_name
  public_key = var.create_private_key ? tls_private_key.ec2_key[0].public_key_openssh : file(var.public_key_path)

  tags = merge(
    {
      Name = "${local.base_name}-key"
    },
    local.common_tags
  )
}


resource "local_file" "private_key" {
  count           = var.create_key_pair && var.create_private_key ? 1 : 0
  content         = tls_private_key.ec2_key[0].private_key_pem
  filename        = "${var.key_output_dir}/${var.key_pair_name}.pem"
  file_permission = "0400"

  depends_on = [aws_key_pair.key_pair]
}



###########################################
# BASTION HOST (Public)
###########################################
resource "aws_instance" "bastion" {
  count = var.enable_bastion_instance ? 1 : 0

  ami                         = var.bastion_ami_id
  instance_type               = var.bastion_instance_type
  key_name                    = var.create_key_pair ? aws_key_pair.key_pair[0].key_name : var.bastion_key_name
  subnet_id                   = element(aws_subnet.subnets[*].id, var.bastion_subnet_index)
  vpc_security_group_ids      = [aws_security_group.sg[var.bastion_sg_name].id]  
  associate_public_ip_address = true

  monitoring                  = var.enable_monitoring
  disable_api_termination     = var.disable_api_termination
  ebs_optimized               = var.ebs_optimized
  user_data                   = var.user_data != "" ? var.user_data : null

  root_block_device {
    volume_size           = var.bastion_volume_size
    volume_type           = var.basition_volume_type
    delete_on_termination = var.root_block_delete_on_termination
  }

  tags = merge(
    {
      Name = "${local.base_name}-bastion"
    },
    local.common_tags
  )
}

resource "aws_eip" "bastion_eip" {
  count = var.allocate_elastic_ip ? 1 : 0
  instance = aws_instance.bastion[0].id
  domain   = "vpc"

  tags = {
    Name = "bastion-eip"
  }
}

# ###########################################
# # PRIVATE INSTANCES (Application)
# ###########################################
resource "aws_instance" "private_instances" {
  count = var.enable_private_instances ? var.private_instance_count : 0

  ami                    = var.private_instance_ami_id
  instance_type          = var.private_instance_type
  key_name               = var.create_key_pair ? aws_key_pair.key_pair[0].key_name : var.private_instance_key
  subnet_id              = element(aws_subnet.subnets[*].id, var.private_instance_subnet)
  vpc_security_group_ids = [aws_security_group.sg[var.private_instance_sg_name].id]   
  disable_api_termination = var.disable_api_termination
  monitoring              = var.enable_monitoring
  ebs_optimized           = var.ebs_optimized
  user_data               = var.user_data != "" ? var.user_data : null

  root_block_device {
    volume_size           = var.app_volume_size
    volume_type           = var.app_volume_type
    encrypted             = var.app_encrypted_volume
    delete_on_termination = var.root_block_delete_on_termination
  }

  tags = merge(
    {
      Name = "${local.base_name}-app-${count.index}"
    },
    local.common_tags
  )
}