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

repo forall -c git reset --hard && git clean -f -d

repo sync -j10 -f $unoromdir/devices

cp $devicedir/manifest.xml .repo/local_manifests/unoroms_$deviceid.xml

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

. build/envsetup.sh
lunch $lunchCombo
make -j8 $maketarget
