# linux,shell,git

## linux命令相关

* nohup ./auto_run_stress.sh &  
可以实现ssh连接后，输入命令执行，在ssh断开后，进程依然在后台运行  
    * 查看输出  
      输出默认保存在nohup.out 中，也可以自定义重定向 nohup command > myout.file 2>&1 &   
    * 查看任务：jobs   
  
* 查看进程：ps 
  *  如果想查看进程的CPU占用率和内存占用率，可以使用aux
  *  如果想查看进程的父进程ID和完整的COMMAND命令，可以使用-ef   
  
* 查找文件  find . –name “ ” 通配符*

* 查看文件大小 du –sh 文件名 

* 查找大文件find . -type f -size +800M

* 显示当前路径：pwd

* 复制文件夹：cp –r

* dirname该命令可以取给定路径的目录部分  
 basename命令：去掉目录和文件的后缀，只取文件名  

* tail -f：循环读取持续更新的文件内容，watch

* tmux： tmux attach || tmux 相当于nohup的窗口化  
	* Ctrl+b切命令模式  
	* d退出session
	* tmux ls查看所有，tmux a -t n连接，tmux kill-session -t n删除session
	* c创建新窗口  &关闭窗口  数字键：切到指定窗口  切换上一个p，下一个n  
	* tmux detach -a适配显示大小
	* 窗格新建Ctrl+b，%，切换按方向键，关闭x
	
* mkdir -p path 如果目录不存在，则创建，使用于多级目录的创建
* ls -l详细输出当前路径下文件，默认最新的文件在最下面

* grep -E使用正则表达式，-o只显示匹配到的（默认显示一行）
	* 场景1：判断某文件是否存在，find之后|grep-E，然后判断结果是否为空
	* 场景2：判断输出中是否存在某字符，同上
	
* sed -n 1p http_temp.txt显示一个文件的第几行

* sed -i "s;${pro_old};${product_name};g" stress_test_report.html
	* 字符串替换
	* 需要注意变量的字符串如果有引号需要转义\"
	* 默认分隔符可以用/，但是由于变量中存在/，所以可以换用;
	
* 用linux连接其他主机：ssh mi@10.221.167.187

## vim相关
配置显示行数/etc/vim/vimrc    加一行set number

## shell相关
**Shell 命令模式操作**

* 撤销之前的操作：u
* 复制：yy复制整行 y$复制到行尾 yw复制单词
* 粘贴：p
* 删除：dd删除整行  d$删除到行尾 dw删除单词
* 查找：/字符   回车

## shell编程
**创建脚本**  
touch name.sh  
#!/bin/bash  
chmod +x ./test.sh  #使脚本具有执行权限  
./test.sh  #执行脚本  

**变量**  
字母/数字/_ 	(首字符不能为数字)  
使用变量：${variable_name}  
只读变量：readonly variable_name  
删除变量：unset variable_name (不能删只读变量)  
${#name}获取变量值的长度  

**${}也可用于字符串切割/替换**
* 切割  
去掉左边：#，去掉右边：%，一个#/%：最小匹配，两个##/%%：最大匹配，最后正则匹配  
如：file=/dir1/dir2/dir3/my.file.txt  
${file##*/}最大匹配，*/匹配到/dir1/dir2/dir3/，最后去掉左边得到my.file.txt  
* 替换  
	如将所有dir替换为path：${file//dir/path} 	
参数：file，（/：第一个替换，//：全部替换），dir，/，path

**Eval 二次扫描，可用于变量嵌套**  
原理：先取变量的值，作为变量名，然后获取嵌套变量的值  
* 赋值：eval temp="$""${int}"  
* 输出变量值：eval echo "$""$int" ，可用于"$""$#"输出最后一个参数的值
* 如果是直接变量嵌套，可以用${!int}
* 如果是字符串拼接之后再取值，只能eval echo “$”a”$int”

**字符串：str=” ”**
* 字符串长度：${#str}
* 提取字符串中的字符：${str:1:4}	首字符下标0，从1开始提取4个字符
* 查找字符串： \`expr index “$str” abc\`  输出第一个a的位置（不是下标）

**数组**

* 整体赋值：Arr=(v0 v1 v2)
* 根据下标赋值：arr[0]=
* 根据下标取值：${arr[index]}	
* 输出数组的所有值：${arr[*]}
* 获取数组长度：${#arr[*]}

**注释**  
单行：#  
多行：<<EOF	注释内容	EOF  

**脚本传参./test.sh 1 2 3**  
如果其中一个参数中间有空格，传字符串“x x”  
当n>=10时，需要使用${n}来使用参数  
* 参数个数：$#  
* 程序名：$0  
* 所有参数一个字符串显示，如”$1 $2 $3” ：$*  
* 所有参数多个参数返回，如”$1” “$2” “$3”：$@  
* 当前进程ID：$$  


**移动参数shift / shift n**  
场景是判断参数或者使用参数，while循环中判断$1的值再shift，常用于处理选项  
缺点是移动后参数会被覆盖不可恢复

**处理选项**
* 参数简单且不考虑合并（如：-ab）场景：  
一般是外层while -n判断$1非空  
循环内部case in判断$1的选项-a)，如果内部有参数获取，获取后再shift  
判断--：shift break跳出循环，再获取$@剩余参数，  
判断*：选项异常，可以加一条提示  
Case外，shift把下一个选项前移  
* 参数复杂且存在合并需求：case内判断-a)  
Getopt：set -- \`getopt –q ab:cdef “@”\`（-q忽略选项不存在的报错，加冒号代表需要参数） 
* 参数复杂、存在合并、且参数中包含空格（-a "arg1 arg2”）  
  * Getopts:不存在的选项显示为？，执行时可以选项和参数之间不带空格./test –abarg1  
While getopts : ab:c opt这个原理相当于遍历参数，case判断$opt的值，可以自动提取-后的字符，所以判断时写a)，而且循环内就不用再shift了  
Case内有两个参数  
$OPTARG：当前选项的参数值  
$OPTIND：当前选项的位置，处理完一个选项后会自动+1，  
最后在while循环之后，shift $[$OPTIND-1]，把剩余参数shift出来，再处理$@  


**算术**  
整数运算：$(())/$[]   
+-*/%  内部有变量可以不加${}，如$[a+b+1]（不需要转义）  
浮点数运算用bc  

**(())**  
对整数的testing判断==，<，>，&&  
运算+-*/%  
自增减++ --，自增也可用Let “int++”  
内部赋值：((b=a-15))   
取结果：a=$((b+c)) （内部不用加$来取值）  

**数字比较if [ $a –eq $b ]**  
-eq 等，-ne 不等，-gt 大于，小于-lt，-ge大于等于，-le小于等于  

**字符串比较：if []**  
=，!=，-z是否为0，-n是否不为0    
更高级用[[]]可用正则==  
注意[]中使用变量要加""，[[]]不用加引号

**布尔**：!非，-o或，-a与  
**逻辑**：&& ||   

**Read读取输入**  
Read –p “enter a num” num  
-t 5 超时后，状态码非0退出  
-s 输入隐藏：密码输入  
也可以按行处理命令的输出，命令 | while read line  循环处理每一行的$line  

**echo –e**可用转义字符  \n \c    
**echo –n**单行显示，不换行  
**printf "%-10s %-8s %-4.2f\n" 郭芙 女 47.9876**  

* -左对齐  不加-是右对齐
* 10：输出最小宽度字符，不够自动补空格
* .2f :保留两位小数

**流程控制**  
* If []  (注意左右有空格)
Then
Elif []
Then
Else
Fi

* For in do done，也可以for((int=0;int<7;int++))
* While do done
* Until do done  
以上的done后可以加>重定向文件，或者|  
* Case in 
) ;;
);; 
Esac

* Break跳出所有循环
* Continue跳出当前循环

**函数**  
函数要先定义再使用，同名函数在此定义会被重写  
函数内使用local赋值，避免和全局变量冲突，有同名时值也会分离开来  
返回值$? 函数返回值会被其他命令覆盖，最好调用完存入变量  
`Sum() {
	Return 
}
Function sum {
}`

* 数字或字符串返回建议：  
最好不用$?，因为输出不能大于256，可以用函数内echo，然后赋值给变量，var=\`function\`，当做返回值
* 传参数组：  
函数内部用temp_arr=(\`echo "$@"\`)取数组，调用时传sum ${arr[*]}：
* 返回数组：  
函数内部用下标for依次赋值，然后返回echo ${arr[*]}，调用后取result_arr=(\`function_name var\`)，


**$()同\`\`**  
用作命令嵌套，或者把命令的输出赋值给变量

**A|B 管道**    
把A命令的输出用做B命令的输入，more可以规定显示状态（全部显示还是当前显示最大行数）

**输出结果一般用做wc统计**

**切割字符串cut/awk**
* Cut：\`echo $str | cut -d " " -f1\`  默认制表符分隔  
    * -d ” ”指定分隔符  
    * -fn取第n列（1，2或者1-2）  
    * -c 1-2 输出每一行的一到2的字符  
* Awk：awk -F '"' '{print $1"=>"$2}'  
    * -F “ ”制定分隔符  （不指定时默认空格分隔）
    * $1取第一个数据  

**输入输出重定向**  
\>被覆盖 >>不被覆盖  
<输入重定向  
0：STDIN 输入  
1：STDOUT输出  
2：STDERR错误  

* 命令行重定向输出：
    * 单独：1>out 2>err
    * 1和2全部重定向：&>all_out
* 脚本中临时重定向：命令>&2，运行时：./test 2>err
* 脚本中永久重定向：exec 1/2>out 运行时脚本输出和>&强制输出的都会重定向，直到有语句改变
* 输入重定向：exec 0<file 然后配合while read line，来处理数据

**引入其他脚本**  
. name或者source name，就可以调用此脚本的变量或者函数

## git
**ssh-key配置**  
$ git config --global user.name "wanglun7"  
$ git config --global user.email "659366659@qq.com"  
$ ssh-keygen -t rsa -C "659366659@qq.com"  
$ cat ~/.ssh/id_rsa.pub  

测试连接：ssh -T git@github.com  
查看git配置：git config -l

**git status**  
查看工作区代码相对于暂存区的差别

**git add**  
将当前目录下修改的所有代码从工作区添加到暂存区 . 代表当前目录

* git add .
已跟踪修改+新添加，**不包括删除**
* git add -u .
已跟踪修改+删除，**不包括新添加**，注意这些被删除的文件被加入到暂存区再被提交并推送到服务器的版本库之后这个文件就会从git系统中消失了。
* git add -A .
已跟踪修改+删除+新添加

**git commit -m ‘注释’**：将缓存区内容添加到本地仓库  

* git commit -am ‘message’  相当于加了个-a
如果没有新增，只有已跟踪文件的修改或者删除操作，用这个可以省略git add操作
* git commit -s：在提交时显示  signed-off-by 

**git pull origin master**  
将远程仓库master中的信息同步到本地分支master中

**git push origin master**  
将本地版本库分支master推送到远程服务器

**git branch -a**  查看所有分支(当前分支不加-a)

**git checkout -b dev origin/dev**  切换分支

**整合远程变更：**
 git push -u origin + dev 

