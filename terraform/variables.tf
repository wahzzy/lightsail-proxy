variable "vpn_ports" {
  type = list(object({
    from_port = number
    to_port   = number
    protocol  = string
  }))
  default = null
}
