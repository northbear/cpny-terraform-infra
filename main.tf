terraform {
  required_providers {
    aws = {
      version = "~> 4.20"
    }
    kubernetes = {
      version = "~> 2.11"
    }
    helm = {
      version = "~> 2.6"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      Environment      = "TestZero"
      Owner            = "Igor Yurchenko"
      TF-Configuration = "cpny-terraform-infra"
    }
  }
}

provider "kubernetes" {
  host                   = aws_eks_cluster.this.endpoint
  cluster_ca_certificate = base64decode(aws_eks_cluster.this.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.this.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.this.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.this.token
  }
}
