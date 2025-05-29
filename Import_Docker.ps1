
# Variables 
param (
    [string]$RegistryName,
    [string]$SOURCEIMAGE="docker.io/library/hello-world:latest",
    [string]$IMAGE="hello-world:latest", 
    [string]$USERNAME="dockerepo123"
    )


Write-Host "Importation de l'image hello-world vers ACR "

az acr import --name $RegistryName --source $SOURCEIMAGE --image $IMAGE --username $USERNAME --password *******

Write-Host "Importation Effectuée"