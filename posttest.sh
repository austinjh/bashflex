declare -a driveseq=(c d e f g h i j k l m o p q r s t u v w x y z)
declare -a drivesize=(100 100 50)
declare -a drivesizenew=()
declare -a pvgroup=()
DATADISK_MAX=16
LVM_SIZE=0


for d in ${!drivesize[@]}
do
    echo $d is sized ${drivesize[$d]} which is device /dev/sd${driveseq[$d]}
    pvgroup[$d]=/dev/sd${driveseq[$d]}
    LVM_SIZE=$(( $LVM_SIZE + ${drivesize[$d]} ))
done

pvgroupstr=${pvgroup[@]}
echo $pvgroupstr
echo LVM Size: $LVM_SIZE
#sudo pvcreate $pvgroupstr > \$logfile