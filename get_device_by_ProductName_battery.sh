#!/bin/bash
cd ~/camera-test/tools
all_num=`./get_device_list | wc -l`
all_device_list=`./get_device_list`
all_pro_list=()
echo all device num:$all_num

for device in $all_device_list
do
	product=`adb -s $device shell getprop | grep ro.product.device`
	product=`echo ${product} | cut -d ":" -f2`
	product=`echo ${product} | cut -d "[" -f2`
	product=`echo ${product} | cut -d "]" -f1`
	if [ ${#all_pro_list[@]} = 0 ]
	then
		all_pro_list[0]="$product $device"
	else
		key=0
		temp=0
		for ((i=0;i<${#all_pro_list[@]};i++))
		do
			pro=`echo ${all_pro_list[$i]} | cut -d " " -f1`
			if [ "$pro" = "${product}" ]
			then
				key=$i
				temp=1
				break
			else	
				temp=0
			fi	
		done

		if [ $temp -eq 0 ]
		then
			add=$[${#all_pro_list[@]}]
			all_pro_list[$add]="$product $device"
		else
			all_pro_list[$key]="${all_pro_list[$key]} $device"
		fi

	fi
done

for ((i=0;i<${#all_pro_list[@]};i++))
do
	each_pro=(${all_pro_list[i]})
	pro=${each_pro[0]}
	echo $pro:$[${#each_pro[@]}-1]
	
	for ((j=1;j<${#each_pro[@]};j++))
	do 
		echo -n "${each_pro[$j]} "
	done
	echo -e "\n"
done


i=0
for device in $all_device_list
do
         level=$(adb -s $device shell dumpsys battery | grep -E "level")
         level=$(echo $level | cut -d ":" -f2)
         if [ $level -lt 30 ]
         then
                 i=$[$i+1]
                  echo "$device battery_level: $level"
         fi
  done
  echo "level<30:" $i
































