#! /bin/bash
set -e

# az login
# az account set --name uob-res-dev

RESOURCE_GROUP=rg-res-dev-research2-camptest-1
# az disk list --resource-group $RESOURCE_GROUP --query "[*].{Name:name,Gb:diskSizeGb,Tier:sku.tier}" --output table
declare test=($(az disk list --resource-group $RESOURCE_GROUP --query "[*].{Name:name,Gb:diskSizeGb,Tier:sku.tier}" --output table))

# az disk list --resource-group $RESOURCE_GROUP --output table

echo ${test[@]}