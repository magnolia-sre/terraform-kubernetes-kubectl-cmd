variable "cluster-name" {
  description = "Name of the k8s cluster to connect to. Ex. for a k8s cluster named `my-cluster-has-a-very-long-and-complex-name` use: `my-cluster-has-a-very-long-and-complex-name`"
}

variable "always-apply" {
  type = bool
  default = true
}

variable "app" {
  description = "The console-log output file names will use this app name variable. Ex. for `myapp`: cmd-myapp.log-0"
}

variable "cmds" {
  type = list(string)
  description = "Command(s) which will ultimately contain a `kubectl` command execution"
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

variable "interpreter" {
  default = ["/bin/bash", "-c"]
  description = "Provide a different than default ('/bin/bash') interpreter."
}