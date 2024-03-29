locals {
  useOldCredentials = var.credentials.token == null && var.token != null

  context_name = "terraform-${var.cluster-name}"

  kubectl_kubeconfig_param = var.credentials.kubeconfig-path != null ? "--kubeconfig='${var.credentials.kubeconfig-path}'" : "--kubeconfig <(echo $$KUBECONFIG | base64 -d)"

  kubeconfig = var.credentials.kubeconfig-path != null? "DO NOTHING" : yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = local.context_name
    clusters = [{
      name = var.cluster-name
      cluster = {
        certificate-authority-data = local.useOldCredentials ? var.ca-certificate : var.credentials.token.ca-certificate
        server                     = local.useOldCredentials ? var.endpoint : var.credentials.token.endpoint
      }
    }]
    contexts = [{
      name = local.context_name
      context = {
        cluster = var.cluster-name
        user    = local.context_name
      }
    }]
    users = [{
      name = local.context_name
      user = local.useOldCredentials || var.credentials.token != null ? {
        token = local.useOldCredentials ? var.token : var.credentials.token.token
      } : {
        client-certificate-data = var.credentials.client-certificate
        client-key-data         = var.credentials.client-key
      }
    }]
  })

  logfile-name = "cmd-${var.app}.log"
}

resource "null_resource" "kubectl" {
  count = length(var.cmds)

  triggers = {
    always_apply = var.always-apply ? timestamp() : 0
    cmd = trim(replace(var.cmds[count.index], "/(kubectl\\s+[a-zA-Z0-9]+?\\s+|kubectl)/", "$0 ${local.kubectl_kubeconfig_param} "), "\n")
  }
  provisioner "local-exec" {
    command     = format("%s %s", self.triggers.cmd, ">> ${local.logfile-name}-${count.index}")
    interpreter = var.interpreter
    environment = {
      KUBECONFIG = base64encode(local.kubeconfig)
    }
  }
}

resource "null_resource" "kubectl-destroy" {
  count = length(var.destroy-cmds)

  triggers = {
    kubeconfig   = local.kubeconfig
    logfile-name = local.logfile-name
    destroy_cmd  = trim(replace(var.destroy-cmds[count.index], "/(kubectl\\s+[a-zA-Z0-9]+?\\s+|kubectl)/", "$0 ${local.kubectl_kubeconfig_param} "), "\n")
    interpreter  = jsonencode(var.interpreter)
  }
  provisioner "local-exec" {
    when        = destroy
    command     = format("%s %s", self.triggers.destroy_cmd, ">> ${self.triggers.logfile-name}-destroy-${count.index}")
    interpreter = jsondecode(self.triggers.interpreter)
    environment = {
      KUBECONFIG = base64encode(self.triggers.kubeconfig)
    }
  }
}