
##########################################
# OUTPUTS
##########################################
output "attached_volumes" {
  value = [
    for idx, vol in aws_ebs_volume.multi : {
      volume_id   = vol.id
      instance_id = local.flattened_ebs[idx].instance_id
      device_name = local.flattened_ebs[idx].device_name
    }
  ]
}
