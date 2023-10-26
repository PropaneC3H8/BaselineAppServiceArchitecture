terraform {
  required_providers {
    azurerm = {
      version = "= 3.68.0"
    }

    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }

  backend "azurerm" {}
}

provider "azurerm" {
  features {}
}