

###############################################
# LOCALS
###############################################
locals {
  common_tags = {
    purpose = "training"
    owner   = "rebit"
  }

  ###################################################
  # Determine which configuration to use
  ###################################################
  active_instances_ebs = (
    var.enable_custom ? var.instances_ebs :
    var.enable_common ? [
      for id in var.common_instances : {
        instance_id = id
        volumes = [
          for vol in var.common_volume_templates : merge(
            vol,
            { tags = merge(local.common_tags, vol.tags, { Instance = id }) }
          )
        ]
      }
    ] : []
  )

  ###################################################
  # Flatten for easy looping
  ###################################################
  flattened_ebs = flatten([
    for instance in local.active_instances_ebs : [
      for vol in instance.volumes : {
        instance_id          = instance.instance_id
        device_name          = vol.device_name
        volume_size          = vol.volume_size
        mount_point          = vol.mount_point
        encrypted            = vol.encrypted
        type                 = vol.type
        iops                 = lookup(vol, "iops", null)
        throughput           = lookup(vol, "throughput", null)
        multi_attach_enabled = lookup(vol, "multi_attach_enabled", false)
        tags                 = merge(local.common_tags, vol.tags)
      }
    ]
  ])
}



###############################################
# GET INSTANCE INFO FOR AZ
###############################################
data "aws_instance" "selected" {
  for_each = {
    for inst in local.active_instances_ebs : inst.instance_id => inst
  }
  instance_id = each.value.instance_id
}

###############################################
# CREATE EBS VOLUMES
###############################################
resource "aws_ebs_volume" "multi" {
  count                = length(local.flattened_ebs)
  availability_zone    = data.aws_instance.selected[local.flattened_ebs[count.index].instance_id].availability_zone
  size                 = local.flattened_ebs[count.index].volume_size
  encrypted            = local.flattened_ebs[count.index].encrypted
  iops                 = local.flattened_ebs[count.index].iops
  throughput           = local.flattened_ebs[count.index].throughput
  type                 = local.flattened_ebs[count.index].type
  multi_attach_enabled = local.flattened_ebs[count.index].multi_attach_enabled

  tags = merge(
    local.flattened_ebs[count.index].tags,
    { Name = "EBS-${count.index + 1}" }
  )
}

###############################################
# ATTACH EBS VOLUMES
###############################################
resource "aws_volume_attachment" "multi" {
  count       = length(local.flattened_ebs)
  device_name = local.flattened_ebs[count.index].device_name
  volume_id   = aws_ebs_volume.multi[count.index].id
  instance_id = local.flattened_ebs[count.index].instance_id
}

