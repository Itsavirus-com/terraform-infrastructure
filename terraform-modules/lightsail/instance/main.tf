resource "aws_lightsail_key_pair" "my_key" {
  name       = "${var.PROJECT}-user"
  public_key = file(pathexpand("../../../key-pairs/publickey"))

}

# Create a new Lightsail instance
resource "aws_lightsail_instance" "instance" {
  name              = "${var.PROJECT}-instance"
  availability_zone = var.AVAILABILITY_ZONE  # Replace with your desired availability zone
  blueprint_id      = var.BLUEPRINT_ID  # Replace with your desired blueprint ID
  bundle_id         = var.BUNDLE_ID  # Replace with your desired bundle ID
  key_pair_name     = aws_lightsail_key_pair.my_key.name  # Replace with your desired key pair name

}


# Allocate a static IP for the instance
resource "aws_lightsail_static_ip" "instance_eip" {
  name = "${var.PROJECT}-static-ip"
}

# Attach the static IP to the instance
resource "aws_lightsail_static_ip_attachment" "instance_eip_attachment" {
  static_ip_name    = aws_lightsail_static_ip.instance_eip.name
  instance_name     = aws_lightsail_instance.instance.name
}

resource "aws_lightsail_instance_public_ports" "vps" {
  instance_name = aws_lightsail_instance.instance.name

  port_info {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
  }
  port_info {
    protocol  = "tcp"
    from_port = 25
    to_port   = 25
  }
  port_info {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
  }
  port_info {
    protocol  = "tcp"
    from_port = 443
    to_port   = 443
  } 
  port_info {
    protocol      = "tcp"
    from_port     = 3000
    to_port       = 3000
  }
  port_info {
    protocol      = "tcp"
    from_port     = 996
    to_port       = 996
  }
  port_info {
    protocol      = "udp"
    from_port     = 7946
    to_port       = 7946
  }
  port_info {
    protocol      = "udp"
    from_port     = 4789
    to_port       = 4789
  }
    port_info {
    protocol      = "udp"
    from_port     = 2377
    to_port       = 2377
  }
   port_info {
    protocol      = "tcp"
    from_port     = 5432
    to_port       = 5432
    cidrs         = var.ALLOWED_IP
  }

}

# # Create a new Lightsail block storage disk
# resource "aws_lightsail_disk" "ebs_volume" {
#   name              = "${var.PROJECT}-disk"
#   availability_zone = var.AVAILABILITY_ZONE  
#   size_in_gb        = var.EBS_VOLUME_SIZE  
# }

# # Attach the block storage disk to the instance
# resource "aws_lightsail_disk_attachment" "ebs_volume_attachment" {
#   disk_name     = aws_lightsail_disk.ebs_volume.name
#   instance_name = aws_lightsail_instance.instance.name
#   disk_path     = "/dev/sda2" # Change this to the desired disk path on the instance
# }

