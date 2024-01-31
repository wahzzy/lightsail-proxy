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

resource "local_file" "ansible_inventory" {

    content     = <<-EOL
    [host]
    ${aws_lightsail_instance.instance.public_ip_address}
    [host:vars]
    ansible_user=${var.instance_user}
    ansible_ssh_private_key_file=${var.ssh_private_key_file}
    EOL
    filename = "${path.module}/../ansible/inventory"
}
resource "local_file" "python_config" {

    content     = <<-EOL
    domain: ${var.domain}
    cloudflare_token: ${var.cloudflare_token}
    instance_ip: ${aws_lightsail_instance.instance.public_ip_address}
    zone_id: ${var.zone_id}
    dns_record_id: ${var.dns_record_id}
    EOL
    filename = "${path.module}/../python/configs.yml"
}
resource "null_resource" "run_commands" {
  depends_on = ["local_file.python_config"]

  provisioner "local-exec" {
    command = <<EOT
      python3 ../python/update_dns_record.py
      ansible-playbook ../ansible/setup.yml -i ${path.module}/../ansible/inventory --extra-vars 'DOMAIN=${var.domain} USER=${var.vpn_user} PASS=${var.vpn_password} EMAIL=${var.vpn_email}'
    EOT
  }
}
