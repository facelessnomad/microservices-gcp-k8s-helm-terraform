terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.13.1"
    }
    google = {
      source  = "hashicorp/google"
      version = "5.27.0"
    }
  }
}