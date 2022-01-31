provider "kubernetes" {
  host                   = local.endpoint
  token                  = local.token
  cluster_ca_certificate = base64decode(local.ca-certificate)
}

locals {
  endpoint       = var.endpoint
  token          = var.token
  ca-certificate = var.ca-certificate

  context_name = "terraform-${var.cluster-name}"

  kubeconfig = yamlencode({
    apiVersion      = "v1"
    kind            = "Config"
    current-context = local.context_name
    clusters = [{
      name = var.cluster-name
      cluster = {
        certificate-authority-data = local.ca-certificate
        server                     = local.endpoint
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
      user = {
        token = local.token
      }
    }]
  })

  logfile-name = "cmd-${var.app}.log"
}

resource "null_resource" "kubectl" {
  count = length(var.cmds)

  triggers = {
    always_apply = var.always-apply ? timestamp() : 0
    cmd = trim(replace(var.cmds[count.index], "kubectl", "kubectl --kubeconfig <(echo $KUBECONFIG | base64 -d)"), "\n")
  }
  provisioner "local-exec" {
    command     = format("%s %s", self.triggers.cmd, ">> ${local.logfile-name}-${count.index}")
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = base64encode(local.kubeconfig)
    }
  }
}