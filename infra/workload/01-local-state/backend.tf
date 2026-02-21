terraform {
  backend "azurerm" {
    resource_group_name  = "rg-tfstate-runbook"
    storage_account_name = "sttfstate260221me01"
    container_name       = "tfstate"
    key                  = "runbook.tfstate"
  }
}