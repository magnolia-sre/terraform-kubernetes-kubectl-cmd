variable "role" {}
variable "cluster_name" {}
variable "region" {}
variable "app" {}

module "kubectl" {
  source = "../../"

  app            = var.app
  cluster-name   = var.cluster_name
  credentials    = {
    kubeconfig-path = "./kube.cfg"
  }
  cmds           = [ <<-EOT
      rm *.log* || true
      export pod_to_log=$(kubectl get pods --field-selector=status.phase!=Running -n ${var.app} | awk 'FNR==2{print $1}')
      #If there were no failures, select any running pod.
      [ -z "$pod_to_log" ] && export pod_to_log=$(kubectl get pods -n ${var.app} | awk 'FNR==2{print $1}')
      kubectl logs -n ${var.app} $pod_to_log
EOT
  ]
}

output "logs" {
  value = module.kubectl.logfile-name
}