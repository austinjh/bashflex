#! /bin/bash
set -e

# az login
# az account set --subscription uob-res-dev 

# Functions definitions (Need to be at the top of the file in BASH -\M/- )

function add_pv () {
    #
}

function extend_pv () {
    #
}

# Globals definitions

declare -a diskseq=(c d e f g h i j k l m o p q r s t u v w x y z)
declare -a disksizesnew=(100 100)
declare -a pvgroup=()
declare -a diskactions=()
declare -a diskactionsvalue=()
declare -a diskactionsvol=()
DATADISK_MAX=16
DATADISK_MAXSIZE=32768
disknameprefix="nimbus-dev-camptest-1-dev-sd"
RESOURCE_NAME=vm1
RESOURCE_GROUP=rg-res-dev-research2-camptest-1
NFSSHAREVM_RG=$RESOURCE_GROUP
NFS_DATADISK_SKU=Standard

# Main sequence starts here ------------------------------------------

currentdiskqty=$(az disk list --resource-group $RESOURCE_GROUP --query "[?contains(name,'${disknameprefix}')].{Name:name,Gb:diskSizeGb,Tier:sku.tier}" --output table | grep --count sd)

# Validate inputs are viable for extending the storage allocation

if (( ${#disksizesnew[@]} > $DATADISK_MAX )); then
    echo "Error: Maximum disks reached"
    exit 1
fi
if (( ${#disksizesnew[@]} < $currentdiskqty )); then
    echo "Error: Unable to provision fewer disks than currently attached"
    exit 3
fi
re='^[0-9]+$'
for d in ${!disksizesnew[@]}; do
    if ! [[ ${disksizesnew[$d]} =~ $re ]] ; then
        echo "Error: Disk size should be a number in GB"
        exit 1
    fi
    if (( ${disksizesnew[$d]} > $DATADISK_MAXSIZE )); then
        echo "Error: Maximum disk size exceeded"
        exit 1
    fi
done

# Loop through each proposed disk size and determine an action plan.

for i in ${!disksizesnew[@]} ; do
    diskname=${diskseq[$i]}
    disksizecurrent=$(az disk list --resource-group $RESOURCE_GROUP --query "[?contains(name,'${disknameprefix}${diskname}')].diskSizeGb" --output tsv)
    disksizeproposed=${disksizesnew[$i]}
    if [ -z $disksizecurrent ]
    then
        echo "Disk will be added, size ${disksizeproposed}G"
        #echo az vm disk attach --vm-name ${RESOURCE_NAME} --resource-group $NFSSHAREVM_RG --name ${disknameprefix}${diskname} --size-gb ${disksizeproposed} --sku $NFS_DATADISK_SKU --new
        diskactions[$i]="Add"
        diskactionsvalue[$1]=${disksizeproposed}
    else
        if (( $disksizeproposed > $disksizecurrent ))
        then
            echo "Disk will be expanded from ${disksizecurrent}G to ${disksizeproposed}G"
            echo az disk update --name ${disknameprefix}${diskname} --resource-group $RESOURCE_GROUP --size-gb $disksizeproposed
        else
            echo "NO CHANGE - Disk ${disknameprefix}${diskname} will remain at ${disksizecurrent}G"
            if (( $disksizeproposed < $disksizecurrent )); then
                echo "Updated disk sizes are not permmited to be smaller than those currently attached"
                exit 2
            fi
        fi
    fi
done

# Loop through the proposed actions and make the required changes to the disks

for a in ${!diskactions[@]} ; do
    action=${diskactions[$a]}
    diskletter=${diskseq[$a]}
    changesize=${diskactionsvalue[$a]}
    case $action in

        add)
        add_pv $diskletter $changesize
        ;;

        extend)
        extend_pv $diskletter $changesize
        ;;
        
    esac
done

