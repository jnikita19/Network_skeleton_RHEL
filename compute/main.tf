resource "aws_instance" "private_instances" {
  count = var.enable_private_instances ? var.private_instance_count : 0

  ami                     = var.private_instance_ami_id
  instance_type           = var.private_instance_type
  key_name                = var.key_name
  subnet_id               = var.private_subnet_id
  vpc_security_group_ids  = [var.security_group_id]
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

  tags = {
    Name    = "${var.program}-${var.purpose}-instance-${count.index}"
    purpose = var.purpose
    Owner   = var.owner
  }
  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      tags,          # Ignore tag updates from outside Terraform
      instance_type, # Ignore manual instance type change
    ]
  }
}
