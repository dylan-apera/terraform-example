$location = 'australiaeast'
$rg = 'rg-name'
$storageName = 'blobstorebkend'

az group create --name $rg --location $location

#Create storage account
az storage account create --resource-group $rg --name $storageName --sku Standard_LRS --encryption-services blob

#Get storage account key
ACCOUNT_KEY=$(az storage account keys list --resource-group $rg --account-name $storageName --query [0].value -o tsv)

#Create blob container
az storage container create --name tfbackends --account-name azureBlobStore --account-key $ACCOUNT_KEY