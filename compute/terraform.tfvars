# --- EC2 Settings ---
enable_private_instances = true
private_instance_count   = 1
private_instance_ami_id  = "ami-0e57fa2ecfa799574"
key_name                 = "rhel-training-key"

# --- Networking IDs ---
private_subnet_id = "subnet-0f006b33ff05789d9"
security_group_id = "sg-0dcc20508afaea6a5"

# --- Instance Configuration ---
disable_api_termination          = false
enable_monitoring                = true
ebs_optimized                    = true
user_data                        = ""
app_volume_size                  = 20
app_volume_type                  = "gp3"
app_encrypted_volume             = true
root_block_delete_on_termination = true

# --- Tags ---
purpose = "training"
program = "Rebit"
owner   = "rebit"
