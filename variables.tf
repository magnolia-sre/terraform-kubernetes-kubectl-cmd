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

variable "destroy-cmds" {
  type = list(string)
  default = [""]
  description = "Commands to execute during the destroy phase of the terraform module, using kubectl commands of course."
}


variable "endpoint" {
  default = null
  description = "Deprecated, please use the equivalent credentials.token.* var. This will be removed soon!"
}

variable "token" {
  default = null
  description = "Deprecated, please use the equivalent credentials.token.* var. This will be removed soon!"
}

variable "ca-certificate" {
  default = null
  description = "Deprecated, please use the equivalent credentials.ca-certificate var. This will be removed soon!"
}

variable "credentials" {
  default = {}
  description = "Currently only supports token and kubeconfig-path"
  type = object({
    token: optional(object({
      ca-certificate: optional(string) #TODO: determine if it belongs here or directly under its parent.
      endpoint: optional(string)
      token: optional(string)
    }))
    client-certificate: optional(string)
    client-key: optional(string)
    kubeconfig-path: optional(string)
  })
}