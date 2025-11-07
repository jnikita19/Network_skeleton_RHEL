aws_region     = "us-east-2"
enable_common  = true
enable_custom  = false

common_instances = [
  "i-03fc6823700268685",
  "i-09c86eecb66098656"
]

common_volume_templates = [
  {
    device_name          = "/dev/sdf"
    mount_point          = "/data"
    volume_size          = 20
    encrypted            = true
    type                 = "gp3"
    iops                 = 3000
    throughput           = 125
    multi_attach_enabled = false
    tags = { Purpose = "CommonData" }
  }
]
