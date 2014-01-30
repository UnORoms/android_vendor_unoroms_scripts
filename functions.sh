#!/bin/bash
set -xe

function printHeader() {

echo ".....-----===== UnORoms Project =====-----......"

}


function checkInputParams() {
	echo "Manufacturer : $1"	
	if ( isArgumentNull "$1" )
	then
		echo "Manufacturer is not specified"
		exit 1
	fi
	

	echo "Device : $2"      
        if ( isArgumentNull "$2" )
        then
                echo "Device is not specified"
                exit 1
        fi

	echo "Lunch Combo : $3"      
        if ( isArgumentNull "$3" )
        then
                echo "Lunch Combo is not specified"
                exit 1
        fi

	echo "Make Target : $4"      
        if ( isArgumentNull "$4" )
        then
                echo "Make Target is not specified"
                exit 1
        fi

}

function isArgumentNull() {

	if [ ! $1 ]
	then
		return 0
	fi
	return 1

}
