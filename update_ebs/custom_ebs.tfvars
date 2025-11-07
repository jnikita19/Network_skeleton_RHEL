aws_region     = "us-east-2"
enable_common  = false
enable_custom  = true

instances_ebs = [
  {
    instance_id = "i-01f79575f434dc394"
    volumes = [
      {
        device_name          = "/dev/sdf"
        volume_size          = 15
        mount_point          = "/data1"
        encrypted            = true
        type                 = "gp3"
        iops                 = 3000
        throughput           = 125
        multi_attach_enabled = false
        tags = { Purpose = "Logs" }
      },
      {
        device_name          = "/dev/sdg"
        volume_size          = 12
        mount_point          = "/data2"
        encrypted            = true
        type                 = "gp3"
        iops                 = 3000
        throughput           = 125
        multi_attach_enabled = false
        tags = { Purpose = "Backup" }
      }
    ]
  },
  {
    instance_id = "i-0a53d8380876fd09b"
    volumes = [
      {
        device_name          = "/dev/sdf"
        volume_size          = 12
        mount_point          = "/db"
        encrypted            = true
        type                 = "gp3"
        iops                 = 4000
        throughput           = 200
        multi_attach_enabled = false
        tags = { Purpose = "Database" }
      }
    ]
  }
]
