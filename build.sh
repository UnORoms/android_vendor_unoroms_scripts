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

repo forall -c git clean -d -f
repo forall -c git reset --hard

repo sync -j10 -f $unoromdir/devices

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

cp -R $devicedir/overrides/* device/$manufac/$device/

rm -rf out/target/product/$device

if [ -f lastSuccessRepoSync ]
then
	LASTTIME=`cat lastSuccessRepoSync`
	repo forall -p -c git log --since="$LASTTIME" > changelog
	
	if [ ! -s changelog ]
	then
		echo "No changes... Not building"
		exit 0
	fi
fi



. build/envsetup.sh
lunch $lunchCombo
make -j8 $maketarget

if [ -f changelog ]
then
	CHANGELOG=`ls out/target/product/$device/ | grep md5sum | sed s/md5sum/changelog/g`
	mv changelog out/target/product/$device/$CHANGELOG
fi

echo $CURRTIME > lastSuccessRepoSync
