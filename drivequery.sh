#! /bin/bash
set -e

# az login
# az account set --name uob-res-dev

declare -a diskseq=(c d e f g h i j k l m o p q r s t u v w x y z)
declare -a disksizes=(100 100 32)
declare -a disksizesnew=(100 100 64)
declare -a pvgroup=()
DATADISK_MAX=16
DATADISK_MAXSIZE=32768
disknameprefix="nimbus-dev-camptest-1-dev-sd"

RESOURCE_GROUP=rg-res-dev-research2-camptest-1

az disk list --resource-group $RESOURCE_GROUP --query "[*].{Name:name,Gb:diskSizeGb,Tier:sku.tier}" --output table

if (( ${#disksizesnew[@]} > $DATADISK_MAX )); then
    echo "Error: Maximum disks reached"
    exit 1
fi

re='^[0-9]+$'
for d in ${!disksizes[@]}; do
    if ! [[ ${disksizes[$d]} =~ $re ]] ; then
        echo "Error: Disk size should be a number in GB"
        exit 1
    fi
    if (( ${disksizes[$d]} > $DATADISK_MAXSIZE )); then
        echo "Error: Maximum disk size exceeded"
        exit 1
    fi
done

for i in ${!disksizesnew[@]} ; do
    diskname=${diskseq[$i]}
    disksizecurrent=$(az disk list --resource-group $RESOURCE_GROUP --query "[?contains(name,'${disknameprefix}${diskname}')].diskSizeGb" --output tsv)
    disksizeproposed=${disksizesnew[i]}
    echo ${disknameprefix}${diskname} is sized at $disksizecurrent
    if (( $disksizeproposed > $$disksizecurrent ))
    then
        echo Drive will be expanded from ${disksizecurrent}G to ${disksizeproposed}G
    else
        echo NO CHANGE - Drive ${disknameprefix}${diskname} will remain at ${disksizecurrent}G
    fi
done


for d in ${!disksizes[@]}; do
    echo az vm disk attach \
    --vm-name "${RESOURCE_NAME}" \
    --resource-group "$NFSSHAREVM_RG" \
    --name "${RESOURCE_NAME}-dev-sd${diskseq[$d]}" \
    --size-gb "${disksizes[$d]}" \
    --sku "$NFS_DATADISK_SKU" \
    --new
done
