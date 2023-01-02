variable "role" {}
variable "cluster_name" {}
variable "region" {}
variable "app" {}

locals {
  endpoint       = data.aws_eks_cluster.cluster.endpoint
  token          = data.aws_eks_cluster_auth.cluster.token
  ca-certificate = data.aws_eks_cluster.cluster.certificate_authority.0.data
}

module "kubectl" {
  source = "../../"

  app            = var.app
  cluster-name   = var.cluster_name
  credentials    = {
    token: {
      endpoint: local.endpoint
      token: local.token
      ca-certificate: local.ca-certificate
    }
  }
  cmds           = [ <<-EOT
      rm *.log* || true
      export pod_to_log=$(kubectl get pods --field-selector=status.phase!=Running -n ${var.app} | awk 'FNR==2{print $1}')
      #If there were no failures, select any running pod.
      [ -z "$pod_to_log" ] && export pod_to_log=$(kubectl get pods -n ${var.app} | awk 'FNR==2{print $1}')
      kubectl logs -n ${var.app} $pod_to_log
EOT
  ]
  destroy-cmds = [
    <<-EOT
      kubectl get pods -n ${var.app}
EOT
  , "kubectl get ns"]
}

output "logs" {
  value = module.kubectl.logfile-name
}

output "logs-destroy" {
  value = module.kubectl.logfile-destroy-name
}
