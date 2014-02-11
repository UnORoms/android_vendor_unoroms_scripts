#!/bin/bash
set -xe

source vendor/unoroms/scripts/functions.sh

printHeader

checkInputParams $*

unoromdir="vendor/unoroms"
manufac=$1
device=$2
lunchCombo=$3
maketarget=$4
deviceid=$manufac_$device
devicedir="$unoromdir/devices/$manufac/$device"

repo sync -j10 -f $unoromdir/devices

rm -f .repo/local_manifests/unoroms_*.xml

cp $devicedir/manifest.xml .repo/local_manifests/unoroms_$deviceid.xml

CURRTIME=`date "+%Y-%m-%d %H:%M"`
echo $CURRTIME

repo sync -j10 -f

if [ -f $unoromdir/devices/romPatch.sh ]
then
	. $unoromdir/devices/romPatch.sh
fi

if [ -f $devicedir/deviceSpecificPatch.sh ]
then
	. $devicedir/deviceSpecificPatch.sh
fi

if [ "$(ls -A $devicedir/overrides )" ]
then
	cp -R $devicedir/overrides/* device/$manufac/$device/
fi

rm -rf out/target/product/$device

if [ -f lastSuccessRepoSync_$device ]
then
	LASTTIME=$(cat lastSuccessRepoSync_$device)
	repo forall -p -c git log --since="$LASTTIME" --oneline > changelog
	
	if [ ! -s changelog ]
	then
		echo "No changes... Not building"
		exit 0
	fi
fi



. build/envsetup.sh
lunch $lunchCombo
make -j8 $maketarget

CHANGELOG=`ls out/target/product/$device/ | grep md5sum | sed s/md5sum/changelog/g`

if [ -f changelog ]
then
	mv changelog out/target/product/$device/$CHANGELOG
else
	echo "Initial Release" > out/target/product/$device/$CHANGELOG
fi

echo $CURRTIME > lastSuccessRepoSync_$device
