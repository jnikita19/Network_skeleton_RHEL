


locals {
  base_name = "${var.env}-${var.program}"

  common_tags = {
    env   = var.env
    owner = var.owner
  }

  ################ Subnets ################
  subnets = [
    for i in range(length(var.subnet_names)) : {
      name       = "${var.env}-${var.program}-${var.subnet_names[i]}"
      cidr       = var.subnet_cidrs[i]
      avail_zone = var.subnet_azs[i]
    }
  ]

  public_subnet_indexes = [
    for idx, name in var.subnet_names :
    idx if can(regex("(?i)public", name))
  ]

  private_subnet_indexes = [
    for idx, name in var.subnet_names :
    idx if !can(regex("(?i)public", name))
  ]

  public_subnet_ids = [
    for i in local.public_subnet_indexes :
    aws_subnet.subnets[i].id
  ]

  private_subnet_ids = [
    for i in local.private_subnet_indexes :
    aws_subnet.subnets[i].id
  ]

  application_subnet_ids = [
    for i, subnet in aws_subnet.subnets :
    subnet.id if can(regex("(?i)application", var.subnet_names[i]))
  ]

  database_subnet_ids = [
    for i, subnet in aws_subnet.subnets :
    subnet.id if can(regex("(?i)database", var.subnet_names[i]))
  ]

  ################ NACLs ################
  nacls = {
    for i in range(length(var.nacl_names)) :
    var.nacl_names[i] => "${var.env}-${var.nacl_names[i]}-nacl"
  }

  nacl_config = {
    for nacl_key, nacl_value in var.nacl_rules :
    nacl_key => {
      name       = local.nacls[nacl_key]
      subnet_ids = [for index in nacl_value.subnet_index : aws_subnet.subnets[index].id]
      ingress    = nacl_value.ingress_rules
      egress     = nacl_value.egress_rules
    }
  }

  ################ Security Groups ################
  security_groups = {
    for i in range(length(var.sg_names)) :
    var.sg_names[i] => "${var.env}-${var.project_name}-${var.sg_names[i]}-sg"
  }

  security_group_config = {
    for sg_key, sg_value in var.security_groups_rule :
    sg_key => {
      name    = local.security_groups[sg_key]
      ingress = sg_value.ingress_rules
      egress  = sg_value.egress_rules
    }
  }

  flattened_ingress_rules = flatten([
    for sg_key, sg_value in local.security_group_config : [
      for rule in sg_value.ingress : [
        length(try(rule.source_sg_names, [])) > 0 ? {
          sg_name   = sg_key
          rule_type = "sg"
          rule      = rule
        } : {
          sg_name   = sg_key
          rule_type = "cidr"
          rule      = rule
        }
      ]
    ]
  ])

  flattened_egress_rules = flatten([
    for sg_key, sg_value in local.security_group_config : [
      for rule in sg_value.egress : [
        length(try(rule.source_sg_names, [])) > 0 ? {
          sg_name   = sg_key
          rule_type = "sg"
          rule      = rule
        } : {
          sg_name   = sg_key
          rule_type = "cidr"
          rule      = rule
        }
      ]
    ]
  ])
}
