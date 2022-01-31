module "kubectl" {
  source = "../"

  app            = var.app
  cluster-name   = var.cluster-name
  endpoint       = local.endpoint
  token          = local.token
  ca-certificate = local.ca-certificate
  cmds           = [ <<-EOT
      rm *.log* || true
      export pod_to_log=$(kubectl get pods --field-selector=status.phase!=Running -n ${var.app} | awk 'FNR==2{print $1}')
      #If there were no failures, select any running pod.
      [ -z "$pod_to_log" ] && export pod_to_log=$(kubectl get pods -n ${var.app} | awk 'FNR==2{print $1}')
      kubectl logs -n ${var.app} $pod_to_log
EOT
  ]
}