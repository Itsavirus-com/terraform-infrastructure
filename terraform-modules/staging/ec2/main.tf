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

resource "null_resource" "remote_exec" {
  depends_on = [aws_instance.instance]
  provisioner "remote-exec" {
    inline = [
      # Create an SSH Key
      "ssh-keygen -t rsa -f /home/ubuntu/.ssh/id_rsa -q -P ''",

      # Mount the attached volume to /mnt/ebs1
      "sudo mkfs -t ext4 /dev/nvme1n1",
      "sudo mkdir /mnt/ebs1",
      "sudo mount /dev/nvme1n1 /mnt/ebs1",
      "sudo echo '/dev/nvme1n1  /mnt/ebs1   ext4    defaults,nofail   0   2' | sudo tee -a /etc/fstab",

      # Preparing for docker engine
      "sudo apt install -y apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository 'deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable'",
      "sudo apt update",
      "sudo apt install -y docker-ce",
      "sudo chmod 666 /var/run/docker.sock",
      
      # Move docker engine to ebs1
      "sudo service docker stop",
      "sudo mv /var/lib/docker /mnt/ebs1/docker",
      "echo '{\"data-root\": \"/mnt/ebs1/docker\"}' | sudo tee /etc/docker/daemon.json",
      "sudo service docker start",
      
      # Caprover installation
      "docker run -p 80:80 -p 443:443 -p 3000:3000 -v /var/run/docker.sock:/var/run/docker.sock -v /captain:/captain caprover/caprover",
      
      # Set cronjob for cleaning docker image and container
      # "echo '0 0 * * MON docker container prune --force' | crontab -",
      # "echo '0 0 * * MON docker image prune --all' | crontab -"
    ]
  }


  connection {
    host = aws_instance.instance.public_ip
    type = "ssh"
    user = "ubuntu"
    private_key = file(pathexpand("./../../../key-pairs/privkey"))
  }
}