terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.82.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.4.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

provider "http" {}