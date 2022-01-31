variable "cluster-name" {}

variable "always-apply" {
  type = bool
  default = true
}

variable "app" {}

variable "cmds" {
  type = list(string)
  description = "Command to execute kubectl with"
}

variable "endpoint" {}

variable "token" {}

variable "ca-certificate" {}