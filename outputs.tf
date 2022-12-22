output "logfile-name" {
  value = [ for i, cmd in null_resource.kubectl :
          format("%s-%s", local.logfile-name, i)
  ]
}

output "deprecation_warning" {
  value = var.endpoint != null ? "Noticed the usage of var.endpoint, please migrate to var.credentials.* instead" : "All good."
}