#!/bin/bash
echo -e "当前日期：\c"
echo `date`
echo -e "当前进程ID：$$\n"

#字符串
str="This is a string"
str_length=${#str}
i_index=`expr index "${str}" i`
get_3_7=${str:3:7}
echo -e "字符串：\"${str}\""
echo -e "字符串长度：${str_length}"
echo -e "i的位置：${i_index}"
echo -e "从3开始取7个字符\"${get_3_7}\"\n"

#数组
arr=(v[0] v[1] v[2] v[3])
arr[3]=v_change[3]
arr_length=${#arr[*]}
index_1_length=${#arr[1]}
echo "数组:${arr[*]}"
echo "下标为1的值：${arr[1]}"
echo "数组个数：${arr_length}"
echo -e "下标为1值的长度：${index_1_length}\n"

:<<EOF
多行注释
EOF

#传参
par_num=$#
echo "参数个数：${par_num}"
echo -e "所有参数：$*"
#echo "1:${1}"
int=1
for par in $@
do
    echo "第${int}个参数：${par}"
    let "int++"
done
int=`expr ${int} - 1`
#echo "int=${int}"

#运算
str0=
str1="not null"

if [ -z "${str0}" ]
then
    echo -e "\n字符串\"${str0}\"为空"
fi

if [ -n "${str1}" ]
then
    echo -e "字符串\"${str1}\"不为空\n"
fi

sum(){
    int=1
    sum=0
    for sum_par in $@
    do
        sum=`expr ${sum} + ${sum_par}`
        echo "第${int}个参数：${sum_par}"
        let "int++"
    done
    return ${sum}
}

echo "函数传参："
sum 1 2 3
in_sum=$?
echo -e "函数传参的和：${in_sum}\n"

echo "脚本传参："
sum $@
out_sum=$?
echo -e "脚本传参的和：${out_sum}\n"

:<<EOF
echo "输点数字："
read input
sum ${input}
input_sum=$?
echo "输入的是：${input}" > input_file
echo "输入传参的和：${input_sum}" >> input_file
echo "输入的和在input_file里"
EOF

int=1
for par in $@
do
    echo "${int}:$int"
    let "int++"
done

result="verity is already disabled"
if [ "${result}" == "verity is already disabled" ]
then
    echo 1
fi


filename=/home/dir1/dir2/lun.sh
echo $0
echo $(dirname $filename)
echo $(basename $filename)

#想使用$1,或者变量嵌套，用eval
int=1
str="one"
one="two"
eval echo "$""$int"
eval echo "$""$str"

#(())比较大小
a=1
b=2
result=$((a==b))
echo a=b? : $result

#函数传入数组
function sum {
    local temp_arr=(`echo "$@"`)
    local sum=0
    for var in ${temp_arr[*]}
    do
        sum=$[$var+$sum]
    done
    echo $sum
}
arr=(1 2 3 4 5)
echo `sum ${arr[*]}`

#返回数组
function double {
    local var_arr=(`echo "$@"`)
    for ((i=0;i<${#var_arr[*]};i++))
    do
        re_arr[$i]=$[${var_arr[$i]}*2]
    done
    echo ${re_arr[*]}
}
arr=(1 2 3 4 5)
r=(`double ${arr[*]}`)

#test ${!#}
#也可以用eval，！只支持直接二次展开，eval支持拼接展开
if [ $# -gt 1 ]
then
    echo last arg:${!#}
fi
int=2
echo ${!int}
a=b
a2=c
var=a$int
echo ${!var}
eval echo "$"a"$int"





