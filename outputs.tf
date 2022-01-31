output "logfile-name" {
  value = [ for i, cmd in null_resource.kubectl :
          format("%s-%s", local.logfile-name, i)
  ]
}