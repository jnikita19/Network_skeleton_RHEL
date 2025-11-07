variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

###################################################
# Feature flags to toggle between modes
###################################################
variable "enable_common" {
  description = "Enable the common EBS configuration mode"
  type        = bool
  default     = false
}

variable "enable_custom" {
  description = "Enable the custom EBS configuration mode"
  type        = bool
  default     = false
}

###################################################
# Common configuration
###################################################
variable "common_instances" {
  description = "List of EC2 instance IDs that share the same volume configuration"
  type        = list(string)
  default     = []
}

variable "common_volume_templates" {
  description = "Common EBS volume configuration to apply to all common instances"
  type = list(object({
    device_name          = string
    mount_point          = string
    volume_size          = number
    encrypted            = bool
    type                 = string
    iops                 = optional(number)
    throughput           = optional(number)
    multi_attach_enabled = optional(bool)
    tags                 = map(string)
  }))
  default = []
}

###################################################
# Custom configuration
###################################################
variable "instances_ebs" {
  description = "List of instances with their individual EBS volume configurations"
  type = list(object({
    instance_id = string
    volumes = list(object({
      device_name          = string
      volume_size          = number
      mount_point          = string
      encrypted            = bool
      type                 = string
      iops                 = optional(number)
      throughput           = optional(number)
      multi_attach_enabled = optional(bool)
      tags                 = map(string)
    }))
  }))
  default = []
}
