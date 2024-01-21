output "instance_ip" {
  value       = aws_lightsail_instance.instance[*].public_ip_address
  description = "The Public IP Address name of the Lightsail instance."
}