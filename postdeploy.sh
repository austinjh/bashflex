declare -a driveseq=(c d e f g h i j k l m o p q r s t u v w x y z)
declare -a drivesize=(100 100 32 100000000)
declare -a drivesizenew=()
declare -a pvgroup=()
DATADISK_MAX=16
DATADISK_MAXSIZE=32768


if (( ${#drivesize[@]} > $DATADISK_MAX )); then
    echo "Maximum disks reached"
    exit 1
fi

for d in ${!drivesize[@]}
do
    if (( ${drivesize[$d]} > $DATADISK_MAXSIZE )); then
        echo "Maximum disk size exceeded"
        exit 1
    fi
    echo $d is sized ${drivesize[$d]} which is device /dev/sd${driveseq[$d]}
    pvgroup[$d]=/dev/sd${driveseq[$d]}
done

pvgroupstr=${pvgroup[@]}

echo $pvgroupstr
