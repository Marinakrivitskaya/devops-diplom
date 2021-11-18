terraform {
  required_providers {
    random = {
      source  = "hashicorp/random"
      version = ">= 0.12.0"
    }
  }
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "Marinakrivitskaya"

    workspaces {
      name = "stage"
    }
  }
}
