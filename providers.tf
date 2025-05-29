
# terraform bloc providers
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-prod"
    storage_account_name = "mysaterraformprod"
    container_name       = "mysacontainer"
    key                  = "prod.terraform.tfstate"
  }
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.30.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }
}

provider "azurerm" {
  features {}
}