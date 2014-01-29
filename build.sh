#!/bin/bash

source vendor/unoroms/scripts/functions.sh

printHeader

checkInputParams $*

unoromdir="vendor/unoroms"
manufac=$1
device=$2
lunchCombo=$3
deviceid=$manufac_$device
devicedir="$unoromdir/devices/$manufac/$device"

repo forall git clean -d -f

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
make -j8 bacon
