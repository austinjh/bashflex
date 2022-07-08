declare -a driveseq=(c d e f g h i j k l m)
declare -a drivesize=(100 100 32)

for d in ${!drivesize[@]}
do
    echo $d is sized ${drivesize[$d]} which is device /dev/sd${driveseq[$d]}
done

echo Drives are set: ${driveseq[@]}
