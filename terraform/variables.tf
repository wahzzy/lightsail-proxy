variable "tcp_ports" {
  type = list(number)
  default = null
}
variable "instance_user" {
  type = string
  default = "ubuntu"
}
variable "ssh_private_key_file" {
  type = string
  default = null
}
variable "domain" {
  type = string
  default = null
}
variable "cloudflare_token" {
  type = string
  default = null
}
variable "zone_id" {
  type = string
  default = null
}
variable "dns_record_id" {
  type = string
  default = null
}
variable "vpn_user" {
  type = string
  default = null
}
variable "vpn_password" {
  type = string
  default = null
}
variable "vpn_email" {
  type = string
  default = null
}
