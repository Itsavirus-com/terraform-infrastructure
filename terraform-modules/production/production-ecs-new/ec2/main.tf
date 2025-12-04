# Keypair using local ssh public key
resource "aws_key_pair" "my_key" {
 key_name = "${var.PROJECT}-user"
 public_key = file(pathexpand("../../../key-pairs/publickey"))
}

# Elastic IP for instance
resource "aws_eip" "instance_eip" {
  vpc = true
}

resource "aws_eip_association" "my_eip_assoc" {
  instance_id   = aws_instance.instance.id
  allocation_id = aws_eip.instance_eip.id
}

#AWS Instance
resource "aws_instance" "instance" {

    ami = var.AMI
    instance_type = var.INSTANCE_TYPE
    key_name = aws_key_pair.my_key.key_name
    subnet_id = var.public_subnet_id
    vpc_security_group_ids = [var.sg_id]
    associate_public_ip_address = true

    root_block_device {
        volume_type = "gp2"
        volume_size = "20"
        delete_on_termination = true
    }

    tags = {
        Name = "${var.PROJECT}-instance"
    }

    volume_tags = {
        Name = "${var.PROJECT}-root"
    }
}

# Create new EBS volume
resource "aws_ebs_volume" "ebs_volume" {
    size = var.EBS_VOLUME_SIZE
    availability_zone = aws_instance.instance.availability_zone

    tags = {
        Name = "${var.PROJECT}-ebs-data"
    }
}

# Attach EBS volume to instance
resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sda2"
  volume_id = aws_ebs_volume.ebs_volume.id
  instance_id = aws_instance.instance.id
}

resource "aws_ami_from_instance" "instance_ami" {
  name = "${var.PROJECT}-AMI"
  source_instance_id = aws_instance.instance.id
}
