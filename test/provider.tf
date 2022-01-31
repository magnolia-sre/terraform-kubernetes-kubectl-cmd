provider "aws" {
  region = var.region
  assume_role {
    role_arn = var.role
  }
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster-name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster-name
}

variable "role" {}
variable "cluster-name" {}
variable "region" {}
variable "app" {}

locals {
  endpoint       = data.aws_eks_cluster.cluster.endpoint
  token          = data.aws_eks_cluster_auth.cluster.token
  ca-certificate = data.aws_eks_cluster.cluster.certificate_authority.0.data
}