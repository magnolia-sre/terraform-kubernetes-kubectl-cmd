provider "aws" {
  region = var.region
  assume_role {
    role_arn = var.role
  }
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}