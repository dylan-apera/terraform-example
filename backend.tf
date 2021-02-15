#Connect terraform to blob storage - create a remote backend on Azure for terraform
terraform {
    backend "azurerm" {
        storage_account_name  = "storageremotetfdemo"
        container_name        = "tfbackends"
        key                   = "myappli.tfstate" 
    }
}

#Help -> https://www.terraform.io/docs/language/settings/backends/azurerm.html
#test