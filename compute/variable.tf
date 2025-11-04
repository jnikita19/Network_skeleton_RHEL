variable "enable_private_instances" {
  type        = bool
  default     = true
  description = "Enable private instances"
}

variable "private_instance_count" {
  type        = number
  default     = 1
  description = "Number of private instances"
}

variable "private_instance_ami_id" {
  type        = string
  description = "AMI ID for private instances"
  default     = "ami-0fcb2d702e65ba9c1"
}

variable "private_instance_type" {
  type        = string
  default     = "t2.micro"
  description = "Instance type for private instances"
}

variable "key_name" {
  type        = string
  description = "Key pair name for EC2"
  default     = "rhel-key"
}

variable "private_subnet_id" {
  type        = string
  description = "Private subnet ID for EC2"
  default     = "subnet-024e053dd989617a7"
}

variable "security_group_id" {
  type        = string
  description = "Security group ID for EC2"
  default     = "sg-068edf11948b84de3"
}

variable "disable_api_termination" {
  type    = bool
  default = false
}

variable "enable_monitoring" {
  type    = bool
  default = false
}

variable "ebs_optimized" {
  type    = bool
  default = false
}

variable "user_data" {
  type    = string
  default = ""
}

variable "app_volume_size" {
  type    = number
  default = 10
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

variable "purpose" {
  type        = string
  description = "Purpose tag value"
  default     = "training"
}

variable "program" {
  type        = string
  description = "Program tag value"
  default     = "Rebit"
}

variable "owner" {
  type        = string
  description = "Owner tag value"
  default     = "rebit"
}
