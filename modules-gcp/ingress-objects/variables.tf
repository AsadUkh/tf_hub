
variable "ingress_hosts" {
  type = list(object({
    host         = string
    path         = string
    backend_name = string
    port         = number
  }))
}


variable "namespace" {
  default = "apps"
}

variable "ingress_name" {
  default = "multi-host-ingress"
}

