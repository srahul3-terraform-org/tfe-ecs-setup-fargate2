terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~>2.20.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "srahul3"

    workspaces {
      name = "ecs-setup-tf"
    }
  }
  
}
provider "docker" {}

provider "aws" {
  region = var.aws_region
}