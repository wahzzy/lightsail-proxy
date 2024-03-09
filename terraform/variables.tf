variable "tcp_ports" {
  type = list(number)
  default = [22, 80, 2053, 2083]
}
variable "instance_user" {
  type = string
  default = "ubuntu"
}
variable "ssh_private_key_file" {
  type = string
  default = null
}
