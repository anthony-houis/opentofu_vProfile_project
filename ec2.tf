resource "tls_private_key" "vprofile_test_private_key" {
  algorithm   = "ED25519"
}

resource "aws_key_pair" "opentofu_generated_key" {
  key_name   = var.keyname
  public_key = tls_private_key.formation_private_key.public_key_openssh
}

resource "local_file" "vprofile_test_opentofu_key" {
  content  = tls_private_key.vprofile_test_private_key.private_key_openssh
  filename = "${var.keyname}"
}

resource "aws_ebs_volume" "mariadb_volume" {
  availability_zone = data.aws_availability_zones.available.names[0]
  size              = 10
  tags = {
    "Name"    = "mariadb-volume"
    "Project" = "vProfile-opentofu"
  }
}

resource "aws_instance" "mariadb_instance" {
  ami               = data.aws_ami.ubuntu.id
  instance_type     = var.instance_types["micro"]
  key_name          = aws_key_pair.opentofu_generated_key.key_name
  availability_zone = data.aws_availability_zones.available.names[0]
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_id   = aws_ebs_volume.mariadb_volume.id
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.formation_private_key.private_key_pem
    host        = self.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y mariadb-server",
      "sudo mysql_secure_installation",
    ]
  }
  tags = {
    "Name"    = "mariadb-instance"
    "Project" = "vProfile-opentofu"
  }
}

resource "aws_network_interface_sg_attachment" "mariadb_sg_attachment" {
  security_group_id    = aws_security_group.vprofile-backend-sg.id
  network_interface_id = aws_instance.mariadb_instance.primary_network_interface_id
}

resource "aws_ebs_volume" "rabbitmq_volume" {
  availability_zone = data.aws_availability_zones.available.names[0]
  size              = 10
  tags = {
    "Name"    = "rabbitmq-volume"
    "Project" = "vProfile-opentofu"
  }
}

resource "aws_instance" "rabbitmq_instance" {
  ami               = data.aws_ami.ubuntu.id
  instance_type     = var.instance_types["micro"]
  key_name          = aws_key_pair.opentofu_generated_key.key_name
  availability_zone = data.aws_availability_zones.available.names[0]
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_id   = aws_ebs_volume.rabbitmq_volume.id
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.formation_private_key.private_key_pem
    host        = self.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y rabbitmq-server",
    ]
  }
  tags = {
    "Name"    = "rabbitmq-instance"
    "Project" = "vProfile-opentofu"
  }
}

resource "aws_network_interface_sg_attachment" "rabbitmq_sg_attachment" {
  security_group_id    = aws_security_group.vprofile-backend-sg.id
  network_interface_id = aws_instance.rabbitmq_instance.primary_network_interface_id
}

resource "aws_ebs_volume" "memcached_volume" {
  availability_zone = data.aws_availability_zones.available.names[0]
  size              = 10
  tags = {
    "Name"    = "memcached-volume"
    "Project" = "vProfile-opentofu"
  }
}

resource "aws_instance" "memcached_instance" {
  ami               = data.aws_ami.ubuntu.id
  instance_type     = var.instance_types["micro"]
  key_name          = aws_key_pair.opentofu_generated_key.key_name
  availability_zone = data.aws_availability_zones.available.names[0]
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_id   = aws_ebs_volume.memcached_volume.id
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.formation_private_key.private_key_pem
    host        = self.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt install -y memcached",
      "sudo systemctl start memcached",
      "sudo systemctl enable memcached",
      "sudo systemctl status memcached",
      "sed -i 's/127.0.0.1/0.0.0.0/g' /etc/sysconfig/memcached",
      "sudo systemctl restart memcached",
      "sudo memcached -p 11211 -U 11211 -u memcache -m 64 -c 1024 -l"
    ]
  }
  tags = {
    "Name"    = "memcached-instance"
    "Project" = "vProfile-opentofu"
  }
}

resource "aws_network_interface_sg_attachment" "memcached_sg_attachment" {
  security_group_id    = aws_security_group.vprofile-backend-sg.id
  network_interface_id = aws_instance.memcached_instance.primary_network_interface_id
}

resource "aws_instance" "app_instance" {
  ami                  = data.aws_ami.ubuntu.id
  instance_type        = var.instance_types["micro"]
  key_name             = aws_key_pair.opentofu_generated_key.key_name
  availability_zone    = data.aws_availability_zones.available.names[1]
  iam_instance_profile = aws_iam_instance_profile.tomcat_s3_instance_profile.name
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.formation_private_key.private_key_pem
    host        = self.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y openjdk-17-jdk",
      "sudo apt-get install -y tomcat10 tomcat10-admin tomcat10-docs tomcat10-common git python3 python3-pip unzip",
      "curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o 'awscliv2.zip'",
      "unzip awscliv2.zip",
      "sudo ./aws/install",
      "aws --version",
    ]
  }
  tags = {
    "Name"    = "app-instance"
    "Project" = "vProfile-opentofu"
  }
}

resource "aws_network_interface_sg_attachment" "app_sg_attachment" {
  security_group_id    = aws_security_group.vprofile-app-sg.id
  network_interface_id = aws_instance.app_instance.primary_network_interface_id
}

resource "aws_iam_instance_profile" "tomcat_s3_instance_profile" {
  name = var.role_name
  role = aws_iam_role.tomcat_s3_role.name
}