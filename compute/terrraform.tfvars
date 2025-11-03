# --- EC2 Settings ---
enable_private_instances = true
private_instance_count   = 25
private_instance_ami_id  = "ami-0fcb2d702e65ba9c1"   
key_name                 = "rhel-key"

# --- Networking IDs ---
private_subnet_id  = "subnet-04c9eb12143a90294"
security_group_id  = "sg-0e85eca10903c323b"

# --- Instance Configuration ---
disable_api_termination           = false
enable_monitoring                 = true
ebs_optimized                     = true
user_data                         = ""
app_volume_size                   = 8
app_volume_type                   = "gp3"
app_encrypted_volume              = true
root_block_delete_on_termination  = true

# --- Tags ---
purpose = "training"
program = "Rebit"
owner   = "rebit"
