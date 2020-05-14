#!/bin/bash

flash(){
	~/camera-test/tools/flash_device.sh -d $2 -s $1
}

setup(){
	cd ~/camera-test/tools/
        git pull
        source libs.sh
        ./execute/setup_test_env -s $1
}

log(){
	~/845cameraStressEnableLog_MTK.sh $1
}

exist_path(){
    path=~/monkey_log/$1/$(date +"%Y-%m-%d")
    mkdir -p $path
    echo $path
}

monkey(){
    path=`exist_path $1`
    adb -s $1 shell monkey -v --throttle 200 --ignore-crashes --pct-touch\
    40 --pct-motion 35 --pct-appswitch 5 --pct-anyevent 5 --pct-trackball 0\
    --pct-syskeys 5 --pct-pinchzoom 5 -p com.android.camera --bugreport 300000 >\
    $path/monkey.txt
    echo 'monkey is done,log path:$path'
}

while getopts "d:f:slm" opt
do
	case $opt in
	d)
		device_list=$OPTARG;;
	f)
        dir_build=$OPTARG
		flash $device_list $dir_build;;
	s)
		setup $device_list;;
	l)
		log $device_list;;
	m)
		monkey $device_list;;
	esac
done

