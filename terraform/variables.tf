
variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "purpose" {
  type    = string
  default = "training"
}

variable "program" {
  type    = string
  default = "Rebbit"
}

variable "owner" {
  type    = string
  default = "rebit"
}

###################### VPC Configuration ####################
variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "enable_dns_support" {
  type        = bool
  description = "Enable DNS support in VPC"
  default     = true
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Enable DNS hostnames in VPC"
  default     = true
}

variable "instance_tenancy" {
  type        = string
  description = "Tenancy option: default or dedicated"
  default     = "default"
}

###################### Subnet Configuration ####################
variable "subnet_names" {
  type        = list(string)
  description = "List of subnet names"
  default     = ["public-1", "private-1", "public-2", "private-2"]
}

variable "subnet_cidrs" {
  type        = list(string)
  description = "List of CIDR blocks for subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24", "10.0.4.0/24"]
}

variable "subnet_azs" {
  type        = list(string)
  description = "List of Availability Zones for subnets"
  default     = ["us-east-2a", "us-east-2a", "us-east-2b", "us-east-2b"]
}

variable "public_subnet_indexes" {
  type        = list(number)
  description = "Indexes of public subnets in subnet list"
  default     = [0, 2]
}

######################## Route Tables ########################
variable "public_rt_cidr_block" {
  type    = string
  default = "0.0.0.0/0"
}

variable "private_rt_cidr_block" {
  type    = string
  default = "0.0.0.0/0"
}

########################## NAT ######################################
variable "create_nat_gateway" {
  type    = bool
  default = true
}

variable "nat_gateway_count" {
  description = <<EOT
Number of NAT Gateways to create:
- Set to 1 for a single NAT Gateway (cost-saving)
- Set to length of public_subnet_ids for HA (one per AZ)
EOT
  type        = number
  default     = 1
}

########################## NACL ###########################
variable "create_nacl" {
  type    = bool
  default = true
}

variable "nacl_names" {
  type    = list(string)
  default = ["public", "private"]
}

variable "nacl_rules" {
  type        = any
  description = "Map of NACL rules (ingress/egress). See README for structure."
  default     = {}
}

#################### Security Groups ########################
variable "sg_names" {
  type    = list(string)
  default = ["bastion-sg", "app-sg"]
}


variable "security_groups_rule" {
  description = "Map of security group rules"
  type = map(object({
    name = string
    ingress_rules = list(object({
      from_port       = number
      to_port         = number
      protocol        = string
      description     = string
      cidr_blocks     = optional(list(string), [])
      source_sg_names = optional(list(string), [])
    }))
    egress_rules = list(object({
      from_port   = number
      to_port     = number
      protocol    = string
      description = string
      cidr_blocks = list(string)
      # optional source_sg_names not used for egress in this example
    }))
  }))
  default = {}
}

variable "sg_egress_type" {
  type    = string
  default = "egress"
}

variable "sg_ingress_type" {
  type    = string
  default = "ingress"
}

variable "create_sg" {
  type    = bool
  default = true
}



########################
# Key Pair & SSH Configuration
########################
variable "create_key_pair" {
  description = "Create new AWS key pair"
  type        = bool
  default     = true
}

variable "create_private_key" {
  description = "Whether to generate a private key locally"
  type        = bool
  default     = true
}

variable "private_key_algorithm" {
  description = "Private key algorithm"
  type        = string
  default     = "RSA"
}

variable "private_key_rsa_bits" {
  description = "RSA key length in bits"
  type        = number
  default     = 4096
}

variable "key_pair_name" {
  description = "AWS key pair name"
  type        = string
  default     = "otms-key"
}

variable "key_output_dir" {
  description = "Directory to save generated private key"
  type        = string
  default     = "./keys"
}

variable "public_key_path" {
  description = "Path to existing public key (if not creating new one)"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}


########################
# Bastion Instance Config
########################
variable "enable_bastion_instance" {
  description = "Enable Bastion host instance"
  type        = bool
  default     = true
}

variable "bastion_ami_id" {
  description = "AMI ID for Bastion instance"
  type        = string
}

variable "bastion_instance_type" {
  description = "Instance type for Bastion"
  type        = string
  default     = "t2.micro"
}

variable "bastion_subnet_index" {
  description = "Subnet index for Bastion instance"
  type        = number
  default     = 0
}

variable "bastion_key_name" {
  description = "Existing key pair name for Bastion (used if create_key_pair=false)"
  type        = string
  default     = ""
}

variable "allocate_elastic_ip" {
  description = "Whether to allocate Elastic IP for Bastion"
  type        = bool
  default     = true
}

variable "bastion_sg_name" {
  description = "Security group name for Bastion"
  type        = string
  default     = "bastion-sg"
}

########################
# Private Instance Config
########################
variable "enable_private_instances" {
  description = "Enable creation of private instances"
  type        = bool
  default     = true
}

variable "private_instance_count" {
  description = "Number of private instances to create"
  type        = number
  default     = 5
}

variable "private_instance_ami_id" {
  description = "AMI ID for private instances (e.g., RHEL 9.x)"
  type        = string
}

variable "private_instance_type" {
  description = "Instance type for private instances"
  type        = string
  default     = "t3.micro"
}

variable "private_instance_key" {
  description = "Existing key pair for private instances (used if create_key_pair=false)"
  type        = string
  default     = ""
}

variable "private_instance_subnet" {
  description = "Subnet index where private instances will be launched"
  type        = number
  default     = 1
}

variable "private_instance_sg_name" {
  description = "Security group name for private instances"
  type        = string
  default     = "app-sg"
}

########################
# EC2 Settings
########################
variable "enable_monitoring" {
  type    = bool
  default = false
}

variable "disable_api_termination" {
  type    = bool
  default = false
}

variable "ebs_optimized" {
  type    = bool
  default = false
}

variable "bastion_volume_size" {
  type    = number
  default = 20
}

variable "basition_volume_type" {
  type    = string
  default = "gp3"
}


variable "app_volume_size" {
  type    = number
  default = 20
}

variable "app_volume_type" {
  type    = string
  default = "gp3"
}
variable "app_encrypted_volume" {
  type    = bool
  default = true
}


variable "root_block_delete_on_termination" {
  type    = bool
  default = true
}

variable "user_data" {
  type    = string
  default = ""
}