# kubectl-cmd

Launch `kubectl` commands with same terraform credentials, see `/test/main.tf` and `test/provider.tf` for an AWS based example on how to configure.

Basically requires these variables for setting up the kubernetes provider:

- Host/endpoint (non-sensitive)
- ca-certificate (non-sensitive)
- token (sensitive)

Since there are sensitive values, the output will be marked as sensitive and won't show. It's therefore not recommended to use this module with terraform versions which don't implement sensitive values handling (so use this module only from TF 1.0+).

## Usage

You might configure a list of scripts with kubectl commands to be launched locally using bash. Eg.:

- [`kubectl get pods -n one-namespace`, `kubectl get pods -n other-namespace`]

The output of each command will be stored in indexed log files in the form of `cmd-<app>.log-<index>` in respective order of the commands.

If needing to launch a multiline script with multiple kubectl commands executed in them only the last command executed (being that kubectl or not) will generate the log file. Example, for this multiline script:

```bash
kubectl get pods -all-namespaces
kubectl logs -n mynamespace thispod 
```
The log file will contain only the output of `kubectl logs...` execution.

Multiline scripts (using heredoc format) are considered a single command. You can mix single or multiline commands.

### Example



```terraform

module "kubectl" {
  source = "../"

  app            = "myapp"
  cluster-name   = "mycluster"
  endpoint       = var.endpoint
  token          = var.token
  ca-certificate = var.ca-certificate
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