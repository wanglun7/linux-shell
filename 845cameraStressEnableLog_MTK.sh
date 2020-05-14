#!/bin/bash
IPADDRESS=$1
#测试之前做需要哪些操作
testBootSetline=`sed -n '2p' configBefore.txt`
testBootSet=`echo $testBootSetline | awk -F ":" '{print $2}'`
debugBuildline=`sed -n '3p' configBefore.txt`
debugBuild=`echo $debugBuildline | awk -F ":" '{print $2}'`
developerOptionsline=`sed -n '4p' configBefore.txt`
developerOptions=`echo $developerOptionsline | awk -F ":" '{print $2}'`
logbuffer16Mline=`sed -n '5p' configBefore.txt`
logbuffer16M=`echo $logbuffer16Mline | awk -F ":" '{print $2}'`
testBootConnectWiFiMline=`sed -n '6p' configBefore.txt`
testBootConnectWiFi=`echo $testBootConnectWiFiMline | awk -F ":" '{print $2}'`
#Root Remount手机
rootRemount(){
    echo "Root phone Remount phone"
    adb -s ${IPADDRESS} root
    sleep 3
    adb -s ${IPADDRESS} disable-verity
    sleep 3
    adb -s ${IPADDRESS} reboot
    waitUI
}
stress(){
    adb -s ${IPADDRESS} wait-for-device root
    adb -s ${IPADDRESS} wait-for-device remount
    adb -s ${IPADDRESS} wait-for-device push device_features/MiuiCamera.apk /system/priv-app/MiuiCamera/MiuiCamera.apk
    adb -s ${IPADDRESS} reboot
    waitUI
}

#等待手机重启进入home界面
waitUI(){
    while true;do
        case `adb -s ${IPADDRESS} shell ls sdcard |grep -c -w MIUI` in
            0)
                echo "please wait booting!!!!"
                sleep 10
                ;;
            1)
                echo "booting success"
                adb -s ${IPADDRESS} wait-for-device root
                adb -s ${IPADDRESS} wait-for-device remount
                break
                ;;
            *)
                echo "result:"`adb -s ${IPADDRESS} shell ls sdcard |grep -c -w MIUI`
                ;;
        esac
        local a=$((a+1))
        if [ $a -eq 100 ];then
            echo "wait 500 s, phone booting failed!!! pause~~"
            sleep 1000000
        fi
    done
}
#安装相机压力测试APK
installTestAPK(){
    if [ $debugBuild == "Y" ];then
        echo "Install test APK"
        adb -s ${IPADDRESS} push apk/stressAPK/signed_PLATFORM-test_app-debug.apk /data/local/tmp/
        adb -s ${IPADDRESS} push apk/stressAPK/signed_PLATFORM-test_app-debug-androidTest.apk /data/local/tmp/
        adb -s ${IPADDRESS} shell pm install -t -r /data/local/tmp/signed_PLATFORM-test_app-debug.apk
        adb -s ${IPADDRESS} shell pm install -t -r /data/local/tmp/signed_PLATFORM-test_app-debug-androidTest.apk
    else
        echo "Install miui APK"
        adb -s ${IPADDRESS} push apk/stressAPK/signed_PLATFORM_app-debug.apk /data/local/tmp/
        adb -s ${IPADDRESS} push apk/stressAPK/signed_PLATFORM_app-debug-androidTest.apk /data/local/tmp/
        adb -s ${IPADDRESS} shell pm install -t -r /data/local/tmp/signed_PLATFORM_app-debug.apk
        adb -s ${IPADDRESS} shell pm install -t -r /data/local/tmp/signed_PLATFORM_app-debug-androidTest.apk

    fi
}


#Before Camera Stress Test :precondition
precondition(){
    #安装Uiautomator2.0脚本
    adb -s ${IPADDRESS} push apk/app-debug.apk /data/local/tmp/
    adb -s ${IPADDRESS} push apk/app-debug-androidTest.apk /data/local/tmp/
    adb -s ${IPADDRESS} shell pm install -t -r /data/local/tmp/app-debug.apk
    adb -s ${IPADDRESS} shell pm install -t -r /data/local/tmp/app-debug-androidTest.apk
    #自动执行开机向导
    if [ $testBootSet == "Y" ];then
        adb -s ${IPADDRESS} shell am instrument -w -r -e debug false -e class com.xiaomi.miui.cases.stability.factoryreset#testBootSet com.xiaomi.tcauto.uitest.test/android.support.test.runner.AndroidJUnitRunner > ${IPADDRESS}testBootSet.txt
        while true;do
            if [ `grep -c "FAILURES!!!" ${IPADDRESS}testBootSet.txt` -ne 0 ];then
                echo "BootSet case run failed , logout again"
                rm ${IPADDRESS}testBootSet.txt
                adb -s ${IPADDRESS} shell am instrument -w -r -e debug false -e class com.xiaomi.miui.cases.stability.factoryreset#testBootSet com.xiaomi.tcauto.uitest.test/android.support.test.runner.AndroidJUnitRunner > ${IPADDRESS}testBootSet.txt
                cat ${IPADDRESS}testBootSet.txt
            else
                echo "BootSet case pass~~"
                rm ${IPADDRESS}testBootSet.txt
                break
            fi
        done
    fi
    #开机引导加白机器跳过联网
    if [ $testBootConnectWiFi == "Y" ];then
        adb -s ${IPADDRESS} shell am instrument -w -r -e debug false -e class com.xiaomi.miui.cases.stability.factoryreset#testConnectWiFi com.xiaomi.tcauto.uitest.test/android.support.test.runner.AndroidJUnitRunner > ${IPADDRESS}testConnectWiFi.txt
        while true;do
            if [ `grep -c "FAILURES!!!" ${IPADDRESS}testConnectWiFi.txt` -ne 0 ];then
                echo "testConnectWiFi case run failed , testConnectWiFi again"
                rm ${IPADDRESS}testConnectWiFi.txt
                adb -s ${IPADDRESS} shell am instrument -w -r -e debug false -e class com.xiaomi.miui.cases.stability.factoryreset#testConnectWiFi com.xiaomi.tcauto.uitest.test/android.support.test.runner.AndroidJUnitRunner > ${IPADDRESS}testConnectWiFi.txt
                cat ${IPADDRESS}testConnectWiFi.txt
            else
                echo "testConnectWiFi case pass~~"
                rm ${IPADDRESS}testConnectWiFi.txt
                break
            fi
        done
    fi
    #开发者选项中设置不锁屏和直接进入系统
    if [ $developerOptions == "Y" ];then
        adb -s ${IPADDRESS} shell am instrument -w -r -e debug false -e class com.xiaomi.miui.cases.stability.factoryreset#testDeveloperOptions com.xiaomi.tcauto.uitest.test/android.support.test.runner.AndroidJUnitRunner > ${IPADDRESS}testDeveloperOptions.txt
        while true;do
            if [ `grep -c "FAILURES!!!" ${IPADDRESS}testDeveloperOptions.txt` -ne 0 ];then
                echo "testDeveloperOptions case run failed , testDeveloperOptions again"
                rm ${IPADDRESS}testDeveloperOptions.txt
                adb -s ${IPADDRESS} shell am instrument -w -r -e debug false -e class com.xiaomi.miui.cases.stability.factoryreset#testDeveloperOptions com.xiaomi.tcauto.uitest.test/android.support.test.runner.AndroidJUnitRunner > ${IPADDRESS}testDeveloperOptions.txt
                cat ${IPADDRESS}testDeveloperOptions.txt
            else
                echo "testDeveloperOptions case pass~~"
                rm ${IPADDRESS}testDeveloperOptions.txt
                break
            fi
        done
    fi
    #开发者选项中设置日志缓冲区为16M
    if [ $logbuffer16M == "Y" ];then
        adb -s ${IPADDRESS} shell am instrument -w -r -e debug false -e class com.xiaomi.miui.cases.stability.factoryreset#testlogbuffer16M com.xiaomi.tcauto.uitest.test/android.support.test.runner.AndroidJUnitRunner > ${IPADDRESS}testlogbuffer16M.txt
        while true;do
            if [ `grep -c "FAILURES!!!" ${IPADDRESS}testlogbuffer16M.txt` -ne 0 ];then
                echo "testlogbuffer16M case run failed , testlogbuffer16M again"
                rm ${IPADDRESS}testlogbuffer16M.txt
                adb -s ${IPADDRESS} shell am instrument -w -r -e debug false -e class com.xiaomi.miui.cases.stability.factoryreset#testlogbuffer16M com.xiaomi.tcauto.uitest.test/android.support.test.runner.AndroidJUnitRunner > ${IPADDRESS}testlogbuffer16M.txt
                cat ${IPADDRESS}testlogbuffer16M.txt
            else
                echo "testlogbuffer16M case pass~~"
                rm ${IPADDRESS}testlogbuffer16M.txt
                break
            fi
        done
    fi
}

echo "Go GO Go GO Go GO ~~~~~"

#openLog
openLog(){
    openOfflineLog(){
        echo "Open offline log"
        adb -s ${IPADDRESS} wait-for-device shell setprop persist.sys.offlinelog.kernel true
        adb -s ${IPADDRESS} wait-for-device shell setprop persist.sys.offlinelog.logcat true
    }
    openCameraDebugLog(){
        echo "Open camere debuglog"
        adb -s ${IPADDRESS} wait-for-device shell "echo 'libc.debug.malloc.program=android.hardware.camera.provider@2.4-service' >>/system/build.prop"
        adb -s ${IPADDRESS} wait-for-device shell "echo 'libc.debug.malloc=10' >>/system/build.prop"
        adb -s ${IPADDRESS} wait-for-device shell "echo overrideLogLevels=0xF >> /vendor/etc/camera/camxoverridesettings.txt" 
        adb -s ${IPADDRESS} wait-for-device shell "echo logVerboseMask=0x1000 >> /vendor/etc/camera/camxoverridesettings.txt"
        adb -s ${IPADDRESS} wait-for-device shell "echo logInfoMask=0xFFFFFFFF >> /vendor/etc/camera/camxoverridesettings.txt" 
        sztr_len=`adb -s ${IPADDRESS} shell df -h | grep media | awk '{print $2}' | awk '{print length}'`
        let sz_len=$sztr_len-1
        media_sz=`adb -s ${IPADDRESS} shell df -h | grep media | awk '{print $2}' | cut -c1-$sz_len`
        if [ $media_sz -gt 130 ];then
            adb -s ${IPADDRESS} shell echo "systemLogEnable=TRUE  >>  /vendor/etc/camera/camxoverridesettings.txt"
            adb -s ${IPADDRESS} shell echo "debugLogFilename=camxdbg  >>  /vendor/etc/camera/camxoverridesettings.txt"
        fi
    }
    openCoredump(){
        echo "Open coredump"
        #adb -s ${IPADDRESS} wait-for-device logcat -G 256M
        adb -s ${IPADDRESS} wait-for-device shell setprop persist.debug.trace 1
        adb -s ${IPADDRESS} wait-for-device shell setprop kill_camera_service_enable false
        adb -s ${IPADDRESS} wait-for-device shell setenforce 0
        adb -s ${IPADDRESS} wait-for-device shell getenforce
    }
    openOfflineLog
    openCameraDebugLog
    openCoredump
}

eatmem(){
    adb -s ${IPADDRESS} wait-for-device push fragmentize-E10-P.ko /system/bin
    adb -s ${IPADDRESS} wait-for-device shell insmod system/bin/fragmentize-E10-P.ko accupy=1000
}

openMTKLog(){
    adb -s $1 shell setenforce 0
    adb -s $1 shell setprop persist.vendor.mtk.camera.log_level 3
    adb -s $1 shell setprop persist.mtk.camera.log_level 3
    adb -s $1 shell setprop vendor.debug.camera.capture.log 3
#    adb -s $1 shell logcat -G 8M
    adb -s $1 shell pkill camerahal*
    adb -s $1 shell am broadcast -a com.debug.loggerui.ADB_CMD -e cmd_name switch_taglog --ei cmd_target 1 -n com.debug.loggerui/.framework.LogReceiver
    adb -s $1 shell am broadcast -a com.debug.loggerui.ADB_CMD -e cmd_name start --ei cmd_target 1 -n com.debug.loggerui/.framework.LogReceiver
}

#installTestAPK
#precondition
rootRemount
# stress
# openLog
openMTKLog "${IPADDRESS}"
