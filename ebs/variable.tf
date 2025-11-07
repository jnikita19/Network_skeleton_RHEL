variable "instances_ebs" {
  description = "List of instances with their EBS configurations"
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
}


variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
  
}