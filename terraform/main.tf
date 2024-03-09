provider "aws" {
  region = "ap-northeast-1"
}
resource "aws_lightsail_instance" "instance" {
  name              = "vpn"
  availability_zone = "ap-northeast-1a"
  blueprint_id      = "ubuntu_22_04"
  bundle_id         = "nano_3_0"

  # If the instance already exists, stop it
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lightsail_instance_public_ports" "instance_ports" {
  instance_name = aws_lightsail_instance.instance.name

  dynamic "port_info" {
    for_each = var.tcp_ports == null ? [] : var.tcp_ports

    content {
      protocol  = "tcp"
      from_port = port_info.value
      to_port   = port_info.value
    }
  }
}

