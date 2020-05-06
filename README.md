# linux,shell,git
## git
测试连接：ssh -T git@github.com
### git status
查看工作区代码相对于暂存区的差别
### git add 
将当前目录下修改的所有代码从工作区添加到暂存区 . 代表当前目录
* git add .
已跟踪修改+新添加，**不包括删除**
* git add -u .
已跟踪修改+删除，**不包括新添加**，注意这些被删除的文件被加入到暂存区再被提交并推送到服务器的版本库之后这个文件就会从git系统中消失了。
* git add -A .
已跟踪修改+删除+新添加
### git commit -m ‘注释’ 
将缓存区内容添加到本地仓库
* git commit -am ‘message’  相当于加了个-a
如果没有新增，只有已跟踪文件的修改或者删除操作，用这个可以省略git add操作
### git pull origin master
将远程仓库master中的信息同步到本地分支master中
### git push origin master 
将本地版本库分支master推送到远程服务器


