
aws_region = "us-east-2"

###########################################
# VPC Configuration
###########################################
vpc_cidr             = "10.0.0.0/16"
instance_tenancy     = "default"
enable_dns_support   = true
enable_dns_hostnames = true

###########################################
# Subnet Configuration
###########################################
subnet_names = [
  "public-subnet-1",
  "private-subnet-1"
]

subnet_cidrs = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

subnet_azs = [
  "us-east-2a",
  "us-east-2b"
]

###########################################
# Route Table Configuration
###########################################

public_rt_cidr_block  = "0.0.0.0/0"
private_rt_cidr_block = "0.0.0.0/0"

public_subnet_indexes = [0] # index for public subnet

###########################################
# Internet Gateway & NAT Gateway
###########################################
create_nat_gateway = true
nat_gateway_count  = 1

###########################################
# NACL Configuration
###########################################
create_nacl = false

nacl_names = ["public-nacl", "private-nacl"]

nacl_rules = {
  public-nacl = {
    subnet_index = [0]
    ingress_rules = [
      { protocol = "tcp", rule_no = 100, action = "allow", cidr_block = "0.0.0.0/0", from_port = 22, to_port = 22 },   # SSH
      { protocol = "tcp", rule_no = 110, action = "allow", cidr_block = "0.0.0.0/0", from_port = 80, to_port = 80 },   # HTTP
      { protocol = "tcp", rule_no = 120, action = "allow", cidr_block = "0.0.0.0/0", from_port = 443, to_port = 443 }, # HTTPS
      { protocol = "-1", rule_no = 130, action = "allow", cidr_block = "0.0.0.0/0", from_port = 0, to_port = 0 }       # All
    ]
    egress_rules = [
      { protocol = "-1", rule_no = 100, action = "allow", cidr_block = "0.0.0.0/0", from_port = 0, to_port = 0 } # All outbound
    ]
  }

  private-nacl = {
    subnet_index = [1]
    ingress_rules = [
      { protocol = "tcp", rule_no = 100, action = "allow", cidr_block = "10.0.1.0/24", from_port = 22, to_port = 22 },     # SSH from public subnet
      { protocol = "tcp", rule_no = 110, action = "allow", cidr_block = "10.0.1.0/24", from_port = 1024, to_port = 65535 } # Ephemeral
    ]
    egress_rules = [
      { protocol = "-1", rule_no = 100, action = "allow", cidr_block = "0.0.0.0/0", from_port = 0, to_port = 0 } # All outbound
    ]
  }
}

###########################################
# Security Group Configuration
###########################################
create_sg = true
sg_names  = ["bastion-sg", "rhel-private-instances-sg"]

security_groups_rule = {
  bastion-sg = {
    name = "bastion-sg"
    ingress_rules = [
      { from_port = 22, to_port = 22, protocol = "tcp", description = "SSH Access", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 80, to_port = 80, protocol = "tcp", description = "HTTP Access", cidr_blocks = ["0.0.0.0/0"] },
      { from_port = 443, to_port = 443, protocol = "tcp", description = "HTTPS Access", cidr_blocks = ["0.0.0.0/0"] }
    ]
    egress_rules = [
      { from_port = 0, to_port = 0, protocol = "-1", description = "Allow all outbound", cidr_blocks = ["0.0.0.0/0"] }
    ]
  }

  rhel-private-instances-sg = {
    name = "rhel-private-instances-sg"
    ingress_rules = [
      { from_port = 22, to_port = 22, protocol = "tcp", description = "Allow SSH from Bastion", source_sg_names = ["bastion-sg"] },
      { from_port = 80, to_port = 80, protocol = "tcp", description = "App Port from Bastion", source_sg_names = ["bastion-sg"] }
    ]
    egress_rules = [
      { from_port = 0, to_port = 0, protocol = "-1", description = "Allow all outbound", cidr_blocks = ["0.0.0.0/0"] }
    ]
  }
}

###########################################
# Environment Tags
###########################################
purpose = "training"
owner   = "rebit"
program = "Rebit"

###########################################
# Key Pair Configuration
###########################################
create_key_pair       = true
create_private_key    = true
private_key_algorithm = "RSA"
private_key_rsa_bits  = 2048
key_pair_name         = "rhel-key"
key_output_dir        = "./keys"
public_key_path       = "~/.ssh/id_rsa.pub"

###########################################
# Bastion Instance Configuration
###########################################
enable_bastion_instance = true
bastion_ami_id          = "ami-0d9a665f802ae6227"
bastion_instance_type   = "t2.micro"
bastion_subnet_index    = 0
bastion_sg_name         = "bastion-sg"
bastion_key_name        = "rhel-key"
allocate_elastic_ip     = true

###########################################
# Private Instances Configuration
###########################################
enable_private_instances = true
private_instance_count   = 25
private_instance_ami_id  = "ami-0fcb2d702e65ba9c1"
private_instance_type    = "t2.micro"
private_instance_subnet  = 1
private_instance_sg_name = "rhel-private-instances-sg"
private_instance_key     = "rhel-key"

###########################################
# Instance Storage & Options
###########################################
enable_monitoring                = false
disable_api_termination          = false
ebs_optimized                    = false
root_block_delete_on_termination = true
user_data                        = ""
bastion_volume_size              = 8
basition_volume_type             = "gp3"
app_volume_size                  = 10
app_volume_type                  = "gp3"
app_encrypted_volume             = true
