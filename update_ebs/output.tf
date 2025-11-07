
output "attached_volumes" {
  value = {
    for idx, vol in aws_ebs_volume.multi :
    idx => {
      instance_id = local.flattened_ebs[idx].instance_id
      volume_id   = vol.id
      device_name = local.flattened_ebs[idx].device_name
      mount_point = local.flattened_ebs[idx].mount_point
    }
  }
}
