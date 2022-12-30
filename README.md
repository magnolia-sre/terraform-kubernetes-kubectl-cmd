# kubectl-cmd

Terraform module which launches `kubectl` commands from a shell using terraform kubernetes provider credentials, see `/test/*/main.tf` and `test/*/provider.tf` for some AWS with EKS based examples on how to configure. Allows using manually forged custom kubeconfig files too.

Basically requires these variables for setting up the kubernetes provider:

- Host/endpoint (non-sensitive)
- ca-certificate (non-sensitive)
- token (sensitive)

Since there are sensitive values, the output will be marked as sensitive and won't show. It's therefore not recommended to use this module with terraform versions which don't implement sensitive values handling (so use this module only from TF 1.0+).

## Usage

You might configure a list of (by default: bash-based) scripts with kubectl commands to be launched in the terraform running local machine. Eg.:

- [`kubectl get pods -n one-namespace`, `kubectl get pods -n other-namespace`]

The output of each command will be stored in indexed log files in the form of `cmd-<app>.log-<index of the command>` in respective order of the commands. If using the destroy commands the file name will be `cmd-<app>-destroy.log-<index>`

If needing to launch a multiline script with multiple kubectl commands executed in them only the last command executed (being that kubectl or not) will generate the log file. Example, for this multiline script:

```bash
kubectl get pods -all-namespaces
kubectl logs -n mynamespace thispod 
```
The log file will contain only the output of `kubectl logs...` execution.

Multiline scripts (using heredoc format) are considered a single command. You can mix single or multiline commands.

Use the destroy commands (`destroy-cmds`) very carefully, as with kubeconfig credentials which expire (and you should use those) if your build relies on separate-in-time destroy process, when that takes longer than the expiration time it will surely fail. Make some resilient adjustments for this factor. This is a limitation that we might not ever overcome in this module.

### Example

Example using token auth:

```terraform

module "kubectl" {
  source  = "agseijas/kubectl-cmd/kubernetes"

  app            = "myapp"
  cluster-name   = "mycluster"
  credentials    = {
    token: {
      endpoint: local.endpoint              # alternatively just directly from provider definition: data.aws_eks_cluster.cluster.endpoint 
      token: local.token                    # likewise: data.aws_eks_cluster_auth.cluster.token
      ca-certificate: local.ca-certificate  # likewise: data.aws_eks_cluster.cluster.certificate_authority.0.data
    }
  }
  cmds           = [ <<-EOT
    kubectl get pods -all-namespaces
    kubectl logs -n myapp thispod 
EOT
    ,
    "kubectl apply -f any.yaml"
  ]

  #We use the `|| true` to ensure that the failing kubectl is not important if it fails.
  destroy-cmds   = [<<-EOT
    kubectl get ns || true 
EOT
  ]
}
```

There are other auth methods (see [variables.tf # credentials](variables.tf)) you can use; or even use a prebuilt kubeconfig file.

```terraform
module "kubectl" {
  source  = "agseijas/kubectl-cmd/kubernetes"

  app            = "myapp"
  cluster-name   = "mycluster"
  credentials    = {
    kubeconfig-path: "./mykubeconfigfile"
  }
  cmds           = [ <<-EOT
    kubectl get pods -all-namespaces
    kubectl logs -n myapp thispod 
EOT
    ,
    "kubectl apply -f any.yaml"
  ]
}
```

Will generate two log files with the output of the first and second command:

`cmd-myapp.log-0` with the output of `kubectl logs -n myapp thispod`
`cmd-myapp.log-1` with the output of `kubectl apply -f any.yaml`

## Destroy phase

You might define destroy phase commands too configuring it in the var `destroy-cmds`. Use this option carefully as destroy phase will rely on kube config that might have expired when the destroy is triggered.

## Test

If you're in AWS with EKS:

```shell
cd test/eks-token #(or any of the other examples)
export TF_VAR_app="any namespace name to get pods from" \
  && export TF_VAR_cluster-name="my-cluster-name" \
  && export TF_VAR_role="arn:aws:iam::ACCOUNTID:role/my-role" \
  && export TF_VAR_region="my-region"
terraform apply
```
