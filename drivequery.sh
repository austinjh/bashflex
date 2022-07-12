#! /bin/bash
set -e

# az login
# az account set --name uob-res-dev

declare -a driveseq=(c d e f g h i j k l m o p q r s t u v w x y z)
declare -a drivesize=(100 100 32)
declare -a drivesizenew=(100 100 64)
declare -a pvgroup=()
DATADISK_MAX=16
DATADISK_MAXSIZE=32768
disknameprefix="nimbus-dev-camptest-1-dev-sd"

RESOURCE_GROUP=rg-res-dev-research2-camptest-1
# az disk list --resource-group $RESOURCE_GROUP --query "[*].{Name:name,Gb:diskSizeGb,Tier:sku.tier}" --output table
# declare test=($(az disk list --resource-group $RESOURCE_GROUP --query "[*].{Name:name,Gb:diskSizeGb,Tier:sku.tier}" --output table))

# az disk list --resource-group $RESOURCE_GROUP --output table

# echo ${test[@]}

# Get
az disk list --resource-group $RESOURCE_GROUP --query "[*].{Name:name,Gb:diskSizeGb,Tier:sku.tier}" --output table

# Get everything
# az disk list --resource-group $RESOURCE_GROUP
# az disk list --resource-group $RESOURCE_GROUP --query "[?contains(name,'nimbus-dev-camptest-1-dev-sd')].{Name:name,Gb:diskSizeGb}" --output tsv
# namearray=$(az disk list --resource-group $RESOURCE_GROUP --query "[?contains(name,'nimbus-dev-camptest-1-dev-sd')].diskSizeGb" --output tsv)

# az disk list --resource-group $RESOURCE_GROUP --query "[?contains(name,${disknameprefix})].{GB:diskSizeGb}" --output table


for i in ${!drivesizenew[@]} ; do
    diskname=${driveseq[$i]}
    echo ${disknameprefix}${diskname}
    az disk list --resource-group $RESOURCE_GROUP --query "[?contains(name,'${disknameprefix}${diskname}')].diskSizeGb" --output tsv
done

if (( ${#drivesizenew[@]} > $DATADISK_MAX )); then
    echo "Error: Maximum disks reached"
    exit 1
fi

re='^[0-9]+$'
for d in ${!drivesize[@]}; do
    if ! [[ ${drivesize[$d]} =~ $re ]] ; then
        echo "Error: Disk size should be a number in GB"
        exit 1
    fi
    if (( ${drivesize[$d]} > $DATADISK_MAXSIZE )); then
        echo "Error: Maximum disk size exceeded"
        exit 1
    fi
done

for d in ${!drivesize[@]}; do
    az vm disk attach \
    --vm-name "${RESOURCE_NAME}" \
    --resource-group "$NFSSHAREVM_RG" \
    --name "${RESOURCE_NAME}-dev-sd${driveseq[$d]}" \
    --size-gb "${drivesize[$d]}" \
    --sku "$NFS_DATADISK_SKU" \
    --new
done
