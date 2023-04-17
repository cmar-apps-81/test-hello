terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "cmar"

    workspaces {
      name = "eks-svc"
    }
  }
}
